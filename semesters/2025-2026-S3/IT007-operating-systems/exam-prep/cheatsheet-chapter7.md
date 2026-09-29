# IT007 — Cheatsheet Chương 7: Quản lý bộ nhớ

> Chắt lọc từ [guide Chương 7](chapter7-exam-study-guide.md) để xem nhanh trước giờ thi. Giải thích đầy đủ nằm trong guide.
> Đáp án là **suy luận**, vì đề mẫu không có đáp án chính thức. `[C7 s44]` = slide C7, trang PDF 44.

---

## Dịch logical address sang physical address (Paging) — câu 20

**Công thức** (địa chỉ tính theo byte, page/frame đánh số từ 0, `P` = page size = frame size) [C7 s44–s45]

```text
p = floor(L / P)      d = L mod P        ← tách page number và offset
f = pageTable[p]                         ← TRA BẢNG, không tính
physical = f × P + d                     ← offset giữ nguyên
```

**4 bước làm bài**
1. Đổi page size ra byte: `1 KB = 1024`, `2 KB = 2048`, `4 KB = 4096`.
2. Chia `L` cho `P`: thương là `p`, số dư là `d`.
3. Tra dòng **Page = p** trong bảng để lấy `f`.
4. Ghép `f × P + d`, rồi kiểm tra kết quả.

**Đề mẫu câu 20:** frame 2 KB, `L = 7654`, bảng `0→5, 1→3, 2→4, 3→2` [Đề tr5, C20]

| Bước | Tính | Kết quả |
|---|---|---|
| Tách | `7654 = 3 × 2048 + 1510` | `p = 3`, `d = 1510` |
| Tra bảng | page 3 → frame 2 | `f = 2` |
| Ghép | `2 × 2048 + 1510` | **5606** → **A** |

**Kiểm tra (30 giây)**
- `physical mod P` phải bằng `L mod P` (ở đây cả hai đều là `1510`).
- `f × P ≤ physical < (f + 1) × P` (ở đây `4096 ≤ 5606 < 6144`).

**Bẫy**

| Làm sai | Ra phương án | Nhận ra vì |
|---|---|---|
| Chỉ lấy offset `d` | **D** — 1510 | Quên cộng địa chỉ đầu frame |
| Tra nhầm dòng (page 2 → frame 4) | **B** — `4 × 2048 + 1510` = 9702 | Offset đúng nhưng frame sai, nên soát lại dòng vừa tra |
| Dùng page number làm frame và bỏ offset | **C** — `3 × 2048` = 6144 | Kết quả chia hết cho `P`, mất phần `d` |
| Dùng page number làm frame, giữ offset | 7654 | Kết quả bằng đúng logical address, tức là chưa tra bảng |
| Dùng `2 KB = 2000` | lệch số | Bài bộ nhớ dùng lũy thừa 2 |

> ⚠️ Bảng cho **Page → Frame**. Đọc cột Page để tìm dòng, lấy số ở cột Frame. Đừng đọc ngược chiều.
