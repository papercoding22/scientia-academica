#!/usr/bin/env python3
"""
slides-to-md.py — Dựng bộ đệm text cho PDF trong materials/ để grep trước khi Read.

    scripts/slides-to-md.py                    Mọi môn, mọi học kỳ
    scripts/slides-to-md.py --course IT007     Chỉ một môn
    scripts/slides-to-md.py --force            Dựng lại cả file chưa đổi

Kết quả: .cache/md/<đường dẫn gốc>.md (gitignore), mỗi trang một mục "## Trang N".
materials/ không bị ghi gì — đó là thư mục chỉ đọc (AGENTS.md § 8b).
File không đổi từ lần dựng trước thì bỏ qua.

Cách dùng bộ đệm:
    grep -rn -i "thrashing" .cache/md/semesters/*/IT007-*/
    → biết file + trang → Read đúng trang đó trong PDF gốc.
Trang gắn "⚠️ chủ yếu là hình" thì bộ đệm vô dụng — phải Read để xem sơ đồ.
"""
import sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts" / "lib"))
import doc2md  # noqa: E402

CACHE = ROOT / ".cache" / "md"


def main(args):
    course = args[args.index("--course") + 1] if "--course" in args else None
    force = "--force" in args
    if not doc2md.tool_python():
        sys.exit(f"✗ {doc2md.INSTALL_HINT}")

    pdfs = sorted(p for p in (ROOT / "semesters").glob("*/*/materials/**/*.pdf")
                  if not course or p.relative_to(ROOT).parts[2].startswith(course + "-"))
    if not pdfs:
        sys.exit(f"✗ không tìm thấy PDF nào trong materials/{' của ' + course if course else ''}")

    built = skipped = failed = 0
    for pdf in pdfs:
        rel = pdf.relative_to(ROOT)
        out = CACHE / rel.with_suffix(".md")
        if not force and out.exists() and out.stat().st_mtime >= pdf.stat().st_mtime:
            skipped += 1
            continue
        md, err = doc2md.run("pdf", pdf)
        if err:
            print(f"   ✗ {rel}: {err}")
            failed += 1
            continue
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(md, encoding="utf-8")
        warn = next((l for l in md.splitlines() if l.startswith("> ⚠️")), "")
        print(f"   ✓ {rel.name}{'  ' + warn[2:] if warn else ''}")
        built += 1

    print(f"\n{built} dựng · {skipped} không đổi · {failed} lỗi → {CACHE.relative_to(ROOT)}/")


if __name__ == "__main__":
    if "-h" in sys.argv or "--help" in sys.argv:
        print(__doc__); sys.exit(0)
    main(sys.argv[1:])
