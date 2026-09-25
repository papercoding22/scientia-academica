# IT007 — Map Đề Thi & Exam Blueprint

| | |
|---|---|
| Đề đã phân tích | [`Final-Exam-Sample.pdf`](Final-Exam-Sample.pdf) — Đề thi cuối kỳ, mã đề 01, 6 trang |
| Nguồn gốc đề | ❓ Trường/khoa bỏ trống, không ghi giảng viên ra đề — xem [Cần xác minh](#3-cần-xác-minh) |
| Cập nhật | 2026-09-23 |
| Sinh bởi | skill `exam-map` |
| Hướng dẫn ôn | [Chương 5 — kiến thức chắt lọc và hướng dẫn từng câu](chapter5-exam-study-guide.md) |

> **Quy ước nguồn:** `[C7 s44]` = file slide mã **C7**, slide số **44** (tra mã ở [Nguồn slide](#4-nguồn-slide)).
> Đây là phân tích **một đề mẫu**, không phải lời giảng viên — không thay cho mục 2, 3 của
> [`IMPORTANT_NOTES.md`](../IMPORTANT_NOTES.md).

---

## Mục lục

- [1. Map Đề Thi](#1-map-đề-thi)
  - [Đề 01 — Phần 1: Trắc nghiệm (6 điểm)](#đề-01--phần-1-trắc-nghiệm-6-điểm)
  - [Đề 01 — Phần 2: Tự luận (4 điểm)](#đề-01--phần-2-tự-luận-4-điểm)
- [2. Exam Blueprint](#2-exam-blueprint)
  - [2.1. Thông tin đề](#21-thông-tin-đề)
  - [2.2. Trọng số theo chương](#22-trọng-số-theo-chương)
  - [2.3. Trọng số theo mục](#23-trọng-số-theo-mục)
  - [2.4. Theo dạng câu](#24-theo-dạng-câu)
  - [2.5. Theo mức nhận thức](#25-theo-mức-nhận-thức)
  - [2.6. Ma trận chương × dạng câu](#26-ma-trận-chương--dạng-câu)
  - [2.7. Chưa xuất hiện trong đề](#27-chưa-xuất-hiện-trong-đề)
  - [2.8. Ưu tiên ôn](#28-ưu-tiên-ôn)
- [3. Cần xác minh](#3-cần-xác-minh)
- [4. Nguồn slide](#4-nguồn-slide)

---

## 1. Map Đề Thi

### Đề 01 — Phần 1: Trắc nghiệm (6 điểm)

20 câu × 0.3 điểm. Mọi câu đều gắn chuẩn đầu ra **G2.1** (trừ câu 13 không ghi mã).

| Câu | Chủ đề | Mục trong chương | Kiến thức | Dạng câu | Mức | Điểm | Nguồn |
|---|---|---|---|---|---|---:|---|
| 1 | Ch5 — Đồng bộ tiến trình | 5.7.1 Định nghĩa semaphore | `wait(S)` = xin dùng tài nguyên, `signal(S)` = trả tài nguyên | Nhận diện khái niệm | Nhớ | 0.3 | [C5-2 s16] |
| 2 | Ch5 — Đồng bộ tiến trình | 5.3.1 Yêu cầu dành cho lời giải | Phân biệt 3 yêu cầu: mutual exclusion · progress · **bounded waiting**; phương án (2) là mồi nhử | Nhận diện khái niệm | Nhớ | 0.3 | [C5-1 s21, s25] |
| 3 | Ch7 — Quản lý bộ nhớ | 7.5.3 Effective Access Time | Công thức `EAT = (2 − α)x + ε`, giải **ngược** tìm ε | Tính toán | Vận dụng | 0.3 | [C7 s53] |
| 4 | Ch5 — Đồng bộ tiến trình | 5.7.1 Định nghĩa · 5.7.2 Phân loại semaphore | `wait` giảm chứ không tăng; binary ≈ mutex; counting giới hạn số truy cập. Đề viết `sem_wait()` (POSIX), slide viết `wait(S)` | Phát biểu đúng/sai | Hiểu | 0.3 | [C5-2 s16, s26] |
| 5 | Ch5 — Đồng bộ tiến trình | 5.6.2 Mutex locks không busy waiting | Ngủ khi khoá đang bị giữ, đánh thức khi khoá mở (`block`/`wakeup`); phương án A đảo ngược | Nhận diện khái niệm | Nhớ | 0.3 | [C5-2 s10] |
| 6 | Ch8 — Bộ nhớ ảo | 8.1 Tổng quan về bộ nhớ ảo | Ưu điểm: chạy tiến trình lớn hơn RAM. Nhiễu: B mô tả dynamic linking (7.3.2), D nhầm "demand segmentation" với "simple paging" (8.2.1) | Phát biểu đúng/sai | Hiểu | 0.3 | [C8 s8, s10] · nhiễu [C7 s24] |
| 7 | Ch5 — Đồng bộ tiến trình | 5.3.2 Phân loại giải pháp | Peterson thuộc nhóm giải pháp phần mềm (cùng Bakery, Dekker) | Nhận diện khái niệm | Nhớ | 0.3 | [C5-1 s27] |
| 8 | Ch8 — Bộ nhớ ảo | 8.3.2 Giải thuật thay trang FIFO | FIFO thay trang **nạp sớm nhất**. Nhiễu: A là đặc điểm LRU (8.3.5), D là OPT (8.3.4) | Phát biểu đúng/sai | Hiểu | 0.3 | [C8 s25] · nhiễu [C8 s32] |
| 9 | Ch5 — Đồng bộ tiến trình | 5.9.2 Giải pháp bounded-buffer · 5.9.3 Các lỗi thường gặp | Chỉ có `empty`/`full`, thiếu `mutex` → quên bảo vệ vùng tranh chấp `count++`/`count--` | Phân tích code | Phân tích | 0.3 | [C5-3 s8, s11, s13] |
| 10 | Ch8 — Bộ nhớ ảo | 8.1 Tổng quan về bộ nhớ ảo | Ý nào **không** phải ưu điểm của virtual memory | Phát biểu đúng/sai | Hiểu | 0.3 | [C8 s8] |
| 11 | Ch5 — Đồng bộ tiến trình | 5.6.3 Cách sử dụng mutex locks | Mutex khai báo toàn cục để mọi thread trong tiến trình dùng chung | Phát biểu đúng/sai | Hiểu | 0.3 | [C5-2 s13] |
| 12 | Ch8 — Bộ nhớ ảo | 8.2.3 Thay thế trang nhớ | Mục tiêu page-replacement algorithm: số page fault nhỏ nhất. Nhiễu A là frame-allocation algorithm | Phát biểu đúng/sai | Hiểu | 0.3 | [C8 s19] |
| 13 | Ch7 — Quản lý bộ nhớ | 7.4.2 Dynamic partitioning — chiến lược placement (trên nền 7.4.1 Fixed partitioning) | First-fit tìm **từ đầu bộ nhớ**; con trỏ PC là bẫy dành cho next-fit | Mô phỏng giải thuật | Vận dụng | 0.3 | [C7 s34, s39] · bài mẫu [C7 s67] |
| 14 | Ch7 — Quản lý bộ nhớ | 7.4 Mô hình quản lý bộ nhớ — Phân mảnh | External fragmentation: tổng trống đủ nhưng không liên tục | Nhận diện khái niệm | Nhớ | 0.3 | [C7 s31] |
| 15 | Ch7 — Quản lý bộ nhớ | 7.3.1 Chuyển đổi địa chỉ | Trong source code, biến là **symbolic address** | Nhận diện khái niệm | Hiểu | 0.3 | [C7 s18] · [C7 s12] |
| 16 | Ch7 — Quản lý bộ nhớ | 7.3.1 Chuyển đổi địa chỉ | Binding lúc compile time → phải biên dịch lại khi đổi địa chỉ nạp. Nhiễu A là khuyết điểm của load time | Phát biểu đúng/sai | Hiểu | 0.3 | [C7 s19] |
| 17 | Ch5 — Đồng bộ tiến trình | 5.1.3 Race condition | Phân biệt race condition với critical section, mutual exclusion, data inconsistency | Nhận diện khái niệm | Nhớ | 0.3 | [C5-1 s14–s16] |
| 18 | Ch7 — Quản lý bộ nhớ | 7.3.3 Dynamic Loading | "Chỉ nạp thủ tục khi được gọi" = dynamic loading (≠ dynamic linking) | Nhận diện khái niệm | Nhớ | 0.3 | [C7 s27] |
| 19 | Ch8 — Bộ nhớ ảo | 8.2.2 Phân trang theo yêu cầu | Ba bước PFSR: blocked → đọc đĩa → ngắt I/O, cập nhật page table, ready | Sắp thứ tự quy trình | Hiểu | 0.3 | [C8 s13] |
| 20 | Ch7 — Quản lý bộ nhớ | 7.5.1 Chuyển đổi địa chỉ trong paging | Logical → physical: tách `p`, `d` theo page size 2KB, tra bảng trang | Tính toán | Vận dụng | 0.3 | [C7 s44] · bài mẫu [C7 s68] |

### Đề 01 — Phần 2: Tự luận (4 điểm)

Đề ghi "0.5 điểm/câu" và bảng trả lời có **8 ô** (21a … 23d) → mỗi ô 0.5 điểm, 8 × 0.5 = 4 ✓.

| Câu | Chủ đề | Mục trong chương | Kiến thức | Dạng câu | Mức | Điểm | Nguồn |
|---|---|---|---|---|---|---:|---|
| 21a | Ch7 — Quản lý bộ nhớ | 7.5.1 Chuyển đổi địa chỉ trong paging | Số bit địa chỉ luận lý `m = (m−n) + n` từ số trang và page size | Tính toán | Vận dụng | 0.5 | [C7 s44] · bài mẫu [C7 s68] |
| 21b | Ch7 — Quản lý bộ nhớ | 7.5.1 Chuyển đổi địa chỉ trong paging | Kích thước bảng trang = số entry (`2^(m−n)`) × kích thước entry | Tính toán | Vận dụng | 0.5 | [C7 s44] |
| 22a | Ch8 — Bộ nhớ ảo | 8.3.5 Giải thuật thay trang LRU | Chạy tay LRU, 4 frame, chuỗi 18 tham chiếu → đếm page fault | Mô phỏng giải thuật | Vận dụng | 0.5 | [C8 s32] · bài mẫu [C8 s49] |
| 22b | Ch8 — Bộ nhớ ảo | 8.3.5 Giải thuật thay trang LRU | Trang bị thay khi tham chiếu 7 lần đầu — phải ghi được trạng thái frame từng bước | Mô phỏng giải thuật | Vận dụng | 0.5 | [C8 s32] |
| 23a | Ch5 — Đồng bộ tiến trình | Appendix A: Liveness *(slide không đánh số mục)* | Định nghĩa **liveness** — trả lời bằng tiếng Anh | Điền thuật ngữ | Nhớ | 0.5 | [C5-2 s51–s52] |
| 23b | Ch8 — Bộ nhớ ảo | 8.2.2 Phân trang theo yêu cầu | Truy cập trang chưa có trong RAM = **page fault** | Điền thuật ngữ | Nhớ | 0.5 | [C8 s13] |
| 23c | Ch7 — Quản lý bộ nhớ | 7.2 Các kiểu địa chỉ nhớ | "Vị trí nhớ được diễn tả trong chương trình" = **logical address** | Điền thuật ngữ | Nhớ | 0.5 | [C7 s12] |
| 23d | Ch7 — Quản lý bộ nhớ | 7.4 Mô hình quản lý bộ nhớ — Phân mảnh | Gom phân mảnh ngoại thành vùng liên tục = **compaction** | Điền thuật ngữ | Nhớ | 0.5 | [C7 s31] |

---

## 2. Exam Blueprint

### 2.1. Thông tin đề

| | |
|---|---|
| Cấu trúc | Phần 1: 20 câu trắc nghiệm × 0.3 = **6 điểm** · Phần 2: 3 câu tự luận, 8 ô × 0.5 = **4 điểm** |
| Hình thức trả lời | Điền vào **bảng trả lời** cuối đề (kể cả tự luận — chỉ ghi đáp số/thuật ngữ, không trình bày lời giải) |
| Thời lượng | Đề không ghi. Slide chương 0: cuối kỳ **60–90 phút**, tự luận + trắc nghiệm, thi tập trung, **50%** điểm môn [C0 s17] — ❓ xem [Cần xác minh](#3-cần-xác-minh) |
| Chuẩn đầu ra | Chỉ **G2.1** — "Nắm vững kiến thức nền tảng" [C0 s5]. Không câu nào kiểm tra G5.1 (giao tiếp, thảo luận) |
| Phạm vi | Ch5, Ch7, Ch8. Không có câu nào thuộc Ch1–4, Ch6, Ch9 |

### 2.2. Trọng số theo chương

`█` ≈ 0.25 điểm.

| Chương | Điểm | % | Số câu/ý | |
|---|---:|---:|---:|---|
| Ch7 — Quản lý bộ nhớ | **4.1** | 41% | 11 | `████████████████` |
| Ch8 — Bộ nhớ ảo | **3.0** | 30% | 8 | `████████████` |
| Ch5 — Đồng bộ tiến trình | **2.9** | 29% | 9 | `███████████▌` |
| Ch6 — Tắc nghẽn | 0 | 0% | 0 | lịch học ghi "Tự nghiên cứu" [C0 s10] |
| Ch1–4 | 0 | 0% | 0 | thi giữa kỳ đặt ở buổi 5, ngay sau Ch1–4 [C0 s9] |
| Ch9 — Linux & Windows | 0 | 0% | 0 | không có trong lịch 10 buổi [C0 s9–s10] |
| **Tổng** | **10** | 100% | 28 | |

> Ch7 + Ch8 (bộ nhớ) = **7.1 / 10 điểm**. Đồng bộ chỉ 2.9 nhưng rải trên nhiều mục nhỏ.

### 2.3. Trọng số theo mục

| Chương | Mục | Câu | Điểm |
|---|---|---|---:|
| Ch7 | **7.5.1 Chuyển đổi địa chỉ trong paging** | 20, 21a, 21b | **1.3** |
| Ch8 | **8.3.5 Giải thuật thay trang LRU** | 22a, 22b | **1.0** |
| Ch7 | 7.4 Phân mảnh + compaction | 14, 23d | 0.8 |
| Ch8 | 8.2.2 Phân trang theo yêu cầu (PFSR, page fault) | 19, 23b | 0.8 |
| Ch5 | 5.7.1–5.7.2 Semaphore: định nghĩa, phân loại | 1, 4 | 0.6 |
| Ch7 | 7.3.1 Chuyển đổi địa chỉ (address binding) | 15, 16 | 0.6 |
| Ch8 | 8.1 Tổng quan về bộ nhớ ảo | 6, 10 | 0.6 |
| Ch5 | Appendix A: Liveness | 23a | 0.5 |
| Ch7 | 7.2 Các kiểu địa chỉ nhớ | 23c | 0.5 |
| Ch5 | 5.1.3 Race condition | 17 | 0.3 |
| Ch5 | 5.3.1 Yêu cầu dành cho lời giải | 2 | 0.3 |
| Ch5 | 5.3.2 Phân loại giải pháp | 7 | 0.3 |
| Ch5 | 5.6.2 Mutex locks không busy waiting | 5 | 0.3 |
| Ch5 | 5.6.3 Cách sử dụng mutex locks | 11 | 0.3 |
| Ch5 | 5.9.2–5.9.3 Bounded-buffer | 9 | 0.3 |
| Ch7 | 7.3.3 Dynamic Loading | 18 | 0.3 |
| Ch7 | 7.4.1–7.4.2 Partitioning + placement | 13 | 0.3 |
| Ch7 | 7.5.3 Effective Access Time | 3 | 0.3 |
| Ch8 | 8.2.3 Thay thế trang nhớ (mục tiêu) | 12 | 0.3 |
| Ch8 | 8.3.2 Giải thuật thay trang FIFO | 8 | 0.3 |
| | | **Tổng** | **10** |

> Gộp theo khối: **paging** (7.5.1 + 7.5.3) = 1.6 điểm · **thay trang** (8.3) = 1.3 điểm.
> Hai khối tính toán/mô phỏng này là phần "chắc điểm" lớn nhất của đề.

### 2.4. Theo dạng câu

| Dạng câu | Câu | Điểm | % | Hệ quả khi ôn |
|---|---|---:|---:|---|
| Nhận diện khái niệm | 1, 2, 5, 7, 14, 15, 17, 18 | 2.4 | 24% | Thuộc định nghĩa đúng câu chữ slide — phương án nhiễu là thuật ngữ "hàng xóm" |
| Phát biểu đúng/sai | 4, 6, 8, 10, 11, 12, 16 | 2.1 | 21% | Nhiễu thường lấy định nghĩa của mục bên cạnh (LRU vs FIFO, dynamic linking vs VM) |
| Điền thuật ngữ (tiếng Anh, ≤ 2 từ) | 23a–d | **2.0** | 20% | Phải **viết ra được** từ tiếng Anh, không chỉ nhận ra khi đọc |
| Tính toán | 3, 20, 21a, 21b | 1.6 | 16% | Thuộc công thức paging và EAT, biết giải ngược |
| Mô phỏng giải thuật | 13, 22a, 22b | 1.3 | 13% | Chạy tay có ghi trạng thái frame từng bước — đề hỏi cả *trang nào bị thay* |
| Sắp thứ tự quy trình | 19 | 0.3 | 3% | Nhớ thứ tự các bước PFSR |
| Phân tích code | 9 | 0.3 | 3% | Soi code đồng bộ tìm vùng tranh chấp bị bỏ quên |
| **Tổng** | | **10** | 100% | |

### 2.5. Theo mức nhận thức

| Mức | Câu | Điểm | % |
|---|---|---:|---:|
| Nhớ | 1, 2, 5, 7, 14, 17, 18, 23a–d | 4.1 | 41% |
| Hiểu | 4, 6, 8, 10, 11, 12, 15, 16, 19 | 2.7 | 27% |
| Vận dụng | 3, 13, 20, 21a, 21b, 22a, 22b | 2.9 | 29% |
| Phân tích | 9 | 0.3 | 3% |
| **Tổng** | | **10** | 100% |

> ~68% điểm là **nhớ + hiểu** → ôn rộng, thuộc thuật ngữ. ~29% là **vận dụng** tập trung
> gần như toàn bộ vào paging và thay trang → luyện tay vài bài là lấy trọn.

### 2.6. Ma trận chương × dạng câu

| Dạng câu | Ch5 | Ch7 | Ch8 | Tổng |
|---|---:|---:|---:|---:|
| Nhận diện khái niệm | 1.5 | 0.9 | — | 2.4 |
| Phát biểu đúng/sai | 0.6 | 0.3 | 1.2 | 2.1 |
| Điền thuật ngữ | 0.5 | 1.0 | 0.5 | 2.0 |
| Tính toán | — | 1.6 | — | 1.6 |
| Mô phỏng giải thuật | — | 0.3 | 1.0 | 1.3 |
| Sắp thứ tự quy trình | — | — | 0.3 | 0.3 |
| Phân tích code | 0.3 | — | — | 0.3 |
| **Tổng** | **2.9** | **4.1** | **3.0** | **10** |

Đọc ma trận: **Ch5 thuần lý thuyết** (không có bài tính), **Ch7 gánh toàn bộ phần tính
toán**, **Ch8 mạnh về mô phỏng** thay trang.

### 2.7. Chưa xuất hiện trong đề

> ⚠️ Một đề mẫu **không chứng minh** các mục dưới đây không thi. Danh sách này để biết
> đề mẫu *chưa phủ* phần nào, không phải để bỏ qua.

| Chương | Mục chưa bị hỏi | Ghi chú |
|---|---|---|
| Ch5 | 5.4 Giải pháp phần mềm (biến `turn`, code Peterson) | Đề chỉ hỏi *phân loại* Peterson, chưa hỏi phân tích code |
| Ch5 | 5.5 Giải pháp phần cứng: memory barrier, `test_and_set`, `compare_and_swap`, biến đơn nguyên | |
| Ch5 | 5.6.1 Spinlock · 5.7.3 Hiện thực semaphore · 5.7.4 Ứng dụng semaphore | |
| Ch5 | 5.8 Monitor · 5.10 Readers-Writers · 5.11 Dining-Philosophers | |
| Ch6 | Toàn bộ chương Tắc nghẽn | "Tự nghiên cứu" [C0 s10] |
| Ch7 | 7.1 Khái niệm cơ sở · 7.3.2 Dynamic linking (chỉ làm phương án nhiễu) · 7.6 Swapping | |
| Ch7 | 7.5.2 Cài đặt bảng trang (PTBR, TLB) | Chỉ gián tiếp qua câu 3 |
| Ch7 | **7.5.4 Tổ chức bảng trang** (phân trang nhiều cấp, bảng trang nghịch đảo) · 7.5.5 Bảo vệ bộ nhớ | ⚠️ Slide có **bài tập mẫu** phân trang 2–3 cấp [C7 s70–s71] — dạng tính toán dễ ra |
| Ch8 | 8.3.3 Nghịch lý Belady · **8.3.4 OPT** (chỉ làm phương án nhiễu) | ⚠️ Bài tập mẫu slide hỏi cả LRU, FIFO, OPT trên cùng chuỗi [C8 s49] |
| Ch8 | 8.4 Cấp phát frame · 8.5 Thrashing, working set | |

### 2.8. Ưu tiên ôn

> *Suy luận từ đề mẫu, **không phải lời giảng viên**.* Xếp theo điểm kỳ vọng / công sức.

| # | Khối | Điểm trong đề | Luyện gì | Bài mẫu trong slide |
|---|---|---:|---|---|
| 1 | Paging: chuyển địa chỉ + kích thước bảng trang + EAT (7.5.1, 7.5.3) | 1.6 | Số bit `p`/`d`, logical → physical, số entry × kích thước entry, giải ngược EAT. Thêm bảng trang nhiều cấp (7.5.4) phòng khi đề đổi | [C7 s68–s71] |
| 2 | Thay trang (8.3) | 1.3 | Chạy tay **LRU, FIFO, OPT** — đếm page fault **và** ghi trang bị thay ở mỗi bước | [C8 s49] |
| 3 | Thuật ngữ tiếng Anh (toàn đề) | 2.0 | Flashcard: mặt trước là định nghĩa tiếng Việt đúng câu chữ slide, mặt sau là thuật ngữ tiếng Anh ≤ 2 từ | — |
| 4 | Đồng bộ Ch5 (8 mục × 0.3 + liveness) | 2.9 | Ôn rộng: 3 yêu cầu của lời giải CS, phân loại giải pháp, `wait`/`signal`, mutex sleep/wakeup, bounded-buffer đủ **3** semaphore (`empty`, `full`, `mutex`) | [C5-3 s8–s13] |
| 5 | Quản lý bộ nhớ nền (7.2–7.4) | 2.5 | Các kiểu địa chỉ, 3 thời điểm binding + khuyết điểm từng cái, dynamic loading vs linking, phân mảnh, first/best/next/worst-fit | [C7 s67] |
| 6 | Tổng quan VM + PFSR (8.1–8.2) | 1.7 | Ưu điểm VM, thứ tự 3 bước PFSR, mục tiêu page-replacement vs frame-allocation | — |

---

## 3. Cần xác minh

> ❓ **CẦN XÁC MINH:** Nguồn gốc đề — tên trường/khoa để trống, không ghi giảng viên. Đề này
> có phải do giảng viên Nguyễn Thanh Thiện cung cấp cho lớp HK3 2025–2026 không, hay là đề
> tham khảo tự tìm?

> ❓ **CẦN XÁC MINH:** Thời lượng và tỷ trọng thi cuối kỳ. Slide chương 0 ghi 60–90 phút, 50%
> [C0 s17], nhưng slide đó đứng tên ThS. Trần Hoàng Lộc và ThS. Phan Đình Duy [C0 s2–s3],
> khác giảng viên lớp mình. Chưa ghi vào `IMPORTANT_NOTES.md` vì chưa có lời giảng viên lớp này.

> ❓ **CẦN XÁC MINH:** Phạm vi thi cuối kỳ có gồm Ch1–4 không. Đề mẫu không có câu nào Ch1–4,
> và lịch trong slide đặt thi giữa kỳ ngay sau Ch4 [C0 s9], nhưng giảng viên chưa nói rõ.

- Câu 4 dùng `sem_wait()` (API POSIX) trong khi slide lý thuyết dùng `wait(S)` — có thể phần
  thực hành cũng được hỏi; chưa đối chiếu tài liệu lab.
- Câu 13 là câu duy nhất không ghi mã chuẩn đầu ra — chỉ ghi nhận, không ảnh hưởng điểm.

---

## 4. Nguồn slide

| Mã | File |
|---|---|
| C0 | [`Copy of #Week01-Chapter0.pdf`](../materials/slides/Copy%20of%20%23Week01-Chapter0.pdf) — Giới thiệu môn học |
| C5-1 | [`Copy of #Week07-Chapter5-1 2024.pdf`](../materials/slides/Copy%20of%20%23Week07-Chapter5-1%202024.pdf) — Đồng bộ tiến trình (phần 1) |
| C5-2 | [`Copy of #Week09-Chapter5-2 2024.pdf`](../materials/slides/Copy%20of%20%23Week09-Chapter5-2%202024.pdf) — Đồng bộ tiến trình (phần 2) |
| C5-3 | [`Copy of #Week10-Chapter5-3 2024.pdf`](../materials/slides/Copy%20of%20%23Week10-Chapter5-3%202024.pdf) — Bài toán đồng bộ kinh điển |
| C7 | [`Copy of #Week12-Chapter7 2024.pdf`](../materials/slides/Copy%20of%20%23Week12-Chapter7%202024.pdf) — Quản lý bộ nhớ |
| C8 | [`Copy of #Week13-Chapter8 2024.pdf`](../materials/slides/Copy%20of%20%23Week13-Chapter8%202024.pdf) — Bộ nhớ ảo |
