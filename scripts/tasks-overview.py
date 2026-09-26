#!/usr/bin/env python3
"""
tasks-overview.py — Xếp lại task trong admin/tasks-<kỳ>.md theo trạng thái và ngày.

    scripts/tasks-overview.py                      Xếp lại mọi admin/tasks-*.md
    scripts/tasks-overview.py admin/tasks-2025-2026-S3.md
    scripts/tasks-overview.py --today 2026-09-27 <file>   Tính theo một ngày chốt khác
    scripts/tasks-overview.py --print <file>       Chỉ in ra, không ghi file

File task của học kỳ CHỈ gồm các nhóm dưới đây. Mỗi dòng là một task — sửa Trạng thái / Hạn
ngay trên dòng (ở nhóm nào cũng được), thêm task mới vào nhóm 1, rồi chạy script:

    1. Sẽ làm        chưa bắt đầu, chưa tới hạn (kể cả hạn ❓) · kỳ thi chưa diễn ra
    2. Đang làm      Trạng thái 🔄, chưa quá hạn
    3. Trễ tiến độ   quá hạn mà chưa ✅, hoặc Trạng thái ⚠️ (kỳ thi không bao giờ vào đây)
    4. Quan trọng    BẢNG XEM, tự sinh — kỳ thi · hạn giảng viên ≤ 7 ngày · hạn hôm nay/ngày mai
    5. Đã xong       Trạng thái ✅ · kỳ thi đã qua

Script tính lại cột "Còn lại", chuyển dòng sang đúng nhóm, sắp theo hạn, sinh lại nhóm 4.
Mọi cột khác giữ nguyên chữ người dùng viết.
"""
import argparse, datetime as dt, pathlib, re, sys

REPO = pathlib.Path(__file__).resolve().parents[1]
START = "<!-- tasks:start — sửa dòng thoải mái, rồi chạy scripts/tasks-overview.py để xếp lại nhóm -->"
END = "<!-- tasks:end -->"
IMPORTANT_DAYS = 7  # hạn giảng viên còn ≤ N ngày thì vào nhóm "Quan trọng"
WEEKDAY = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]

COLS = ["Hạn", "Còn lại", "Môn", "Loại", "Việc", "Trạng thái", "Khoá", "Ghi chú"]
GROUPS = [
    ("todo", "1. Sẽ làm", "Chưa bắt đầu, chưa tới hạn (kể cả hạn ❓) · kỳ thi chưa diễn ra. **Thêm task mới vào đây.**"),
    ("doing", "2. Đang làm", "Trạng thái `🔄`, chưa quá hạn."),
    ("late", "3. Trễ tiến độ", "Quá hạn mà chưa `✅`, hoặc Trạng thái `⚠️`."),
    ("notable", "4. Quan trọng, đáng chú ý",
     f"**Chỉ để xem — tự sinh, đừng sửa ở đây.** Kỳ thi sắp tới · hạn giảng viên còn ≤ {IMPORTANT_DAYS} ngày · "
     "hạn hôm nay/ngày mai. Task vẫn nằm ở nhóm 1–3."),
    ("done", "5. Đã xong", "Trạng thái `✅` · kỳ thi đã qua. Giữ làm lịch sử — không xoá dòng."),
]


