"""Render SVG và crop PNG của Quick Look, không cài dependency hay gọi mạng."""

import math
from pathlib import Path
import re
import shutil
import struct
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zlib

from lib.image_svg import NS

PNG = b"\x89PNG\r\n\x1a\n"
BACKENDS = ("rsvg-convert", "inkscape", "qlmanage")


def available():
    return {name: shutil.which(name) for name in BACKENDS}


def png_chunks(data):
    if not data.startswith(PNG):
        raise ValueError("Không phải PNG")
    offset = 8
    while offset < len(data):
        if len(data)-offset < 12:
            raise ValueError("PNG bị cắt giữa chunk")
        size = struct.unpack(">I", data[offset:offset+4])[0]
        kind = data[offset+4:offset+8]
        payload = data[offset+8:offset+8+size]
        crc = data[offset+8+size:offset+12+size]
        if len(crc) != 4 or struct.unpack(">I", crc)[0] != zlib.crc32(kind+payload):
            raise ValueError("PNG bị hỏng: CRC không hợp lệ")
        yield kind, payload
        offset += size+12
        if kind == b"IEND":
            return
    raise ValueError("PNG thiếu IEND")


def png_size(data):
    kind, header = next(png_chunks(data))
    if kind != b"IHDR" or len(header) != 13:
        raise ValueError("PNG thiếu IHDR")
    return struct.unpack(">II", header[:8])


def chunk(kind, payload):
    return struct.pack(">I", len(payload))+kind+payload+struct.pack(">I", zlib.crc32(kind+payload))


def paeth(a, b, c):
    p = a+b-c
    distances = (abs(p-a), abs(p-b), abs(p-c))
    return (a, b, c)[distances.index(min(distances))]


def crop_png(data, width, height):
    """Crop góc trên trái; unfilter trước khi cắt cả chiều ngang lẫn dọc."""
    chunks = list(png_chunks(data))
    if chunks[0][0] != b"IHDR":
        raise ValueError("PNG thiếu IHDR")
    w, h, depth, color, compression, filtering, interlace = struct.unpack(">IIBBBBB", chunks[0][1])
    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}.get(color)
    if depth != 8 or not channels or interlace or compression or filtering:
        raise ValueError("Crop Quick Look chỉ hỗ trợ PNG 8-bit, không interlace")
    if not (0 < width <= w and 0 < height <= h):
        raise ValueError("Kích thước crop nằm ngoài PNG")
    try:
        raw = zlib.decompress(b"".join(p for k, p in chunks if k == b"IDAT"))
    except zlib.error as exc:
        raise ValueError("PNG có IDAT không hợp lệ") from exc
    stride = w*channels
    if len(raw) != (stride+1)*h:
        raise ValueError("Dữ liệu PNG không khớp kích thước")
    previous = bytearray(stride)
    output = bytearray()
    for y in range(height):
        start = y*(stride+1)
        method = raw[start]
        row = bytearray(raw[start+1:start+1+stride])
        if method not in range(5):
            raise ValueError("PNG filter không hợp lệ")
        if method:
            for x in range(stride):
                a = row[x-channels] if x >= channels else 0
                b = previous[x]
                c = previous[x-channels] if x >= channels else 0
                if method == 1:
                    predictor = a
                elif method == 2:
                    predictor = b
                elif method == 3:
                    predictor = (a+b)//2
                else:
                    predictor = paeth(a, b, c)
                row[x] = (row[x]+predictor) & 255
        output.append(0)
        output.extend(row[:width*channels])
        previous = row
    header = struct.pack(">IIBBBBB", width, height, depth, color, 0, 0, 0)
    # Giữ palette, transparency và metadata màu; bỏ metadata kích thước cũ.
    metadata = b"".join(chunk(k, p) for k, p in chunks
                        if k in (b"PLTE", b"tRNS", b"sRGB", b"gAMA", b"cHRM", b"iCCP"))
    return PNG+chunk(b"IHDR", header)+metadata+chunk(b"IDAT", zlib.compress(output))+chunk(b"IEND", b"")


