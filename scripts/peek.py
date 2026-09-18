#!/usr/bin/env python3
"""
peek.py — Nhìn nhanh vào trong file để biết nó là gì, phục vụ việc phân loại.

    scripts/peek.py <file> [<file>...]     In metadata + vài đoạn đầu
    scripts/peek.py --full <file>          In toàn bộ text

Hỗ trợ: .docx  .vtt  .txt  .md  .csv
PDF: script không đọc được — dùng công cụ đọc file của AI (Read) thay thế.
"""
import sys, re, zipfile, pathlib

def docx(p):
    with zipfile.ZipFile(p) as z:
        xml = z.read("word/document.xml").decode("utf-8", "replace")
        imgs = [n for n in z.namelist() if n.startswith("word/media/")]
    paras = []
    for blk in re.split(r"</w:p>", xml):
        t = "".join(re.findall(r"<w:t[^>]*>([^<]*)</w:t>", blk)).strip()
        if t:
            paras.append(t)
    return paras, {"ảnh nhúng": len(imgs)}

def vtt(p):
    txt = p.read_text(encoding="utf-8", errors="replace")
    cues, meta = [], {}
    for blk in txt.split("\n\n"):
        lines = [l for l in blk.splitlines() if l.strip()]
        ts = next((l for l in lines if " --> " in l), None)
        if not ts:
            continue
        body = " ".join(l for l in lines if l is not ts and " --> " not in l)
        sp = ""
        m = re.search(r"<v[^ >]*\s*([^>]*)>", body)
        if m:
            sp = m.group(1)
        body = re.sub(r"<[^>]*>", "", body).strip()
        if body:
            cues.append(f"[{ts.split(' --> ')[0][:8]}] {sp + ': ' if sp else ''}{body}")
    meta["lượt nói"] = len(cues)
    return cues, meta

def plain(p):
    return [l for l in p.read_text(encoding="utf-8", errors="replace").splitlines() if l.strip()], {}

READERS = {".docx": docx, ".vtt": vtt, ".txt": plain, ".md": plain, ".csv": plain}

def peek(path, full=False):
    p = pathlib.Path(path)
    print(f"\n{'='*72}\n{p.name}")
    if not p.exists():
        print("   ✗ không tồn tại"); return
    size = p.stat().st_size
    print(f"   {size:,} byte · {p.suffix or '(không đuôi)'}")
    fn = READERS.get(p.suffix.lower())
    if not fn:
        if p.suffix.lower() == ".pdf":
            print("   → PDF: script không đọc được. Dùng công cụ Read của AI để xem nội dung.")
        else:
            print(f"   → Không hỗ trợ đuôi {p.suffix}")
        return
    try:
        parts, meta = fn(p)
    except Exception as e:
        print(f"   ✗ lỗi đọc: {e}"); return
    words = sum(len(x.split()) for x in parts)
    extra = " · ".join(f"{k}: {v}" for k, v in meta.items())
    print(f"   {len(parts)} đoạn · ~{words:,} từ{' · ' + extra if extra else ''}")
    print()
    for x in (parts if full else parts[:15]):
        print(f"   │ {x[:150]}")
    if not full and len(parts) > 15:
        print(f"   │ … còn {len(parts)-15} đoạn (dùng --full để xem hết)")

if __name__ == "__main__":
    args = sys.argv[1:]
    if not args:
        print(__doc__); sys.exit(1)
    full = "--full" in args
    for a in [x for x in args if not x.startswith("--")]:
        peek(a, full)
