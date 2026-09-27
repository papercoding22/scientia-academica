#!/usr/bin/env python3
"""Dựng SVG dạng bảng (header + rows) từ một spec JSON đơn giản.

Dùng chung với scripts/note-image.py để render PNG:
    python3 scripts/table-svg.py init --output spec.json
    # sửa spec.json: title, columns, rows, note
    python3 scripts/table-svg.py build spec.json --output table.svg
    python3 scripts/note-image.py render table.svg --output table.png

Không phải renderer: chỉ sinh SVG. Xem scripts/note-image.md cho phần render/markdown.
"""
import argparse
import json
import sys
from pathlib import Path

FORBIDDEN_DIRS = {"materials", "brief", "_raw"}

SAMPLE_SPEC = {
    "title": "Tiêu đề bảng",
    "subtitle": "Phụ đề ngắn (môn học · bài tập · mục)",
    "columns": ["cột 1", "cột 2", "cột 3"],
    "rows": [
        ["hàng 1", "✔", ""],
        ["hàng 2", "", "✔"],
    ],
    "mark_color": "#1e8f4e",
    "header_color": "#2f5496",
    "note": [
        "Nguồn: ghi rõ mục/đề gốc đã chép vào bảng này.",
    ],
}


def xml_escape(text: str) -> str:
    return (
        str(text)
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
    )


def is_forbidden(path: Path) -> bool:
    resolved = path.resolve()
    return any(part in FORBIDDEN_DIRS for part in resolved.parts)


