#!/usr/bin/env python3
"""
Kiểm chứng các giải thuật loại trừ tương hỗ (Dekker, Peterson, Bakery, Test&Set)
bằng cách duyệt MỌI lịch xen kẽ (model checking) — L05, mục 3–4.

Mỗi tiến trình vào critical section đúng MỘT lần rồi thôi. Với mỗi giải thuật in ra:
  - số trạng thái đã duyệt
  - số trạng thái vi phạm mutual exclusion (hai tiến trình cùng ở CS)
  - số trạng thái kẹt (deadlock: chưa xong mà không ai đi tiếp được)

Giả định của mô hình: load/store là đơn nguyên và thứ tự thực thi là tuần tự.
Trên CPU thật, các phép gán có thể bị sắp xếp lại (memory reordering) nên
kết quả ở đây KHÔNG bảo đảm cho máy thật — đó là lý do mục 5 cần memory barrier.

Chạy:  python3 mutex-model-check.py
"""
from collections import deque


def explore(init, step, n, name):
    seen, q = {init}, deque([init])
    me = dead = 0
    while q:
        s = q.popleft()
        pcs = s[-1]
        if sum(p == "CS" for p in pcs) > 1:
            me += 1
        nxt = [t for i in range(n) if pcs[i] != "DONE" for t in step(s, i)]
        if not nxt and any(p != "DONE" for p in pcs):
            dead += 1
        for t in nxt:
            if t not in seen:
                seen.add(t)
                q.append(t)
    print(f"{name:34s} trạng thái={len(seen):6d}  vi phạm ME={me}  kẹt={dead}")


def result(s, ns):
    return [] if ns == s else [ns]        # bỏ bước "quay tại chỗ" (busy waiting)


# ---------- Dekker (2 tiến trình) ----------
def dekker(s, i):
    f0, f1, turn, pcs = s
    f, pcs, j, pc = [f0, f1], list(s[3]), 1 - i, s[3][i]
    if   pc == "S0":    f[i] = True;  pcs[i] = "T"
    elif pc == "T":     pcs[i] = "CS" if not f[j] else "IFT"        # while (flag[j])
    elif pc == "IFT":   pcs[i] = "LOW" if turn == j else "T"        # if (turn == j)
    elif pc == "LOW":   f[i] = False; pcs[i] = "WAIT"               # hạ cờ, lùi
    elif pc == "WAIT":  pcs[i] = "RAISE" if turn != j else "WAIT"   # while (turn == j);
    elif pc == "RAISE": f[i] = True;  pcs[i] = "T"
    elif pc == "CS":    pcs[i] = "TURN"
    elif pc == "TURN":  turn = j;     pcs[i] = "CLR"                # ra khỏi CS: trao lượt
    elif pc == "CLR":   f[i] = False; pcs[i] = "DONE"
    return result(s, (f[0], f[1], turn, tuple(pcs)))


# ---------- Peterson (2 tiến trình) ----------
def peterson(s, i):
    f0, f1, turn, pcs = s
    f, pcs, j, pc = [f0, f1], list(s[3]), 1 - i, s[3][i]
    if   pc == "S0": f[i] = True; pcs[i] = "S1"
    elif pc == "S1": turn = j;    pcs[i] = "W"
    elif pc == "W":  pcs[i] = "CS" if not (f[j] and turn == j) else "W"
    elif pc == "CS": pcs[i] = "X"
    elif pc == "X":  f[i] = False; pcs[i] = "DONE"
    return result(s, (f[0], f[1], turn, tuple(pcs)))


# ---------- Bakery (n tiến trình) ----------
def bakery(n, use_choosing=True):
    def step(s, i):
        ch, num, loc, pcs = map(list, s)
        pc = pcs[i]
        if pc == "S0":
            if use_choosing: ch[i] = True
            pcs[i], loc[i] = ("RD", 0), 0
        elif isinstance(pc, tuple) and pc[0] == "RD":            # đọc từng number[k]
            k = pc[1]; loc[i] = max(loc[i], num[k])
            pcs[i] = ("RD", k + 1) if k + 1 < n else "SETN"
        elif pc == "SETN": num[i] = 1 + loc[i]; pcs[i] = "CLR"
        elif pc == "CLR":
            if use_choosing: ch[i] = False
            pcs[i] = ("W1", 0)
        elif isinstance(pc, tuple) and pc[0] == "W1":            # while (choosing[k]);
            k = pc[1]; pcs[i] = ("W2", k) if not ch[k] else pc
        elif isinstance(pc, tuple) and pc[0] == "W2":            # while (num[k] != 0 && (num[k],k) < (num[i],i));
            k = pc[1]
            if num[k] == 0 or not ((num[k], k) < (num[i], i)):
                pcs[i] = ("W1", k + 1) if k + 1 < n else "CS"
        elif pc == "CS":   pcs[i] = "EXIT"
        elif pc == "EXIT": num[i] = 0; pcs[i] = "DONE"
        return result(s, (tuple(ch), tuple(num), tuple(loc), tuple(pcs)))
    return step


# ---------- Test & Set lock (n tiến trình) ----------
def test_and_set(s, i):
    lock, pcs = s
    pcs, pc = list(pcs), pcs[i]
    if pc == "S0":                       # test_and_set(&lock) — MỘT bước nguyên tử
        old, lock = lock, True
        pcs[i] = "CS" if not old else "S0"
    elif pc == "CS": pcs[i] = "X"
    elif pc == "X":  lock = False; pcs[i] = "DONE"
    return result(s, (lock, tuple(pcs)))


if __name__ == "__main__":
    explore((False, False, 0, ("S0",) * 2), dekker, 2, "Dekker (2)")
    explore((False, False, None, ("S0",) * 2), peterson, 2, "Peterson (2)")
    for n in (2, 3):
        init = ((False,) * n, (0,) * n, (0,) * n, ("S0",) * n)
        explore(init, bakery(n), n, f"Bakery ({n})")
    explore(((False,) * 2, (0,) * 2, (0,) * 2, ("S0",) * 2), bakery(2, False), 2,
            "Bakery (2) — BỎ choosing[]")
    for n in (2, 3):
        explore((False, ("S0",) * n), test_and_set, n, f"Test&Set lock ({n})")
