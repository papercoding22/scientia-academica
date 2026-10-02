# IT007 — Cheatsheet Chương 7: Quản lý bộ nhớ

> Chắt lọc từ [guide Chương 7](chapter7-exam-study-guide.md) để xem nhanh trước giờ thi. Giải thích đầy đủ nằm trong guide.
> Đáp án là **suy luận**, vì đề mẫu không có đáp án chính thức. `[C7 s44]` = slide C7, trang PDF 44.

---

## Thời gian truy xuất hiệu dụng (Effective access time — EAT) — câu 3

**Công thức** (page table nằm trong RAM; `ε` = thời gian tra TLB, `x` = một chu kỳ truy xuất bộ nhớ, `α` = hit ratio) [C7 s53]

```text
hit  : ε + x                        ← tra TLB → đọc dữ liệu
miss : ε + 2x                       ← tra TLB → đọc page table → đọc dữ liệu
EAT  = (ε + x)α + (ε + 2x)(1 − α)
     = (2 − α)x + ε                 ← dạng rút gọn trên slide
⇒ ε  = EAT − (2 − α)x               ← giải ngược khi đề hỏi ε
```

**4 bước làm bài**
1. Gạch dưới ẩn số: đề hỏi `ε`, `α`, `x` hay `EAT`.
2. Đổi `α` ra thập phân (`95% = 0,95`), mọi thời gian cùng đơn vị ns.
3. Thế vào `EAT = (2 − α)x + ε` rồi chuyển vế tìm ẩn.
4. Thế ngược vào hai nhánh hit/miss để kiểm tra.

**Đề mẫu câu 3:** `α = 0,95`, `x = 160 ns`, `EAT = 190 ns`, tìm `ε` [Đề tr1, C3]
**Phương án:** A = 30 ns · B = 22 ns · C = 152 ns · D = 320 ns

| Bước | Tính | Kết quả |
|---|---|---|
| Hệ số | `2 − 0,95` | `1,05` |
| Phần RAM | `1,05 × 160` | `168 ns` |
| Giải ngược | `190 − 168` | **ε = 22 ns** → **B** |

**Kiểm tra (30 giây)**
- Hit `22 + 160 = 182`, miss `22 + 320 = 342`; `0,95 × 182 + 0,05 × 342 = 172,9 + 17,1 = 190` ✓
- `ε + x ≤ EAT ≤ ε + 2x` (ở đây `182 ≤ 190 ≤ 342`) và `ε` phải nhỏ hơn nhiều so với `x`.

**Bẫy**

| Làm sai | Ra phương án | Nhận ra vì |
|---|---|---|
| Coi mọi lần đều hit: `ε = EAT − x = 190 − 160` | **A — 30 ns** | Quên lần đọc page table khi miss; thế lại thì EAT ra `190 + 0,05 × 160 = 198` |
| Chỉ tính một số hạng `α·x = 0,95 × 160` rồi dừng | **C — 152 ns** | `ε` lớn gần bằng `x` là vô lý: TLB phải nhanh hơn RAM nhiều |
| Nhầm `ε` với thời gian nhánh miss bỏ TLB: `2x = 2 × 160` | **D — 320 ns** | `ε` lớn hơn cả EAT, thế lại không thể ra 190 |
| Đảo `α` và `1 − α`: `ε = 190 − 1,95 × 160` | `−122 ns` (không có trong A–D) | Thời gian âm là chắc chắn sai |
| Thế `α = 95` | số âm rất lớn | Hit ratio luôn trong `[0, 1]` |
| Cộng thêm thời gian đọc đĩa khi miss | lệch số | TLB miss **không phải** page fault; đề không cho mô hình đĩa |

---

## Chọn phân vùng cố định (Fixed partition placement) — câu 13

**Quy tắc** — một process được cấp **trọn một partition**. [C7 s34, s39; guide mục 2.4]

```text
Ứng viên  = partition trống AND kích thước ≥ yêu cầu   ← phải thỏa cả hai
First-fit = ứng viên đầu tiên khi tìm từ đầu bộ nhớ     ← bỏ qua PC
Best-fit  = ứng viên có kích thước nhỏ nhất             ← không phụ thuộc PC
Next-fit  = ứng viên đầu tiên khi tìm tiếp từ PC        ← quay về đầu nếu tới cuối
Phần dư   = kích thước partition − yêu cầu              ← internal fragmentation, không cấp riêng
```