def cmd_init(args):
    out = Path(args.output)
    if is_forbidden(out):
        sys.exit(f"Lỗi: không ghi vào thư mục bị chặn ({out})")
    if out.exists() and not args.force:
        sys.exit(f"Lỗi: {out} đã tồn tại. Dùng --force nếu muốn ghi đè.")
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(SAMPLE_SPEC, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Đã tạo spec mẫu: {out}")


def build_svg(spec: dict) -> str:
    columns = spec["columns"]
    rows = spec["rows"]
    for r in rows:
        if len(r) != len(columns):
            raise ValueError(
                f"Hàng {r!r} có {len(r)} ô, khác số cột ({len(columns)})"
            )

    title = spec.get("title", "")
    subtitle = spec.get("subtitle", "")
    note_lines = spec.get("note", [])
    header_color = spec.get("header_color", "#2f5496")
    mark_color = spec.get("mark_color", "#1e8f4e")
    text_color = spec.get("text_color", "#1a1a1a")

    label_col_width = spec.get("label_col_width", 140)
    data_col_width = spec.get("data_col_width", 120)
    row_height = spec.get("row_height", 40)
    n_data_cols = len(columns) - 1

    table_width = label_col_width + n_data_cols * data_col_width
    margin_x = 40
    top = 70 if (title or subtitle) else 20
    header_h = row_height
    body_h = row_height * len(rows)
    note_h = 18 * len(note_lines) + (14 if note_lines else 0)

    width = table_width + margin_x * 2
    height = top + header_h + body_h + note_h + 20

    col_x = [margin_x]
    col_x.append(margin_x + label_col_width)
    for i in range(1, n_data_cols):
        col_x.append(col_x[-1] + data_col_width)
    col_x.append(margin_x + table_width)

    def col_center(i):
        return (col_x[i] + col_x[i + 1]) / 2

    parts = []
    parts.append(
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}" font-family="Segoe UI, Arial, sans-serif">'
    )
    parts.append(f'<rect x="0" y="0" width="{width}" height="{height}" fill="#ffffff"/>')

    if title:
        parts.append(
            f'<text x="{width/2}" y="32" font-size="18" font-weight="bold" '
            f'text-anchor="middle" fill="#1a1a1a">{xml_escape(title)}</text>'
        )
    if subtitle:
        parts.append(
            f'<text x="{width/2}" y="52" font-size="12" '
            f'text-anchor="middle" fill="#555555">{xml_escape(subtitle)}</text>'
        )

    header_y = top
    parts.append(
        f'<rect x="{margin_x}" y="{header_y}" width="{table_width}" height="{header_h}" '
        f'fill="{header_color}"/>'
    )
    for i, col in enumerate(columns):
        parts.append(
            f'<text x="{col_center(i)}" y="{header_y + header_h/2 + 5}" font-size="15" '
            f'font-weight="bold" text-anchor="middle" fill="#ffffff">{xml_escape(col)}</text>'
        )

    for r_idx, row in enumerate(rows):
        row_y = header_y + header_h + r_idx * row_height
        bg = "#f2f6fc" if r_idx % 2 == 0 else "#ffffff"
        parts.append(
            f'<rect x="{margin_x}" y="{row_y}" width="{table_width}" height="{row_height}" '
            f'fill="{bg}"/>'
        )
        for c_idx, cell in enumerate(row):
            cell_text = str(cell)
            is_mark = cell_text.strip() != "" and c_idx > 0 and len(cell_text.strip()) <= 2
            fill = mark_color if is_mark else text_color
            font_size = 18 if is_mark else 15
            weight = ' font-weight="bold"' if is_mark else ""
            parts.append(
                f'<text x="{col_center(c_idx)}" y="{row_y + row_height/2 + 5}" '
                f'font-size="{font_size}"{weight} text-anchor="middle" '
                f'fill="{fill}">{xml_escape(cell_text)}</text>'
            )

    grid_bottom = header_y + header_h + body_h
    parts.append(f'<g stroke="#c9d6e8" stroke-width="1">')
    for y in [header_y] + [header_y + header_h + i * row_height for i in range(len(rows) + 1)]:
        parts.append(f'<line x1="{margin_x}" y1="{y}" x2="{margin_x + table_width}" y2="{y}"/>')
    for x in col_x:
        parts.append(f'<line x1="{x}" y1="{header_y}" x2="{x}" y2="{grid_bottom}"/>')
    parts.append("</g>")
    parts.append(
        f'<rect x="{margin_x}" y="{header_y}" width="{table_width}" height="{header_h + body_h}" '
        f'fill="none" stroke="{header_color}" stroke-width="2"/>'
    )

    note_y = grid_bottom + 24
    for line in note_lines:
        parts.append(
            f'<text x="{margin_x}" y="{note_y}" font-size="11" fill="#777777">{xml_escape(line)}</text>'
        )
        note_y += 18

    parts.append("</svg>")
    return "\n".join(parts)


def cmd_build(args):
    spec_path = Path(args.spec)
    if not spec_path.exists():
        sys.exit(f"Lỗi: không thấy {spec_path}")
    spec = json.loads(spec_path.read_text(encoding="utf-8"))

    out = Path(args.output)
    if is_forbidden(out):
        sys.exit(f"Lỗi: không ghi vào thư mục bị chặn ({out})")
    if out.suffix.lower() != ".svg":
        sys.exit("Lỗi: --output phải có đuôi .svg")
    if out.exists() and not args.force:
        sys.exit(f"Lỗi: {out} đã tồn tại. Dùng --force nếu muốn ghi đè.")

    try:
        svg = build_svg(spec)
    except (KeyError, ValueError) as e:
        sys.exit(f"Lỗi spec: {e}")

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(svg, encoding="utf-8")
    print(f"Đã dựng SVG: {out}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_init = sub.add_parser("init", help="Xuất spec JSON mẫu")
    p_init.add_argument("--output", required=True)
    p_init.add_argument("--force", action="store_true")
    p_init.set_defaults(func=cmd_init)

    p_build = sub.add_parser("build", help="Dựng SVG từ spec JSON")
    p_build.add_argument("spec")
    p_build.add_argument("--output", required=True)
    p_build.add_argument("--force", action="store_true")
    p_build.set_defaults(func=cmd_build)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
