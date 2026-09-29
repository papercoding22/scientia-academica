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

---

## Kích thước bảng trang (Page table size) — câu 21b

**Công thức** (bảng trang một cấp đầy đủ: mỗi **logical page** có một entry) [C7 s44]

```text
số entry   = N = số logical page        ← KHÔNG phải số frame
           = 2^(m − n)                  ← khi đề chỉ cho m bit logical address, page size 2^n byte
tableBytes = N × entryBytes             ← entryBytes lấy đúng số đề cho
```

**4 bước làm bài**
1. Tìm `N`: đề cho sẵn số page thì lấy luôn, đề cho số bit thì tính `2^(m − n)`.
2. Lấy `entryBytes` đúng như đề cho, không tự tính lại từ số frame.
3. Nhân `N × entryBytes` và ghi **đơn vị byte**.
4. Kiểm tra lại: đã dùng số page chứ không phải số frame.

**Đề mẫu câu 21b:** dùng dữ kiện câu 21: **256 page**, mỗi page 4096 byte, **64 frame**, mỗi entry **4 byte** [Đề tr5, C21b]

| Bước | Tính | Kết quả |
|---|---|---|
| Số entry | một entry cho mỗi logical page | `N = 256` |
| Nhân | `256 × 4` | **1024 byte (1 KB)** |

Ghi lên bài tự luận (0,5đ): *"Bảng trang có 1 entry cho mỗi trang → 256 entry. Kích thước = 256 × 4 byte = 1024 byte."*

**Kiểm tra (30 giây)**
- Số page tăng gấp đôi thì bảng phải lớn gấp đôi.
- RAM hay số frame thay đổi thì bảng **không đổi**.
- Kết quả phải là byte, không phải bit, và phải nhỏ hơn nhiều so với không gian địa chỉ.

**Bẫy**

| Làm sai | Ra | Nhận ra vì |
|---|---|---|
| Dùng số frame làm số entry | `64 × 4` = 256 byte | Bảng đánh chỉ số theo **page**, frame chỉ là giá trị lưu trong entry |
| Dùng số địa chỉ byte làm số entry | `2^20 × 4` = 4 MB | Mỗi **trang** có một entry, không phải mỗi byte |
| Lấy kích thước không gian logical | `256 × 4096` = 1 MB | Đó là đáp số của câu hỏi khác (không gian địa chỉ), không phải bảng trang |
| Tự thay entry bằng số bit của frame number | `256 × 6 bit` = 192 byte | Đề đã cho **4 byte cho mỗi entry**, dùng đúng số đó |
| Đổi 4 byte ra bit rồi quên đổi lại | `256 × 32` = 8192 | Đơn vị bị lệch: ra 8192 bit, tức 1024 byte |
