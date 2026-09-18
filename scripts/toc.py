#!/usr/bin/env python3
"""
toc.py — Sinh và kiểm tra mục lục cho file markdown.

    scripts/toc.py check [file...]    Kiểm tra link mục lục có trỏ đúng heading không
    scripts/toc.py gen <file>         In ra mục lục để dán vào file

Anchor sinh theo đúng luật của GitHub (github-slugger):
lowercase → bỏ mọi ký tự không phải chữ/số/gạch/gạch dưới/khoảng trắng →
khoảng trắng thành gạch nối. Dấu tiếng Việt được GIỮ NGUYÊN.
Trùng anchor thì thêm -1, -2.
"""
import sys, re, pathlib

def slug(text, seen):
    s = text.strip().lower()
    s = "".join(c for c in s if c.isalnum() or c in " -_")
    s = s.replace(" ", "-")
    n = seen.get(s, 0)
    seen[s] = n + 1
    return s if n == 0 else f"{s}-{n}"

def strip_fences(md):
    """Bỏ mọi khối ```…``` — ví dụ trong đó không phải nội dung thật."""
    out, fence = [], False
    for line in md.splitlines():
        if line.lstrip().startswith("```"):
            fence = not fence
            continue
        if not fence:
            out.append(line)
    return "\n".join(out)

def headings(md):
    """Trả về [(level, text, anchor)] cho ## và ###."""
    out, seen = [], {}
    for line in strip_fences(md).splitlines():
        m = re.match(r"^(#{2,3}) +(.+?)\s*$", line)
        if not m:
            continue
        text = m.group(2)
        if text.strip().lower() in ("mục lục", "table of contents"):
            continue
        out.append((len(m.group(1)), text, slug(text, seen)))
    return out

def has_toc(md):
    """File đã có mục lục chưa — chỉ tính heading thật, không tính ví dụ trong code block."""
    return any(t.strip().lower() == "mục lục"
               for line in strip_fences(md).splitlines()
               for t in re.findall(r"^#{2,3} +(.+?)\s*$", line))

def gen(path):
    md = pathlib.Path(path).read_text(encoding="utf-8")
    hs = headings(md)
    if not hs:
        return "", 0
    lines = ["## Mục lục", ""]
    for lvl, text, anc in hs:
        lines.append(f"{'  ' * (lvl - 2)}- [{text}](#{anc})")
    return "\n".join(lines), len(hs)

def check(path):
    md = pathlib.Path(path).read_text(encoding="utf-8")
    valid = {a for _, _, a in headings(md)}
    links = re.findall(r"\]\(#([^)]+)\)", strip_fences(md))
    if not links:
        return None                      # không có mục lục, không phải lỗi
    bad = [l for l in links if l not in valid]
    return bad

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__); sys.exit(1)
    cmd, args = sys.argv[1], sys.argv[2:]
    if cmd == "gen":
        toc, n = gen(args[0])
        print(toc); print(f"\n({n} mục)", file=sys.stderr)
    elif cmd == "check":
        fail = 0
        for f in args:
            bad = check(f)
            if bad is None:
                continue
            if bad:
                fail = 1
                print(f"✗ {f}")
                for b in bad:
                    print(f"    link hỏng: #{b}")
            else:
                print(f"✓ {f}")
        sys.exit(fail)
    else:
        print(__doc__); sys.exit(1)
