#!/usr/bin/env python3
"""
doc2md.py — Chuyển tài liệu sang Markdown. Lõi dùng chung cho peek.py và slides-to-md.py.

    doc2md.py pdf <file>       PDF → Markdown, mỗi trang một mục "## Trang N"
    doc2md.py office <file>    .docx .pptx .xlsx → Markdown qua MarkItDown

Phải chạy bằng Python của tool MarkItDown (cài bằng uv, Python ≥ 3.10), không phải
python3 của hệ thống. Script khác gọi qua hàm tool_python() — hàm này chạy được cả trên 3.9.

Vì sao PDF không dùng thẳng `markitdown file.pdf`:
  - Converter PDF của MarkItDown đoán trang nào "trông như bảng", nên đoạn văn căn đều
    trong slide bị dựng thành bảng giả (IT007: 30–40% số dòng). Không có cờ để tắt.
  - Kết quả không đánh dấu trang → không trỏ ngược về slide để xem hình được.
  → Dùng pdfminer (MarkItDown đã kéo theo) trích chữ thuần từng trang.

Cài một lần:
    brew install uv
    uv tool install --python 3.12 'markitdown[pdf,docx,pptx,xlsx]'
"""
import os, sys, re, pathlib, shutil, subprocess
from collections import Counter

INSTALL_HINT = ("chưa cài MarkItDown — chạy: brew install uv && "
                "uv tool install --python 3.12 'markitdown[pdf,docx,pptx,xlsx]'")

# Trang có ít chữ hơn ngưỡng này (sau khi bỏ header/footer lặp lại) coi là trang hình
IMAGE_PAGE_CHARS = 40


def tool_python():
    """Đường dẫn Python của tool markitdown, hoặc None nếu chưa cài."""
    env = os.environ.get("MARKITDOWN_PYTHON")
    if env and pathlib.Path(env).exists():
        return env
    tool_dir = None
    if shutil.which("uv"):
        try:
            tool_dir = subprocess.run(["uv", "tool", "dir"], capture_output=True,
                                      text=True, check=True).stdout.strip()
        except (subprocess.CalledProcessError, OSError):
            pass
    tool_dir = tool_dir or str(pathlib.Path.home() / ".local/share/uv/tools")
    py = pathlib.Path(tool_dir) / "markitdown" / "bin" / "python"
    return str(py) if py.exists() else None


def run(mode, path):
    """Gọi script này bằng Python của tool. Trả về (markdown, lỗi)."""
    py = tool_python()
    if not py:
        return None, INSTALL_HINT
    r = subprocess.run([py, __file__, mode, str(path)], capture_output=True, text=True)
    if r.returncode != 0:
        return None, (r.stderr.strip().splitlines() or ["lỗi không rõ"])[-1]
    return r.stdout, None


def _unspace(line):
    """'Tr ì n h   b à y' → 'Trình bày'. Chữ giãn khoảng trong slide làm grep trượt."""
    tokens = line.split()
    if len(tokens) < 6 or sum(len(t) == 1 for t in tokens) < 0.7 * len(tokens):
        return " ".join(tokens)  # chữ căn đều "Hiểu  được  các" → một khoảng trắng
    return " ".join(w.replace(" ", "") for w in re.split(r" {2,}", line.strip()))


def _content_lines(text, boilerplate):
    return [_unspace(l.strip()) for l in text.splitlines()
            if l.strip() and l.strip() not in boilerplate and not l.strip().isdigit()]


def pdf_to_md(path):
    from pdfminer.high_level import extract_text
    pages = extract_text(path).split("\f")
    if pages and not pages[-1].strip():
        pages.pop()
    # Dòng lặp ở ≥ 40% số trang là header/footer (vd "Thực hiện bởi Trường ĐH CNTT…")
    freq = Counter(l.strip() for p in pages for l in set(p.splitlines()) if l.strip())
    boiler = {l for l, n in freq.items() if len(pages) >= 5 and n >= 0.4 * len(pages)}

    image_pages, body = [], []
    for i, p in enumerate(pages, 1):
        lines = _content_lines(p, boiler)
        if sum(len(l) for l in lines) < IMAGE_PAGE_CHARS:
            image_pages.append(i)
            flag = " ⚠️ chủ yếu là hình — cần Read"
        else:
            flag = ""
        body.append(f"## Trang {i}{flag}\n\n" + "\n".join(lines))

    name = pathlib.Path(path).name
    head = [f"# {name}", "",
            f"> Trích tự động từ `{name}` bằng pdfminer — chỉ để tìm kiếm, **không phải nguồn**.",
            f"> Trích dẫn thì ghi tên file gốc + số trang. {len(pages)} trang."]
    if len(image_pages) == len(pages):
        head.append("> ⚠️ **Không có lớp chữ** (chữ đã bị chuyển thành hình) — đọc bằng Read.")
    elif image_pages:
        head.append(f"> ⚠️ Trang chủ yếu là hình ({len(image_pages)}): "
                    + ", ".join(map(str, image_pages)))
    return "\n".join(head) + "\n\n" + "\n\n".join(body) + "\n"


def office_to_md(path):
    from markitdown import MarkItDown
    return MarkItDown().convert_local(path).markdown


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] not in ("pdf", "office"):
        print(__doc__); sys.exit(1)
    mode, f = sys.argv[1], sys.argv[2]
    try:
        out = pdf_to_md(f) if mode == "pdf" else office_to_md(f)
    except ImportError:
        sys.exit(INSTALL_HINT)
    sys.stdout.write(out)