# ── đọc ─────────────────────────────────────────────────────────────────────
def cells(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def parse_rows(block):
    """Mọi dòng task trong các bảng của nhóm 1, 2, 3, 5 (bỏ qua bảng xem của nhóm 4)."""
    rows, head, group = [], None, None
    for line in block.splitlines():
        m = re.match(r"^## (\d)\.", line)
        if m:
            group, head = m.group(1), None
            continue
        if not line.lstrip().startswith("|"):
            head = None
            continue
        if group == "4":
            continue
        vals = cells(line)
        if head is None:
            head = vals
        elif not all(re.fullmatch(r":?-+:?", v) for v in vals if v):
            row = dict(zip(head, vals + [""] * (len(head) - len(vals))))
            if row.get("Việc"):
                rows.append({c: row.get(c, "") for c in COLS})
    return rows


# ── suy ra ngày giờ, nhóm ───────────────────────────────────────────────────
def when(text):
    """Ngày (+ giờ nếu có) trong ô → (datetime, có giờ?); không có ngày → (None, False)."""
    d = re.search(r"(\d{4})-(\d{2})-(\d{2})", text)
    if not d:
        return None, False
    t = re.search(r"(?<![\d-])(\d{1,2}):(\d{2})", text[d.end():])
    y, mo, da = map(int, d.groups())
    if t:
        return dt.datetime(y, mo, da, int(t.group(1)), int(t.group(2))), True
    return dt.datetime(y, mo, da, 23, 59), False


def fmt(moment, has_time):
    s = f"{WEEKDAY[moment.weekday()]} {moment:%Y-%m-%d}"
    return f"{s} {moment:%H:%M}" if has_time else s


def days_left(moment, now):
    n = (moment.date() - now.date()).days
    return "hôm nay" if n == 0 else f"còn {n} ngày" if n > 0 else f"quá {-n} ngày"


def is_exam(row):
    return row["Loại"].strip().lower() == "thi"


def classify(row, now):
    at, _ = when(row["Hạn"])
    if is_exam(row):
        return "done" if at and at < now else "todo"
    status = row["Trạng thái"]
    if "✅" in status:
        return "done"
    if "⚠️" in status or (at and at < now):
        return "late"
    if "🔄" in status:
        return "doing"
    return "todo"


def notable(row, now):
    """Lý do đáng chú ý, hoặc None."""
    at, _ = when(row["Hạn"])
    if not at or at < now or "✅" in row["Trạng thái"]:
        return None
    left = (at.date() - now.date()).days
    if is_exam(row):
        return "kỳ thi"
    if row["Loại"].strip().lower() == "hạn nộp" and left <= IMPORTANT_DAYS:
        return "hạn giảng viên"
    if left <= 1:
        return "hạn hôm nay/ngày mai"
    return None


def normalize(row, now, group):
    at, has_time = when(row["Hạn"])
    row = dict(row)
    if at:
        row["Hạn"] = fmt(at, has_time)
        row["Còn lại"] = ("đã thi" if is_exam(row) else "—") if group == "done" else days_left(at, now)
    else:
        row["Còn lại"] = "—"
    return row


# ── dựng ────────────────────────────────────────────────────────────────────
def sort_key(row, newest_first=False):
    """Theo hạn; hạn ❓ luôn xếp cuối. Nhóm Đã xong: mới nhất lên đầu."""
    at, _ = when(row["Hạn"])
    stamp = at.timestamp() if at else 0
    return (at is None, -stamp if newest_first else stamp, row["Môn"], row["Việc"])


def table(rows, cols):
    out = ["| " + " | ".join(cols) + " |", "|" + "---|" * len(cols)]
    out += ["| " + " | ".join(r.get(c, "") for c in cols) + " |" for r in rows]
    return out


def build(block, now):
    groups = {key: [] for key, *_ in GROUPS}
    for row in parse_rows(block):
        g = classify(row, now)
        groups[g].append(normalize(row, now, g))
    for key in groups:
        groups[key].sort(key=lambda r: sort_key(r, newest_first=(key == "done")))
    marked = []
    for key in ("todo", "doing", "late"):
        for row in groups[key]:
            why = notable(row, now)
            if why:
                marked.append(dict(row, **{"Vì sao": why}))
    marked.sort(key=sort_key)

    out = [START, "", f"> Xếp lại ngày **{now:%Y-%m-%d}**. *Còn lại* và nhóm của từng dòng tính theo ngày này.", ""]
    for key, title, desc in GROUPS:
        out += [f"## {title}", "", desc, ""]
        if key == "notable":
            cols = ["Hạn", "Còn lại", "Môn", "Loại", "Việc", "Vì sao"]
            out += table(marked, cols) if marked else ["Không có."]
        else:
            out += table(groups[key], COLS)
        out += ["", "---", ""]
    out = out[:-3] + ["", END]
    return "\n".join(out)


def apply(md, now):
    if START not in md or END not in md:
        sys.exit("Không tìm thấy marker <!-- tasks:start … --> / <!-- tasks:end --> — file tạo từ templates/tasks.md chưa?")
    a, b = md.index(START), md.index(END) + len(END)
    return md[:a] + build(md[a:b], now) + md[b:]


def rel(f):
    try:
        return f.resolve().relative_to(REPO)
    except ValueError:
        return f


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="*")
    ap.add_argument("--today", help="YYYY-MM-DD — mặc định: thời điểm hiện tại")
    ap.add_argument("--print", action="store_true", dest="dry")
    args = ap.parse_args()
    now = dt.datetime.strptime(args.today, "%Y-%m-%d") if args.today else dt.datetime.now()
    files = [pathlib.Path(f) for f in args.files] or sorted((REPO / "admin").glob("tasks-*.md"))
    for f in files:
        md = f.read_text(encoding="utf-8")
        new = apply(md, now)
        if args.dry:
            print(f"── {rel(f)}\n{new}\n")
        elif new != md:
            f.write_text(new, encoding="utf-8")
            print(f"✓ xếp lại: {rel(f)}")
        else:
            print(f"· không đổi: {rel(f)}")


if __name__ == "__main__":
    main()
