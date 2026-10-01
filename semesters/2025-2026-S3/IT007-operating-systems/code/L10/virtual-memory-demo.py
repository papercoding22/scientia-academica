#!/usr/bin/env python3
"""Mô hình học tập cho L10; không đo page fault thật của hệ điều hành.

Python 3.9+, chỉ dùng stdlib. Chạy --help để chọn ví dụ.
"""

import argparse
from fractions import Fraction


SLIDE_EXAMPLE = [7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1]
SLIDE_EXERCISE = [1, 2, 3, 4, 2, 1, 5, 6, 2, 1, 2, 3, 7, 6, 3, 2, 1]
BELADY = [1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5]
EXAM_LRU = [1, 3, 2, 4, 5, 4, 0, 1, 7, 4, 1, 3, 2, 7, 1, 3, 5, 2]


def simulate(refs, capacity, policy):
    """Giữ nguyên vị trí frame; None là ô trống, page 0 vẫn hợp lệ.

    Tất cả frame ban đầu rỗng. Nếu OPT có nhiều victim đồng hạng,
    chọn frame có chỉ số nhỏ nhất. Không mô phỏng thời gian I/O/dirty bit.
    """
    if capacity < 1 or policy not in ("FIFO", "OPT", "LRU"):
        raise ValueError("Cần capacity >= 1 và policy FIFO/OPT/LRU")
    if any(page is None for page in refs):
        raise ValueError("None dành cho frame trống")
    frames = [None] * capacity
    loaded, last_used, rows = {}, {}, []
    faults = 0
    for step, page in enumerate(refs, 1):
        hit = page in frames
        victim = None
        if not hit:
            faults += 1
            if None in frames:
                slot = frames.index(None)
            else:
                if policy == "FIFO":
                    victim = min(frames, key=loaded.get)
                elif policy == "LRU":
                    victim = min(frames, key=last_used.get)
                else:
                    future = refs[step:]
                    victim = max(frames, key=lambda p:
                                 future.index(p) if p in future else float("inf"))
                slot = frames.index(victim)
            frames[slot] = page
            loaded[page] = step  # FIFO chỉ đổi thứ tự khi nạp.
        last_used[page] = step  # LRU cập nhật cả khi hit.
        rows.append((step, page, tuple(frames), hit, victim, faults))
    return rows


def working_set(refs, t, window):
    """Tập page phân biệt trong window tham chiếu kết thúc tại bước t (từ 1)."""
    if not 1 <= t <= len(refs) or window < 1:
        raise ValueError("Cần 1 <= t <= len(refs), window >= 1")
    return set(refs[max(0, t - window):t])


def overview():
    pages = {0, 1, 2, 3}
    rows = simulate([0, 1, 0], 2, "LRU")
    resident = set(rows[-1][2]) - {None}
    print("Page của process:", sorted(pages))
    print("Page đang ở RAM:", sorted(resident))
    print("Chưa nạp:", sorted(pages - resident))
    print("Fault:", rows[-1][-1], "| Hit:", sum(row[3] for row in rows))


def algorithms():
    for label, refs, capacity in [
        ("C8 s24–32", SLIDE_EXAMPLE, 3),
        ("C8 s49", SLIDE_EXERCISE, 4),
    ]:
        counts = [f"{p}={simulate(refs, capacity, p)[-1][-1]}"
                  for p in ("FIFO", "OPT", "LRU")]
        print(label + ": " + ", ".join(counts))
    print("Belady FIFO:", ", ".join(
        f"{n} frame={simulate(BELADY, n, 'FIFO')[-1][-1]}" for n in (3, 4)))
    rows = simulate(EXAM_LRU, 4, "LRU")
    first_seven = next(row for row in rows if row[1] == 7)
    print(f"Đề mẫu C22: LRU={rows[-1][-1]}, victim lần đầu gặp 7={first_seven[4]}")


def allocation():
    sizes, total_frames = [2, 4], 12
    shares = [Fraction(size * total_frames, sum(sizes)) for size in sizes]
    print("m=12, s=[2, 4] → a=" + str([int(a) for a in shares]))
    shares = [Fraction(size * 64, 137) for size in [10, 127]]
    print("C8 s37, giá trị trước khi làm tròn:",
          ", ".join(f"{float(a):.4f}" for a in shares))


def locality():
    refs = [1, 2, 1, 3, 2, 4]
    for t in (4, 5, 6):
        ws = working_set(refs, t, 4)
        print(f"t={t}, Δ=4: WS={sorted(ws)}, WSS={len(ws)}")
    for capacity in (2, 3):
        rows = simulate([1, 2, 3, 1, 2, 3], capacity, "LRU")
        print(f"LRU, chuỗi 1 2 3 1 2 3, {capacity} frame: {rows[-1][-1]} fault")
    print("WSS=[3, 4], m=6 → D=7 > 6")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("demo", choices=["all", "overview", "algorithms", "allocation", "working-set"],
                        nargs="?", default="all")
    parser.add_argument("--trace", choices=["FIFO", "OPT", "LRU"],
                        help="In từng frame của bài C8 s49, 4 frame rỗng ban đầu")
    args = parser.parse_args()
    if args.trace:
        print("Bước | Page | Frames | H/F | Victim | Fault lũy kế")
        for step, page, frames, hit, victim, faults in simulate(SLIDE_EXERCISE, 4, args.trace):
            print(step, page, frames, "H" if hit else "F", victim, faults, sep=" | ")
        return
    demos = {"overview": overview, "algorithms": algorithms,
             "allocation": allocation, "working-set": locality}
    for name, run in demos.items():
        if args.demo in ("all", name):
            run()


if __name__ == "__main__":
    main()