def svg_geometry(path):
    root = ET.parse(path).getroot()
    if root.tag != "{%s}svg" % NS:
        raise ValueError("Cần SVG có namespace http://www.w3.org/2000/svg")
    viewbox = root.get("viewBox", "").replace(",", " ").split()
    dims = []
    for name in ("width", "height"):
        match = re.fullmatch(r"([0-9]+(?:\.[0-9]+)?)(?:px)?", root.get(name, ""))
        dims.append(float(match[1]) if match else None)
    if None in dims:
        if len(viewbox) != 4:
            raise ValueError("SVG cần width/height dạng số hoặc px, hoặc viewBox")
        # Không đoán kích thước vật lý từ cm/in/%: chỉ fallback khi thuộc tính thiếu.
        if any(root.get(k) for k, d in zip(("width", "height"), dims) if d is None):
            raise ValueError("Chuyển width/height SVG sang số hoặc px trước khi render")
        box_w, box_h = float(viewbox[2]), float(viewbox[3])
        if not all(math.isfinite(d) and d > 0 for d in (box_w, box_h)):
            raise ValueError("viewBox cần chiều rộng/cao dương và hữu hạn")
        if dims == [None, None]:
            dims = [box_w, box_h]
        elif dims[0] is None:
            dims[0] = dims[1]*box_w/box_h
        else:
            dims[1] = dims[0]*box_h/box_w
    if any(not math.isfinite(d) or d <= 0 for d in dims):
        raise ValueError("Kích thước SVG phải dương và hữu hạn")
    return root, dims[0], dims[1]


def run(command):
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=60)
    except subprocess.TimeoutExpired as exc:
        raise ValueError("Renderer quá thời gian 60 giây") from exc
    if result.returncode:
        message = (result.stderr or result.stdout).strip()
        raise ValueError("Renderer thất bại: %s\n%s\nNếu bị sandbox chặn, xin quyền cho chính lệnh render này; không đổi công cụ để né quyền."
                         % (command[0], message[-2000:]))


def render(source, backend="auto", width=None):
    source = Path(source).resolve()
    root, original_w, original_h = svg_geometry(source)
    w = width or round(original_w)
    h = round(w*original_h/original_w)
    if not (1 <= w <= 8192 and 1 <= h <= 8192):
        raise ValueError("PNG cần mỗi chiều trong khoảng 1–8192 px")
    installed = available()
    if backend == "auto":
        backend = next((name for name, path in installed.items() if path), None)
    if not backend or not installed.get(backend):
        raise ValueError("Chưa có renderer. Chạy doctor; cần rsvg-convert, inkscape hoặc qlmanage (macOS). Không tự cài đặt.")
    with tempfile.TemporaryDirectory(prefix="note-image-render-") as folder:
        target = Path(folder)/"render.png"
        executable = installed[backend]
        if backend == "rsvg-convert":
            run([executable, "--width", str(w), "--height", str(h), "--output", str(target), str(source)])
        elif backend == "inkscape":
            run([executable, str(source), "--export-type=png", "--export-area-page",
                 "--export-width=%s" % w, "--export-height=%s" % h, "--export-filename=%s" % target])
        else:
            # Quick Look hay ép thumbnail SVG thành vuông. Lồng nguyên viewport vào
            # canvas vuông, render rồi crop; không thay viewBox của bản nguồn.
            side = max(w, h)
            square = ET.Element("{%s}svg" % NS, {"width": str(side), "height": str(side),
                                                "viewBox": "0 0 %s %s" % (side, side)})
            if not root.get("viewBox"):
                root.set("viewBox", "0 0 %s %s" % (original_w, original_h))
            root.set("width", str(w))
            root.set("height", str(h))
            root.set("x", "0")
            root.set("y", "0")
            # Giữ base URI để asset tương đối của SVG gốc vẫn resolve đúng.
            root.set("{http://www.w3.org/XML/1998/namespace}base", source.as_uri())
            square.append(root)
            wrapper = Path(folder)/"square.svg"
            ET.ElementTree(square).write(wrapper, encoding="utf-8", xml_declaration=True)
            run([executable, "-t", "-s", str(side), "-o", folder, str(wrapper)])
            target = Path(str(wrapper)+".png")
            if not target.exists() or png_size(target.read_bytes()) != (side, side):
                raise ValueError("Quick Look không trả canvas vuông đúng kích thước; chưa xuất PNG")
            target.write_bytes(crop_png(target.read_bytes(), w, h))
        data = target.read_bytes()
        if png_size(data) != (w, h):
            raise ValueError("Renderer trả kích thước khác yêu cầu; chưa xuất PNG")
        return data, backend, (w, h)
