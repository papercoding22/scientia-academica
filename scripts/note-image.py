#!/usr/bin/env python3
"""CLI dùng chung cho skill tạo/chèn hình. Xem scripts/note-image.md."""

import argparse
import json
import os
from pathlib import Path
import re
import sys
from urllib.parse import quote
import xml.etree.ElementTree as ET

from lib.image_render import BACKENDS, available, png_size, render
from lib.image_svg import build

ROOT = Path(__file__).resolve().parent.parent


def output_path(value, suffix, force=False):
    path = Path(value).absolute()
    if path.suffix.lower() != suffix:
        raise ValueError("Đầu ra cần đuôi %s" % suffix)
    if path.is_symlink():
        raise ValueError("Không ghi đè symlink đầu ra: %s" % path)
    resolved = path.resolve()
    if any(part in ("materials", "brief", "_raw") for part in resolved.parts):
        raise ValueError("Không ghi vào thư mục nguồn materials/, brief/, _raw/")
    if path.exists() and not force:
        raise ValueError("File đã tồn tại: %s. Chọn tên khác; --force chỉ khi đã được yêu cầu thay thế." % path)
    return path


def save(path, data, force=False):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb" if force else "xb") as stream:
        stream.write(data)
    print(path)


def single_line(value, name):
    if not value.strip() or "\n" in value or "\r" in value:
        raise ValueError("%s phải là một dòng không rỗng" % name)
    return value


def markdown(note, image, alt, caption=None, svg=None, readings=()):
    note, image = Path(note).resolve(), Path(image).resolve()
    if note.suffix.lower() != ".md" or not note.is_file():
        raise ValueError("--note phải trỏ tới Markdown có sẵn")
    if image.suffix.lower() not in (".png", ".jpg", ".jpeg", ".webp", ".svg", ".gif", ".avif"):
        raise ValueError("Cần file ảnh PNG/JPEG/WebP/SVG/GIF/AVIF")

    def link(path):
        path = Path(path).resolve()
        if not path.is_file():
            raise ValueError("File không tồn tại: %s" % path)
        for target in (note, path):
            try:
                target.relative_to(ROOT)
            except ValueError as exc:
                raise ValueError("Markdown cần note và ảnh nằm trong repo; hãy lưu ảnh trước") from exc
        return quote(Path(os.path.relpath(path, note.parent)).as_posix(), safe="/-._~")

    alt = re.sub(r"([\\\[\]])", r"\\\1", single_line(alt, "alt"))
    result = ["![%s](%s)" % (alt, link(image))]
    if caption:
        result.append(single_line(caption, "caption"))
    if svg:
        if Path(svg).suffix.lower() != ".svg":
            raise ValueError("--svg cần file SVG")
        result.append("[SVG chỉnh sửa](%s)" % link(svg))
    if readings:
        result.append("**Đọc hình:**\n\n" + "\n".join(
            "- " + single_line(item, "read") for item in readings))
    return "\n\n".join(result)+"\n"


def parser():
    p = argparse.ArgumentParser(description=__doc__)
    commands = p.add_subparsers(dest="command", required=True)
    commands.add_parser("doctor", help="Liệt kê renderer đã có, không cài đặt")
    init = commands.add_parser("init", help="Copy mẫu JSON để sửa nội dung/bố cục")
    init.add_argument("kind", choices=("concept", "mechanism", "mindmap"))
    init.add_argument("--output", required=True)
    init.add_argument("--force", action="store_true")
    make = commands.add_parser("build", help="JSON → SVG; không tự render/chèn note")
    make.add_argument("spec")
    make.add_argument("--output", required=True)
    make.add_argument("--force", action="store_true")
    raster = commands.add_parser("render", help="SVG → PNG đúng tỉ lệ, giữ SVG gốc")
    raster.add_argument("svg")
    raster.add_argument("--output", required=True)
    raster.add_argument("--backend", choices=("auto",)+BACKENDS, default="auto")
    raster.add_argument("--width", type=int, help="Chiều rộng PNG; chiều cao theo tỉ lệ SVG")
    raster.add_argument("--force", action="store_true")
    snippet = commands.add_parser("markdown", help="In block Markdown; không sửa note")
    snippet.add_argument("image")
    snippet.add_argument("--note", required=True)
    snippet.add_argument("--alt", required=True)
    snippet.add_argument("--caption", help="Caption có thể chứa Markdown và nguồn đã đối chiếu")
    snippet.add_argument("--svg")
    snippet.add_argument("--read", action="append", default=[], help="Lặp lại cho mỗi bullet Đọc hình")
    return p


def main(argv=None):
    args = parser().parse_args(argv)
    try:
        if args.command == "doctor":
            for name, path in available().items():
                print("%s: %s" % (name, path or "chưa có"))
            print("build/markdown chỉ cần Python 3.9+. Render cần một công cụ ở trên.")
            return 0
        if args.command == "markdown":
            print(markdown(args.note, args.image, args.alt, args.caption, args.svg, args.read), end="")
            return 0
        suffix = {"init": ".json", "build": ".svg", "render": ".png"}[args.command]
        output = output_path(args.output, suffix, args.force)
        if args.command == "init":
            data = (ROOT/"templates"/"images"/(args.kind+".json")).read_bytes()
        elif args.command == "build":
            data = build(json.loads(Path(args.spec).read_text(encoding="utf-8")))
        else:
            if args.width is not None and args.width <= 0:
                raise ValueError("--width phải dương")
            data, backend, dimensions = render(args.svg, args.backend, args.width)
            print("Renderer: %s · PNG %s × %s" % (backend, *dimensions), file=sys.stderr)
            if png_size(data) != dimensions:
                raise ValueError("PNG không khớp kích thước")
        save(output, data, args.force)
        return 0
    except (ValueError, OSError, KeyError, TypeError, ET.ParseError) as exc:
        print("Lỗi: %s" % exc, file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