**4 bước làm bài**

1. Xác định thuật toán, kích thước process và trạng thái từng partition.
2. Loại partition đã cấp phát hoặc nhỏ hơn yêu cầu.
3. Chọn theo quy tắc trên; First-fit/Next-fit dừng ở ứng viên đầu tiên theo thứ tự tìm, Best-fit chọn ứng viên nhỏ nhất.
4. Đánh dấu cả partition đã cấp; tính phần dư, không tách thành hole để cấp tiếp.

**Dữ kiện câu 13:** P cần **220 KB**; vùng 1→6 lần lượt **150, 250, 380, 420, 320, 240 KB**. Vùng 3 đã cấp phát, **PC tại vùng 3**; các vùng khác trống. [Đề tr3, C13]
**Phương án:** A = vùng 2 (250 KB) · B = vùng 1 (150 KB) · C = vùng 4 (420 KB) · D = vùng 6 (240 KB).
**Phạm vi:** đề mẫu hỏi **First-fit**; Best-fit/Next-fit là **biến thể tự luyện từ phiên gia sư 2026-10-01**, giữ nguyên dữ kiện và phương án. Mỗi thuật toán xét **độc lập trên trạng thái ban đầu**.

| Bước | Tính / xét | Kết quả |
|---|---|---|
| Lọc ứng viên | Vùng 1: `150 < 220`; vùng 3: đã cấp | Còn vùng 2, 4, 5, 6 |
| First-fit — đề mẫu | Từ đầu: vùng 1 → vùng 2 đủ; `250 − 220 = 30 KB` | **A — vùng 2; dư 30 KB** |
| Best-fit — tự luyện | `min(250, 420, 320, 240) = 240`; `240 − 220 = 20 KB` | **D — vùng 6; dư 20 KB** |
| Next-fit — tự luyện | PC ở vùng 3 đã cấp → vùng 4 đủ; `420 − 220 = 200 KB` | **C — vùng 4; dư 200 KB** |

**Kiểm tra (30 giây)**

- Vùng chọn phải trống và đủ 220 KB; Best-fit phải không còn ứng viên nào nhỏ hơn.
- PC ở vùng 3 chỉ đổi thứ tự tìm của Next-fit. Phần dư vẫn thuộc partition đã cấp cho P.

**Bẫy** — mỗi phương án sai của từng biến thể được đối chiếu dưới đây.

| Làm sai | Ra phương án | Nhận ra vì |
|---|---|---|
| Cả ba: chọn vùng đầu tiên/nhỏ nhất mà bỏ điều kiện đủ chỗ | **B — vùng 1** | `150 < 220 KB`, không chứa được P |
| First-fit: bắt đầu tìm tiếp từ PC | **C — vùng 4** | Đó là Next-fit; First-fit đã gặp vùng 2 đủ chỗ từ đầu |
| First-fit: tìm vùng nhỏ nhất đủ chỗ | **D — vùng 6** | Đó là Best-fit; First-fit dừng ngay ở vùng 2 |
| Best-fit: dừng ở ứng viên đầu tiên từ đầu bộ nhớ | **A — vùng 2** | Vùng 6 (240 KB) nhỏ hơn vùng 2 (250 KB) mà vẫn đủ |
| Best-fit: tìm tiếp từ PC rồi dừng ở ứng viên đầu tiên | **C — vùng 4** | Vùng 4 đủ nhưng không nhỏ nhất; Best-fit không chọn theo PC |
| Next-fit: quay về đầu ngay dù chưa tìm tiếp từ PC | **A — vùng 2** | Từ PC ở vùng 3 đã gặp vùng 4 đủ trước khi cần quay vòng |
| Next-fit: tìm vùng nhỏ nhất đủ chỗ | **D — vùng 6** | Next-fit dừng ở vùng 4, không tìm vùng vừa khít hơn |
| Cấp phần dư 20/30/200 KB cho process khác | Sai mô hình, không ứng với A–D | Fixed partition cấp trọn vùng; phần dư là internal fragmentation |

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
