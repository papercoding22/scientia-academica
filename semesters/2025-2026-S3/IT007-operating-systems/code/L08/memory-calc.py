#!/usr/bin/env python3
"""
Máy tính nhỏ cho chương 7 — Quản lý bộ nhớ (note L08).

  python3 memory-calc.py translate <logical_addr> <page_size> <page_table>
      vd: python3 memory-calc.py translate 5000 2048 "5,3,7,1"
  python3 memory-calc.py eat <memory_access_ns> <hit_ratio> [tlb_lookup_ns]
      vd: python3 memory-calc.py eat 100 0.8 20
  python3 memory-calc.py place "<khối trống>" "<tiến trình>"
      vd: python3 memory-calc.py place "600,500,200,300" "212,417,112,426"
  python3 memory-calc.py bits <số trang> <page_size> <số frame>
      vd: python3 memory-calc.py bits 12 2048 32

Không tham số: chạy các ví dụ trong slide.
"""
import math
import sys


def translate(addr, page_size, table):
    p, d = divmod(addr, page_size)                     # tách page number và offset
    if p >= len(table):
        return f"logical {addr}: p={p} vượt bảng trang ({len(table)} mục) → trap: địa chỉ không hợp lệ"
    f = table[p]
    return f"logical {addr}: p={p}, d={d} → frame {f} → physical {f} × {page_size} + {d} = {f * page_size + d}"


def eat(x, alpha, eps=0.0):
    hit, miss = eps + x, eps + 2 * x                   # hit: TLB + 1 lần RAM; miss: TLB + bảng trang + dữ liệu
    return f"EAT = {alpha}×{hit:g} + {1 - alpha:g}×{miss:g} = (2 − {alpha})×{x:g} + {eps:g} = {(2 - alpha) * x + eps:g} ns"


def place(holes, procs):
    out = []
    for name in ("first", "best", "next", "worst"):
        free, last, rows = holes[:], 0, []
        for p in procs:
            fit = [i for i, h in enumerate(free) if h >= p]
            if not fit:
                rows.append(f"{p}K→chờ")
                continue
            if name == "first":
                i = fit[0]
            elif name == "best":
                i = min(fit, key=lambda k: free[k])
            elif name == "worst":
                i = max(fit, key=lambda k: free[k])
            else:                                       # next-fit: quét từ khối cấp gần nhất
                i = next(k % len(free) for k in range(last, last + len(free)) if free[k % len(free)] >= p)
            free[i] -= p
            last = i
            rows.append(f"{p}K→{holes[i]}K")
        out.append(f"{name:>5}-fit: {', '.join(rows):42s} còn trống {free}")
    return "\n".join(out)


def bits(pages, page_size, frames):
    n = int(math.log2(page_size))
    return (f"offset {n} bit · page number {math.ceil(math.log2(pages))} bit → logical "
            f"{math.ceil(math.log2(pages)) + n} bit · frame number {math.ceil(math.log2(frames))} bit → physical "
            f"{math.ceil(math.log2(frames)) + n} bit")


if __name__ == "__main__":
    a = sys.argv[1:]
    if not a:
        print("[C7 s46]", translate(0b0000010111011110, 1024, [5, 6, 3]))
        print("[C7 s54]", eat(100, 0.8, 20))
        print("[C7 s54]", eat(100, 0.98, 20))
        print("[C7 s68]", bits(12, 2048, 32))
        print("[C7 s69]", eat(200, 0.75, 0))
        print("[C7 s67]\n" + place([600, 500, 200, 300], [212, 417, 112, 426]))
    elif a[0] == "translate":
        print(translate(int(a[1]), int(a[2]), [int(x) for x in a[3].split(",")]))
    elif a[0] == "eat":
        print(eat(float(a[1]), float(a[2]), float(a[3]) if len(a) > 3 else 0.0))
    elif a[0] == "place":
        print(place([int(x) for x in a[1].split(",")], [int(x) for x in a[2].split(",")]))
    elif a[0] == "bits":
        print(bits(int(a[1]), int(a[2]), int(a[3])))
