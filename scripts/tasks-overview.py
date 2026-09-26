#!/usr/bin/env python3
"""
tasks-overview.py — Sinh mục "Tổng quan" cho admin/tasks-<kỳ>.md từ chính các bảng chi tiết.

    scripts/tasks-overview.py                      Cập nhật mọi admin/tasks-*.md
    scripts/tasks-overview.py admin/tasks-2025-2026-S3.md
    scripts/tasks-overview.py --today 2026-09-27 <file>   Tính theo một ngày chốt khác
    scripts/tasks-overview.py --print <file>       Chỉ in ra, không ghi file

Tổng quan là DỮ LIỆU SUY RA — nguồn vẫn là bảng "Việc và hạn nộp", "Lịch thi",
"Kế hoạch ôn thi" của từng môn. Sửa bảng chi tiết xong thì chạy lại script này,
đừng sửa tay phần giữa hai marker.
"""
import argparse, datetime as dt, pathlib, re, sys

REPO = pathlib.Path(__file__).resolve().parents[1]
START = "<!-- tasks-overview:start — sinh bằng scripts/tasks-overview.py, đừng sửa tay -->"
END = "<!-- tasks-overview:end -->"
IMPORTANT_DAYS = 7  # hạn giảng viên còn ≤ N ngày thì vào nhóm "Quan trọng"
WEEKDAY = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]

# ── đọc file ────────────────────────────────────────────────────────────────
def parse_table(lines):
    """lines bắt đầu từ dòng header của bảng markdown → list[dict]."""
    def cells(line):
        return [c.strip() for c in line.strip().strip("|").split("|")]
    head = cells(lines[0])
    rows = []
    for line in lines[2:]:
        if not line.lstrip().startswith("|"):
            break
        vals = cells(line)
        rows.append(dict(zip(head, vals + [""] * (len(head) - len(vals)))))
    return rows


def parse_courses(md):
    """→ list[{code, heading, tables: {tên ###: rows}}] theo thứ tự trong file."""
    courses, cur, sub = [], None, None
    lines = md.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        m = re.match(r"^## ([A-Z]{2}\d{3}) — (.+)$", line)
        if m:
            cur = {"code": m.group(1), "heading": line[3:].strip(), "tables": {}}
            courses.append(cur)
            sub = None
        elif line.startswith("## "):
            cur, sub = None, None
        elif cur and line.startswith("### "):
            sub = line[4:].strip()
        elif cur and sub and line.lstrip().startswith("|") and sub not in cur["tables"]:
            block = []
            while i < len(lines) and lines[i].lstrip().startswith("|"):
                block.append(lines[i])
                i += 1
            cur["tables"][sub] = parse_table(block)
            continue
        i += 1
    return courses


# ── suy ra ngày giờ, trạng thái ─────────────────────────────────────────────
def when(*texts):
    """Ngày (+ giờ nếu có) trong các ô → datetime; không có ngày → None."""
    joined = " ".join(texts)
    d = re.search(r"(\d{4})-(\d{2})-(\d{2})", joined)
    if not d:
        return None, False
    t = re.search(r"(?<![\d-])(\d{1,2}):(\d{2})", joined)
    y, mo, da = map(int, d.groups())
    if t:
        return dt.datetime(y, mo, da, int(t.group(1)), int(t.group(2))), True
    return dt.datetime(y, mo, da, 23, 59), False


def fmt(moment, has_time):
    s = f"{WEEKDAY[moment.weekday()]} {moment:%Y-%m-%d}"
    return f"{s} {moment:%H:%M}" if has_time else s


def plain(text):
    """Bỏ link, in đậm, backtick — giữ chữ để hiện gọn trong bảng tổng quan."""
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    return re.sub(r"[*`]", "", text).strip()


def done(status):
    return "✅" in status


def items(course):
    """Mọi việc có thể có hạn của một môn → list[dict]."""
    out = []
    for row in course["tables"].get("Việc và hạn nộp", []):
        if not row.get("Việc"):
            continue
        moment, has_time = when(row.get("Hạn", ""))
        out.append(dict(kind="Hạn nộp", name=plain(row["Việc"]), at=moment, has_time=has_time,
                        status=row.get("Trạng thái", ""), done=done(row.get("Trạng thái", ""))))
    for row in course["tables"].get("Lịch thi", []):
        loai = row.get("Loại", "")
        if loai.startswith("~~"):
            continue
        moment, has_time = when(row.get("Ngày", ""), row.get("Giờ", ""))
        out.append(dict(kind="Thi", name="Thi " + plain(loai).replace("❓", "").strip().lower(),
                        at=moment, has_time=has_time, status="", done=False, exam=True))
    for row in course["tables"].get("Kế hoạch ôn thi", []):
        if not row.get("Buổi ôn"):
            continue
        moment, has_time = when(row.get("Hạn", ""))
        out.append(dict(kind="Ôn thi", name=plain(row["Buổi ôn"]), at=moment, has_time=has_time,
                        status=row.get("Trạng thái", ""), done=done(row.get("Trạng thái", "")), review=True))
    return out


