"""Chạy: python3 -m unittest discover -s scripts/tests -p 'test_note_image.py'."""

import importlib.util
import json
from pathlib import Path
import struct
import sys
import tempfile
import unittest
from unittest.mock import patch
from urllib.parse import unquote
import xml.etree.ElementTree as ET
import zlib

SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))
from lib.image_render import PNG, chunk, crop_png, png_chunks, png_size, render, svg_geometry
from lib.image_svg import NS, build

loader = importlib.util.spec_from_file_location("note_image", SCRIPTS/"note-image.py")
cli = importlib.util.module_from_spec(loader)
loader.loader.exec_module(cli)


def fixture_png(width, height, channels, method):
    """Sinh pixel không đều để phát hiện crop sai góc và unfilter sai hàng/cột."""
    rows = [bytes((17*x+43*y) % 256 for x in range(width*channels)) for y in range(height)]
    raw = bytearray()
    for y, row in enumerate(rows):
        raw.append(method)
        for x, value in enumerate(row):
            a = row[x-channels] if x >= channels else 0
            b = rows[y-1][x] if y else 0
            c = rows[y-1][x-channels] if y and x >= channels else 0
            if method == 4:
                p = a+b-c
                da, db, dc = abs(p-a), abs(p-b), abs(p-c)
                predictor = a if da <= db and da <= dc else b if db <= dc else c
            else:
                predictor = (0, a, b, (a+b)//2)[method]
            raw.append((value-predictor) % 256)
    color = {1: 0, 2: 4, 3: 2, 4: 6}[channels]
    header = struct.pack(">IIBBBBB", width, height, 8, color, 0, 0, 0)
    data = PNG+chunk(b"IHDR", header)+chunk(b"sRGB", b"\0")
    return data+chunk(b"IDAT", zlib.compress(raw))+chunk(b"IEND", b""), rows


class PNGTests(unittest.TestCase):
    def test_crop_preserves_top_left_pixels_for_all_filters_and_orientations(self):
        for channels in (1, 2, 3, 4):
            for method in range(5):
                for width, height in ((7, 3), (3, 7), (7, 7)):
                    with self.subTest(channels=channels, method=method, size=(width, height)):
                        original, rows = fixture_png(7, 7, channels, method)
                        result = crop_png(original, width, height)
                        self.assertEqual(png_size(result), (width, height))
                        chunks = list(png_chunks(result))
                        self.assertIn((b"sRGB", b"\0"), chunks)
                        raw = zlib.decompress(b"".join(p for k, p in chunks if k == b"IDAT"))
                        expected = b"".join(b"\0"+row[:width*channels] for row in rows[:height])
                        self.assertEqual(raw, expected)

    def test_reject_bad_crc_and_unsupported_crop(self):
        original, _ = fixture_png(3, 3, 4, 0)
        with self.assertRaises(ValueError):
            crop_png(original, 4, 3)
        damaged = bytearray(original)
        damaged[16] ^= 1
        with self.assertRaises(ValueError):
            crop_png(bytes(damaged), 2, 2)


class WorkflowTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="note-image-test-")
        self.addCleanup(self.tmp.cleanup)
        self.folder = Path(self.tmp.name).resolve()

    def test_templates_build_valid_editable_svg(self):
        for path in (SCRIPTS.parent/"templates"/"images").glob("*.json"):
            with self.subTest(path=path.name):
                data = build(json.loads(path.read_text()))
                root = ET.fromstring(data)
                self.assertEqual(root.tag, "{%s}svg" % NS)
                self.assertTrue(root.findall(".//{%s}text" % NS))
                self.assertNotIn(b"<image", data)

    def test_vietnamese_xml_escaping_and_multiline(self):
        spec = {"kind": "concept", "title": "Địa chỉ <ảo> & thật", "elements": [
            {"type": "text", "x": 50, "y": 150, "text": "Bộ nhớ <RAM>\nA & B"}]}
        root = ET.fromstring(build(spec))
        texts = [n.text for n in root.findall(".//{%s}tspan" % NS)]
        self.assertIn("Địa chỉ <ảo> & thật", texts)
        self.assertIn("Bộ nhớ <RAM>", texts)
        self.assertIn("A & B", texts)

    def test_oversized_scene_rejected(self):
        spec = {"kind": "mechanism", "title": "Test", "elements": [
            {"type": "rect", "x": 1100, "y": 10, "width": 200, "height": 100}]}
        with self.assertRaises(ValueError):
            build(spec)

    def test_no_overwrite_or_write_to_input_even_through_symlink(self):
        existing = self.folder/"image.svg"
        existing.write_text("original")
        with self.assertRaises(ValueError):
            cli.output_path(existing, ".svg")
        self.assertEqual(existing.read_text(), "original")
        protected = self.folder/"materials"
        protected.mkdir()
        alias = self.folder/"alias"
        alias.symlink_to(protected, target_is_directory=True)
        for path in (protected/"new.svg", alias/"new.svg"):
            with self.assertRaises(ValueError):
                cli.output_path(path, ".svg", force=True)

    def test_markdown_links_bullets_and_no_note_mutation(self):
        note = self.folder/"note.md"
        note.write_text("# Ghi chú\n", encoding="utf-8")
        image = self.folder/"Ảnh [1] #100%.png"
        image.write_bytes(fixture_png(3, 3, 4, 0)[0])
        with patch.object(cli, "ROOT", self.folder):
            result = cli.markdown(note, image, "Ánh xạ [page]", readings=["**Bước 1:** Tra bảng.", "**Bước 2:** Đọc RAM."])
        url = result.split("](", 1)[1].split(")", 1)[0]
        self.assertEqual((note.parent/unquote(url)).resolve(), image)
        self.assertIn("**Đọc hình:**\n\n- **Bước 1:**", result)
        self.assertIn("\n- **Bước 2:**", result)
        self.assertEqual(note.read_text(), "# Ghi chú\n")

    def test_markdown_rejects_missing_external_or_multiline_assets(self):
        note = self.folder/"note.md"
        note.touch()
        image = self.folder/"image.png"
        image.touch()
        with patch.object(cli, "ROOT", self.folder):
            for path in (self.folder/"missing.png", SCRIPTS/"note-image.py"):
                with self.assertRaises(ValueError):
                    cli.markdown(note, path, "Hình")
            with self.assertRaises(ValueError):
                cli.markdown(note, image, "Hình", readings=["Một ý\n- Ý thứ hai"])

    def test_missing_renderer_does_not_create_output(self):
        svg = self.folder/"source.svg"
        svg.write_bytes(build({"kind": "concept", "title": "Test", "elements": []}))
        with patch("lib.image_render.available", return_value={}):
            with self.assertRaisesRegex(ValueError, "Chưa có renderer"):
                render(svg)

    def test_render_failure_preserves_existing_output(self):
        image = self.folder/"image.png"
        image.write_bytes(b"original")
        with patch.object(cli, "render", side_effect=ValueError("renderer failed")):
            self.assertEqual(cli.main(["render", "missing.svg", "--output", str(image), "--force"]), 1)
        self.assertEqual(image.read_bytes(), b"original")

    def test_viewbox_only_and_nonzero_origin(self):
        svg = self.folder/"source.svg"
        svg.write_text('<svg xmlns="http://www.w3.org/2000/svg" viewBox="10 20 300 500"/>')
        _, width, height = svg_geometry(svg)
        self.assertEqual((width, height), (300, 500))
        svg.write_text('<svg xmlns="http://www.w3.org/2000/svg" width="600" viewBox="10 20 300 500"/>')
        _, width, height = svg_geometry(svg)
        self.assertEqual((width, height), (600, 1000))


if __name__ == "__main__":
    unittest.main()