# ── dựng mục Tổng quan ──────────────────────────────────────────────────────
def days_left(moment, now):
    n = (moment.date() - now.date()).days
    return "hôm nay" if n == 0 else f"còn {n} ngày" if n > 0 else f"quá {-n} ngày"


def classify(x, now):
    """Nhóm 1–3, mỗi task đúng một nhóm: trễ tiến độ > đang làm > sẽ làm. Thi không phải task."""
    if x["done"] or x.get("exam"):
        return None
    if "⚠️" in x["status"] or (x["at"] and x["at"] < now):
        return "late"
    if "🔄" in x["status"]:
        return "doing"
    return "todo"


def notable(x, now):
    """Nhóm 4 — lý do đáng chú ý, hoặc None. Có thể trùng với nhóm 1–3."""
    if x["done"] or not x["at"] or x["at"] < now:
        return None
    left = (x["at"].date() - now.date()).days
    if x.get("exam"):
        return "kỳ thi"
    if x["kind"] == "Hạn nộp" and left <= IMPORTANT_DAYS:
        return "hạn giảng viên"
    if left <= 1:
        return "hạn hôm nay/ngày mai"
    return None


def table(entries, now, extra=None):
    if not entries:
        return ["Không có."]
    entries.sort(key=lambda e: (e[1]["at"] is None, e[1]["at"] or dt.datetime.max))
    head = "| Hạn | Còn lại | Môn | Loại | Việc |" + (f" {extra} |" if extra else "")
    rows = [head, "|---|---|---|---|---|" + ("---|" if extra else "")]
    for code, x, *more in entries:
        at = fmt(x["at"], x["has_time"]) if x["at"] else "❓"
        left = days_left(x["at"], now) if x["at"] else "—"
        rows.append(f"| {at} | {left} | {code} | {x['kind']} | {x['name']} |" + (f" {more[0]} |" if extra else ""))
    return rows


def build(md, now):
    groups = {"todo": [], "doing": [], "late": []}
    marked = []
    for c in parse_courses(md):
        for x in items(c):
            g = classify(x, now)
            if g:
                groups[g].append((c["code"], x))
            why = notable(x, now)
            if why:
                marked.append((c["code"], x, why))

    out = [START, "",
           f"> Tính ngày **{now:%Y-%m-%d}** từ các bảng chi tiết bên dưới. Sửa bảng chi tiết xong thì chạy",
           "> `scripts/tasks-overview.py` — không sửa tay phần này.", "",
           f"**1. Sẽ làm** — chưa bắt đầu, chưa tới hạn ({len(groups['todo'])})", "",
           *table(groups["todo"], now), "",
           f"**2. Đang làm** ({len(groups['doing'])})", "",
           *table(groups["doing"], now), "",
           f"**3. Trễ tiến độ** — quá hạn mà chưa xong ({len(groups['late'])})", "",
           *table(groups["late"], now), "",
           f"**4. Quan trọng, đáng chú ý** — kỳ thi · hạn giảng viên ≤ {IMPORTANT_DAYS} ngày · hạn hôm nay/ngày mai", "",
           *table(marked, now, extra="Vì sao"), "",
           END]
    return "\n".join(out)


# ── ghi vào file ────────────────────────────────────────────────────────────
def apply(md, section):
    if START in md and END in md:
        a, b = md.index(START), md.index(END) + len(END)
        return md[:a] + section + md[b:]
    # Chưa có mục: chèn "## Tổng quan" ngay sau mục "## Mốc học kỳ"
    m = re.search(r"^## Mốc học kỳ\n.*?(?=^---\n)", md, flags=re.S | re.M)
    if not m:
        sys.exit("Không tìm thấy mục '## Mốc học kỳ' để chèn Tổng quan sau nó.")
    md = md[:m.end()] + "---\n\n## Tổng quan\n\n" + section + "\n\n" + md[m.end():]
    toc_line = "- [Mốc học kỳ](#mốc-học-kỳ)\n"
    if toc_line in md and "- [Tổng quan](#tổng-quan)" not in md:
        md = md.replace(toc_line, toc_line + "- [Tổng quan](#tổng-quan)\n", 1)
    return md


def rel(f):
    try:
        return f.resolve().relative_to(REPO)
    except ValueError:
        return f


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="*")
    ap.add_argument("--today", help="YYYY-MM-DD — mặc định: ngày hiện tại")
    ap.add_argument("--print", action="store_true", dest="dry")
    args = ap.parse_args()
    now = dt.datetime.strptime(args.today, "%Y-%m-%d") if args.today else dt.datetime.now()
    files = [pathlib.Path(f) for f in args.files] or sorted((REPO / "admin").glob("tasks-*.md"))
    for f in files:
        md = f.read_text(encoding="utf-8")
        section = build(md, now)
        if args.dry:
            print(f"── {f}\n{section}\n")
            continue
        new = apply(md, section)
        if new != md:
            f.write_text(new, encoding="utf-8")
            print(f"✓ cập nhật tổng quan: {rel(f)}")
        else:
            print(f"· không đổi: {rel(f)}")


if __name__ == "__main__":
    main()
