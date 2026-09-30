# IT007 — Chương 8: Bộ nhớ ảo (Virtual memory) — ôn từ đề mẫu

| | |
|---|---|
| Chương | **8 — Bộ nhớ ảo (Virtual memory)**, tương ứng với lecture **L10**, không phải Chương 10 |
| Đề nguồn | [Final-Exam-Sample.pdf](Final-Exam-Sample.pdf), mã đề **01**, 6 trang |
| Phạm vi | **8 câu/ý: 6, 8, 10, 12, 19, 22a, 22b, 23b** |
| Điểm trong đề này | 5 câu trắc nghiệm × 0,3 + 3 ý tự luận × 0,5 = **3,0/10 điểm** |
| Cập nhật | 2026-09-30 |
| Cách dùng | Đọc mục 2 → tự làm các câu trong đề → đối chiếu mục 3 → luyện lại mục 6 |
| Liên quan | [Lecture L10](../lectures/L10-virtual-memory.md) · [Map toàn đề](exam-map.md) · [Guide Chương 7](chapter7-exam-study-guide.md) |

> **Tình trạng nguồn:** đã đọc đủ 6 trang đề, kể cả bảng trả lời trống ở trang 6; **không có đáp án chính thức trong PDF**. Các đáp án dưới đây là **suy luận từ đề và slide**, không phải đáp án do giảng viên công bố. Trường/khoa trên đề để trống, người ra đề chưa xác nhận. Tỷ trọng 3,0 điểm chỉ thuộc đề mẫu này, không cam kết phạm vi đề thi thật.
>
> **Quy ước:** `[Đề tr5, C22a]` là trang 5, câu 22a; `[C8 s32]` là trang PDF thứ 32, tính từ 1, của slide Chương 8 (tra file ở mục 5). Analogy, ví dụ nhỏ và code là **minh họa tự dựng**. L10 dựa trên slide, không có transcript dùng được để kiểm chứng lời giảng miệng.
>
> **Giả thiết câu 22:** dùng **4 frame ban đầu rỗng** và tính cả lỗi khi nạp lần đầu. Đề chỉ ghi số frame, không ghi trạng thái ban đầu; kết quả 22a–b dưới đây phụ thuộc giả thiết này. Nếu có dữ kiện frame đã nạp sẵn, phải mô phỏng lại.

---

## Mục lục

- [1. Đề đang kiểm tra những gì?](#1-đề-đang-kiểm-tra-những-gì)
- [2. Kiến thức chắt lọc](#2-kiến-thức-chắt-lọc)
  - [2.1. Bộ nhớ ảo (Virtual memory)](#21-bộ-nhớ-ảo-virtual-memory)
  - [2.2. Phân trang theo yêu cầu và lỗi trang (Demand paging & Page fault)](#22-phân-trang-theo-yêu-cầu-và-lỗi-trang-demand-paging--page-fault)
  - [2.3. Cấp phát khung trang và thay trang (Frame allocation & Page replacement)](#23-cấp-phát-khung-trang-và-thay-trang-frame-allocation--page-replacement)
  - [2.4. Mô phỏng giải thuật LRU (Least Recently Used)](#24-mô-phỏng-giải-thuật-lru-least-recently-used)
- [3. Đáp án và hướng dẫn từng câu](#3-đáp-án-và-hướng-dẫn-từng-câu)
  - [Câu 6 — Bộ nhớ ảo (Virtual memory)](#câu-6--bộ-nhớ-ảo-virtual-memory)
  - [Câu 8 — Giải thuật thay trang FIFO (First In First Out)](#câu-8--giải-thuật-thay-trang-fifo-first-in-first-out)
  - [Câu 10 — Ưu điểm của bộ nhớ ảo (Virtual memory)](#câu-10--ưu-điểm-của-bộ-nhớ-ảo-virtual-memory)
  - [Câu 12 — Mục tiêu thay trang (Page replacement)](#câu-12--mục-tiêu-thay-trang-page-replacement)
  - [Câu 19 — Xử lý lỗi trang (Page-fault service routine)](#câu-19--xử-lý-lỗi-trang-page-fault-service-routine)
  - [Câu 22a — Đếm lỗi trang với LRU (Least Recently Used)](#câu-22a--đếm-lỗi-trang-với-lru-least-recently-used)
  - [Câu 22b — Trang bị thay khi dùng trang 7 lần đầu (LRU victim)](#câu-22b--trang-bị-thay-khi-dùng-trang-7-lần-đầu-lru-victim)
  - [Câu 23b — Thuật ngữ lỗi trang (Page fault)](#câu-23b--thuật-ngữ-lỗi-trang-page-fault)
- [4. Tự kiểm tra](#4-tự-kiểm-tra)
- [5. Nguồn](#5-nguồn)
- [6. Bạn cần tự làm lại phần nào](#6-bạn-cần-tự-làm-lại-phần-nào)

---

## 1. Đề đang kiểm tra những gì?

| Câu — mã đề 01 | Trang đề | Mục chương và kiến thức | Việc cần làm | Điểm |
|---|---:|---|---|---:|
| 6 | 2 | 8.1, 8.2.1 — Virtual memory, demand paging | Chọn phát biểu **ĐÚNG**, phân biệt với dynamic linking | 0,3 |
| 8 | 2 | 8.3.2 — FIFO; phân biệt LRU, OPT | Nhận ra tiêu chí **nạp sớm nhất** | 0,3 |
| 10 | 3 | 8.1 — Ưu điểm virtual memory | Chọn ý **KHÔNG** phải ưu điểm | 0,3 |
| 12 | 3 | 8.2.3 — Page replacement | Phân biệt mục tiêu thay trang với cấp phát frame | 0,3 |
| 19 | 4 | 8.2.2 — Demand paging, PFSR | Sắp đúng blocked → đọc đĩa → cập nhật, ready | 0,3 |
| 22a | 5 | 8.3.5 — LRU | Mô phỏng đủ 18 tham chiếu, đếm page fault | 0,5 |
| 22b | 5 | 8.3.5 — LRU | Xác định victim khi tham chiếu trang 7 **lần đầu** | 0,5 |
| 23b | 5 | 8.2.2 — Page fault | Điền tiếng Anh, **tối đa 2 từ** | 0,5 |
| **Tổng** | | **8 câu/ý** | | **3,0** |

**Căn cứ điểm:** phần 1 ghi 0,3 điểm/câu. Phần 2 ghi 0,5 điểm/câu; bảng trả lời trang 6 có 8 ô từ 21a đến 23d. Hiểu mỗi ô là 0,5 điểm thì tổng phần 2 là `8 × 0,5 = 4`, khớp đề. Chương 8 chỉ lấy **22a, 22b, 23b**; không cộng cả câu 23 vốn liên chương. [Đề tr1, tr5–tr6]

**Ranh giới:** câu 6B dùng dynamic linking của Chương 7 làm phương án nhiễu. Câu 21 có chữ “địa chỉ ảo” nhưng giải bằng cấu trúc địa chỉ và page table của Chương 7, nên không đưa vào đây. OPT chỉ được nhắc để phân biệt phương án câu 8. Belady, working set và phần lớn nội dung thrashing trong L10 chưa được hỏi trực tiếp trong đề này; điều đó **không có nghĩa là không thi**.

```text
Không cần nạp toàn bộ chương trình → Virtual memory
                 ↓
Chỉ nạp trang khi cần → Demand paging
                 ↓
Trang cần chưa có trong RAM → Page fault → PFSR
                 ↓
Không còn frame trống → Chọn victim page
                 ↓
FIFO: thời điểm nạp | LRU: lần dùng gần nhất | OPT: lần dùng tiếp theo
```

## 2. Kiến thức chắt lọc

### 2.1. Bộ nhớ ảo (Virtual memory)

**Dùng cho:** câu 6, 10. **Nguồn:** [C8 s7–s8, s10]; đối chiếu phương án nhiễu ở [C7 s24].

**Trực giác:** bạn vẫn làm được một công việc lớn dù trước mặt chỉ có chỗ cho phần đang cần.

**Analogy:** bàn học chỉ đủ đặt hai cuốn sách, nhưng bạn có thể học từ cả tủ sách bằng cách lấy từng cuốn cần dùng lên bàn. Bàn vẫn cần tồn tại; tủ sách không thay thế công dụng của bàn.

**Ví dụ nhỏ, tự dựng:** một process có 6 page (trang), được cấp 2 frame (khung trang). Nếu đang cần page 0 và 1, chỉ hai page đó phải có trong RAM; lúc cần page 4, OS có thể đưa page 4 vào một frame sau khi thu hồi chỗ. Process không phải nạp cả 6 page cùng lúc. Đây là mô hình minh họa, giả sử đủ tài nguyên và hỗ trợ để thực hiện các truy cập.

**Định nghĩa:** virtual memory là kỹ thuật cho phép xử lý một process **không được nạp toàn bộ vào bộ nhớ vật lý**. Nhờ đó process có thể lớn hơn bộ nhớ thực; nhiều process có thể cùng hiện diện trong RAM hơn; lập trình viên bớt phải tự tổ chức việc nạp từng phần. [C8 s7–s8]

Slide nêu hai cách cài đặt: **demand paging (phân trang theo yêu cầu)** và **demand segmentation (phân đoạn theo yêu cầu)**; chương này tập trung vào paging. “Simple paging” trong câu 6D không phải tên kỹ thuật thứ nhất mà slide liệt kê. [C8 s10]

| Phát biểu cần nhớ | Giới hạn để tránh hiểu sai |
|---|---|
| Process có thể lớn hơn RAM | Không có nghĩa bộ nhớ vô hạn hoặc mọi chương trình lớn đều chạy hiệu quả |
| Có thể tăng mức độ multiprogramming (đa chương) | Không phải cứ tăng số process là hệ thống nhanh hơn |
| Vẫn cần RAM cho phần đang được thực thi/truy cập | “Loại bỏ sự cần thiết của RAM” là sai trong mô hình của đề |
| Dynamic linking là liên kết đến external module sau khi tạo load module | Đây là định nghĩa của Chương 7, không phải định nghĩa virtual memory [C7 s24] |

### 2.2. Phân trang theo yêu cầu và lỗi trang (Demand paging & Page fault)

**Dùng cho:** câu 19, 23b; nền để đếm lỗi ở câu 22. **Nguồn:** [C8 s13, s17].

**Trực giác:** cần món đồ chưa có sẵn thì phải chờ lấy về, còn người khác vẫn tiếp tục làm việc.

**Analogy:** bạn đang đọc thì thiếu một cuốn sách. Bạn tạm dừng để thủ thư lấy sách từ kho; thủ thư vẫn phục vụ người khác. Sách về thì bạn đủ điều kiện đọc tiếp, nhưng chưa chắc được phục vụ ngay lập tức.

**Ví dụ nhỏ, tự dựng:** RAM có page 1 và một frame trống. Tham chiếu page 1 là **hit**; tham chiếu page 2 chưa có trong RAM là **page fault**. Nạp page 2 vào frame trống vẫn tính **một page fault**, dù không đuổi page nào ra.

**Định nghĩa và quy trình theo slide:** demand paging chỉ nạp page khi được yêu cầu. Khi tham chiếu một page chưa có trong bộ nhớ chính, phần cứng phát sinh **page-fault trap**, kích hoạt **page-fault service routine (PFSR)** của OS. [C8 s13]

```text
Tham chiếu page chưa có trong RAM
                ↓ page-fault trap
Process → blocked
                ↓
Yêu cầu đọc page vào frame trống
                ├── Trong lúc chờ I/O: process khác có thể dùng CPU
                ↓ I/O hoàn tất, đĩa phát ngắt
Cập nhật page table → process về ready
                ↓ Khi được scheduler chọn
Process tiếp tục chạy
```

Nếu không có frame trống, OS phải chọn **victim page (trang bị thay)** trước khi nạp page mới. Slide s17 minh họa bước ghi victim ra đĩa rồi cập nhật bảng; trong hệ thống thực, việc cần ghi lại còn phụ thuộc page đã bị sửa và có bản lưu phù hợp hay chưa. Không dùng số lần ghi đĩa để thay cho số page fault trong bài mô phỏng.

**Giới hạn mô hình:** câu 19 xét page hợp lệ nhưng chưa có trong RAM và phải chờ disk I/O, đúng quy trình giản lược ở s13. Không suy rộng thành “mọi page fault trong mọi OS đều phải đọc đĩa”. `Ready` cũng không đồng nghĩa `running` ngay.

| Tình huống | Page fault? | Phải thay page? |
|---|---|---|
| Page đã có trong RAM | Không | Không |
| Page chưa có, còn frame trống | Có | Không |
| Page chưa có, không còn frame trống | Có | Có, trong mô hình thay trang của bài |

### 2.3. Cấp phát khung trang và thay trang (Frame allocation & Page replacement)

**Dùng cho:** câu 8, 12. **Nguồn:** [C8 s19, s25, s30, s32, s35].

**Trực giác:** quyết định một người được bao nhiêu chỗ khác với quyết định món nào phải bỏ ra khi hết chỗ.

**Analogy:** thư viện cấp cho bạn hai chỗ để sách là một quyết định. Khi muốn đặt cuốn thứ ba lên bàn, chọn cuốn nào cất đi là một quyết định khác.

**Ví dụ nhỏ, tự dựng:** process được cấp **2 frame** là kết quả của frame allocation. Sau khi nạp lần lượt page 1, 2 rồi dùng lại page 1, nếu cần page 3 thì phải chọn victim. **FIFO chọn 1** vì được nạp trước; **LRU chọn 2** vì lâu hơn chưa được dùng.

**Định nghĩa và mục tiêu:** [C8 s19]

- **Frame-allocation algorithm:** quyết định process được cấp bao nhiêu frame.
- **Page-replacement algorithm:** chọn page/frame để thay; mục tiêu học thuật là **số page fault nhỏ nhất**, đánh giá trên một memory reference string (chuỗi tham chiếu bộ nhớ) và số frame xác định.
- Giảm page fault là mục tiêu, không phải bảo đảm mọi thuật toán luôn đạt số lỗi tối ưu. Khi so sánh cần giữ cùng chuỗi, số frame và trạng thái ban đầu.

Với `n` tham chiếu, có thể kiểm đếm bằng `số fault + số hit = n`. **Nạp vào frame trống cũng là fault** nếu page chưa có; fault và replacement không phải hai tên cho cùng một số đếm.

| Giải thuật | Chọn victim theo tiêu chí nào? | Một lần hit có làm đổi thứ tự dùng để chọn victim? |
|---|---|---|
| FIFO — First In First Out | Page được **nạp sớm nhất** trong số đang ở RAM [C8 s25] | Không đổi thứ tự nạp |
| LRU — Least Recently Used | Page có **lần tham chiếu gần nhất xa nhất về quá khứ** [C8 s32] | **Có**, phải cập nhật lần dùng gần nhất |
| OPT — Optimal | Page có lần tham chiếu tiếp theo **trễ nhất trong tương lai**; page không còn dùng nữa cũng là ứng viên [C8 s30] | Phải nhìn phần chuỗi còn lại; cần biết tương lai |

**Bẫy câu 8D:** “sớm nhất trong tương lai” không đúng với FIFO **và cũng không đúng với OPT**. OPT giữ lại page sắp cần, ưu tiên đuổi page còn lâu mới cần.

### 2.4. Mô phỏng giải thuật LRU (Least Recently Used)

**Dùng cho:** câu 22a, 22b. **Nguồn:** quy tắc [C8 s32]; chuỗi cụ thể [Đề tr5, C22].

**Trực giác:** khi thiếu chỗ, cất món đã lâu nhất chưa đụng tới.

**Analogy:** trên bàn có bút và kéo; bạn vừa dùng bút thì kéo trở thành món lâu hơn chưa dùng. Khi cần chỗ cho thước, cất kéo, dù bút được đặt lên bàn trước.

**Ví dụ nhỏ, tự dựng:** 2 frame rỗng, chuỗi `1, 2, 1, 3`:

| Bước | Page | Thứ tự **LRU → MRU** sau bước này | Hit/fault | Victim |
|---:|---:|---|---|---|
| 1 | 1 | `1` | Fault | Không, dùng frame trống |
| 2 | 2 | `1, 2` | Fault | Không, dùng frame trống |
| 3 | 1 | `2, 1` | Hit | Không |
| 4 | 3 | `1, 3` | Fault | **2** |

MRU = **Most Recently Used**, page vừa được dùng gần nhất. Danh sách trên biểu diễn **thứ tự sử dụng**, không phải vị trí frame vật lý.

**Quy tắc hình thức:** gọi `last_used[p]` là số bước tham chiếu gần nhất của page `p`. Khi fault và hết frame trống, chọn page đang ở RAM có `last_used[p]` **nhỏ nhất**. Sau **mọi** tham chiếu, kể cả hit, gán `last_used[p] = bước hiện tại`. [C8 s32]

```text
Page có trong RAM? ── Có → Hit → Cập nhật last_used
       │ Không
       ↓
Tăng số fault → Còn frame trống? ── Có → Nạp vào frame trống
                       │ Không
                       ↓
          Thay page có last_used nhỏ nhất
                       ↓
             Cập nhật last_used page mới
```

**Code Python 3 tự dựng, chạy không cần dependency:** mô phỏng logic của bài; không can thiệp bộ nhớ OS. Danh sách `frames` giữ nguyên vị trí từng frame, còn `last_used` giữ thứ tự dùng.

```python
def simulate_lru(refs, capacity):
    frames = [None] * capacity
    last_used = {}
    rows = []
    for step, page in enumerate(refs, 1):
        hit = page in frames
        victim = None
        if not hit:
            if None in frames:
                slot = frames.index(None)
            else:
                victim = min(frames, key=last_used.get)
                slot = frames.index(victim)
            frames[slot] = page
        last_used[page] = step  # Cập nhật cả khi hit.
        rows.append((step, page, frames.copy(), hit, victim))
    return rows

refs = [1, 3, 2, 4, 5, 4, 0, 1, 7, 4, 1, 3, 2, 7, 1, 3, 5, 2]
rows = simulate_lru(refs, 4)
faults = sum(not row[3] for row in rows)
first_seven = next(row for row in rows if row[1] == 7)
print("Số lỗi trang:", faults)
print("Victim khi truy xuất 7 lần đầu:", first_seven[4])
```

Kết quả: **13 lỗi trang**, victim khi truy xuất 7 lần đầu là **5**. Bảng đủ 18 bước nằm ở câu 22a; cách kiểm độc lập bằng thứ tự LRU → MRU cho cùng kết quả.

**Chốt cách làm:** đánh số tham chiếu → ghi hit/fault → dùng frame trống hoặc chọn victim → cập nhật lần dùng → kiểm `hit + fault = số tham chiếu`. Đừng sắp xếp page theo giá trị số hoặc chỉ cập nhật thứ tự khi có fault.

## 3. Đáp án và hướng dẫn từng câu

### Câu 6 — Bộ nhớ ảo (Virtual memory)

**Đề:** chọn phát biểu **ĐÚNG** về bộ nhớ ảo. [Đề tr2, C6; 0,3 điểm]

Các phương án dưới đây được rút gọn, giữ nhãn và logic gốc:

- **A.** Nhờ bộ nhớ ảo, process có thể thực thi ngay cả khi kích thước lớn hơn bộ nhớ thực.
- **B.** Bộ nhớ ảo cho phép process liên kết đến external module sau khi tạo xong load module.
- **C.** Khi dùng bộ nhớ ảo, số lượng process trong bộ nhớ ít hơn.
- **D.** Hai kỹ thuật cài đặt là simple paging và demand segmentation.

**Đáp án suy luận: A — Process có thể thực thi ngay cả khi kích thước lớn hơn bộ nhớ thực.** [C8 s7–s8]

**Kiến thức cần dùng:** [mục 2.1](#21-bộ-nhớ-ảo-virtual-memory); [C8 s7–s8, s10], [C7 s24].

**Cách làm và giải thích:** không phải nạp toàn bộ process cùng lúc, nên tổng kích thước process có thể vượt RAM. B lấy định nghĩa **dynamic linking**; C đảo ngược lợi ích tăng số process có thể cùng hiện diện; D thay sai **demand paging** bằng **simple paging**.

**Bẫy và giả thiết:** A nói “**có thể**”, không hứa một chương trình bất kỳ đều chạy được hoặc chạy nhanh. Không suy ra virtual memory loại bỏ nhu cầu RAM.

**Tự kiểm tra:** sửa B thành tên khái niệm đúng và sửa D thành hai kỹ thuật đúng mà không nhìn [mục 2.1](#21-bộ-nhớ-ảo-virtual-memory).

### Câu 8 — Giải thuật thay trang FIFO (First In First Out)

**Đề:** chọn phát biểu **ĐÚNG** về FIFO. [Đề tr2, C8; 0,3 điểm]

Các phương án được rút gọn, giữ nhãn và tiêu chí gốc:

- **A.** FIFO cần hỗ trợ phần cứng cho tìm kiếm; ít CPU cung cấp đủ hỗ trợ đó.
- **B.** FIFO thay page được tham chiếu **nhiều lần nhất**.
- **C.** FIFO thay page có thời gian được **nạp vào bộ nhớ sớm nhất**.
- **D.** FIFO thay page sẽ được tham chiếu **sớm nhất trong tương lai**.

**Đáp án suy luận: C — Thay page được nạp vào bộ nhớ sớm nhất trong số page đang ở RAM.** [C8 s25]

**Kiến thức cần dùng:** [mục 2.3](#23-cấp-phát-khung-trang-và-thay-trang-frame-allocation--page-replacement); [C8 s25, s30, s32].

**Cách làm và giải thích:** FIFO quản lý theo thứ tự vào RAM. Hit không đưa page ra cuối hàng đợi FIFO. A lấy nhận xét của slide về **LRU**; B dùng số lần tham chiếu, không phải thứ tự nạp; D dùng tương lai, cũng không phải FIFO.

**Bẫy:** D **không phải định nghĩa đúng của OPT**: OPT chọn page dùng **trễ nhất**, không phải sớm nhất, trong tương lai. “Nạp lâu nhất” của FIFO cũng khác “lâu nhất chưa dùng” của LRU.

**Tự kiểm tra:** với 2 frame và chuỗi `1, 2, 1, 3`, tại page 3, FIFO thay **1**, LRU thay **2**. Giải thích được khác biệt ở lần hit page 1 là đã nắm tiêu chí.

### Câu 10 — Ưu điểm của bộ nhớ ảo (Virtual memory)

**Đề:** ý nào **KHÔNG** phải ưu điểm của virtual memory? [Đề tr3, C10; 0,3 điểm]

- **A.** Loại bỏ sự cần thiết của RAM khi thực thi chương trình.
- **B.** Giảm nhẹ công việc của lập trình viên.
- **C.** Tăng mức độ đa chương.
- **D.** Cho phép thực thi chương trình có kích thước lớn hơn bộ nhớ vật lý.

**Đáp án suy luận: A — “Loại bỏ sự cần thiết của RAM khi thực thi chương trình” là phát biểu sai.** [C8 s7–s8]

**Kiến thức cần dùng:** [mục 2.1](#21-bộ-nhớ-ảo-virtual-memory); [C8 s7–s8].

**Cách làm và giải thích:** virtual memory giảm phần chương trình phải cùng có mặt trong RAM, nhưng phần đang cần vẫn phải được đưa vào bộ nhớ vật lý. B, C, D tương ứng ba ưu điểm slide liệt kê.

**Bẫy:** gạch chân **KHÔNG** trước khi chọn. Đừng chọn D chỉ vì “lớn hơn RAM” nghe bất khả thi; đó chính là điều không cần nạp toàn bộ cùng lúc giúp thực hiện.

**Tự kiểm tra:** dùng analogy bàn học và tủ sách để giải thích vì sao tủ lớn hơn không có nghĩa có thể bỏ hẳn bàn.

### Câu 12 — Mục tiêu thay trang (Page replacement)

**Đề:** mục tiêu cần đạt của các giải thuật thay thế trang là gì? [Đề tr3, C12; 0,3 điểm]

- **A.** Xác định số khung trang cần cấp cho mỗi tiến trình.
- **B.** Tăng số lượng trang nhớ được nạp vào bộ nhớ.
- **C.** Số lượng lỗi trang nhỏ nhất.
- **D.** Giảm tình trạng trì trệ do tiến trình không được cấp đủ số lượng khung trang.

**Đáp án suy luận: C — Số lượng lỗi trang nhỏ nhất.** [C8 s19]

**Kiến thức cần dùng:** [mục 2.3](#23-cấp-phát-khung-trang-và-thay-trang-frame-allocation--page-replacement); [C8 s19, s35].

**Cách làm và giải thích:** giải thuật chọn victim sao cho hạn chế phải nạp lại page, được đánh giá bằng số page fault trên chuỗi tham chiếu. A là câu hỏi của **frame allocation**. B không phải mục tiêu vì nạp nhiều page không đồng nghĩa chúng cần thiết. D liên quan vấn đề thiếu frame và kiểm soát trì trệ; C là mục tiêu trực tiếp được ghi ở s19.

**Bẫy:** mục tiêu giảm fault không làm mọi thuật toán trở thành OPT. Đừng nhầm “chọn thay page nào” với “cấp cho process bao nhiêu frame”.

**Tự kiểm tra:** giải thích vì sao đề đã cho **4 frame** ở câu 22 nhưng vẫn cần chọn **LRU**: một dữ kiện xác định lượng chỗ, dữ kiện còn lại xác định victim.

### Câu 19 — Xử lý lỗi trang (Page-fault service routine)

**Đề:** sắp thứ tự các bước PFSR. [Đề tr4, C19; 0,3 điểm]

Các bước được rút gọn, giữ số gốc:

1. Phát yêu cầu đọc đĩa để nạp page được tham chiếu vào frame trống; trong khi chờ I/O, process khác được cấp CPU.
2. I/O xong, đĩa phát ngắt; PFSR cập nhật page table và chuyển process về `ready`.
3. Chuyển process về `blocked`.

| A | B | C | D |
|---|---|---|---|
| `(3) → (1) → (2)` | `(1) → (2) → (3)` | `(3) → (2) → (1)` | `(2) → (1) → (3)` |

**Đáp án suy luận: A — (3) → (1) → (2).** [C8 s13]

**Kiến thức cần dùng:** [mục 2.2](#22-phân-trang-theo-yêu-cầu-và-lỗi-trang-demand-paging--page-fault); [C8 s13].

**Cách làm và giải thích:** process thiếu page nên phải `blocked`; tiếp theo yêu cầu đọc page, nhường CPU trong lúc chờ I/O; sau khi dữ liệu đã được nạp, OS cập nhật ánh xạ rồi đưa process về `ready`. B đưa về blocked sau khi đã hoàn tất; C, D cho I/O hoàn tất trước khi yêu cầu đọc.

**Bẫy và giả thiết:** bước **3 trong đề** chính là bước **1 của quy trình slide**. Giữ số của đề khi điền. Bài đã giả định frame trống; nếu hết frame, phải bổ sung chọn victim theo s17, không tự đổi thứ tự ba bước đã cho. `Ready` chưa phải `running`.

**Tự kiểm tra:** không nhìn đáp án, nói được “chờ vì thiếu page → đọc page → sẵn sàng trở lại”, rồi đổi đúng sang nhãn `(3), (1), (2)`.

### Câu 22a — Đếm lỗi trang với LRU (Least Recently Used)

**Đề:** hệ thống có **4 frame**, dùng LRU trên chuỗi **18 tham chiếu** sau; điền số lỗi trang vào ô 22a. [Đề tr5, C22a; 0,5 điểm]

```text
1, 3, 2, 4, 5, 4, 0, 1, 7, 4, 1, 3, 2, 7, 1, 3, 5, 2
```

**Đáp án suy luận, với 4 frame ban đầu rỗng: 13 lỗi trang.** Quy tắc [C8 s32]; kết quả mô phỏng bảng dưới và code [mục 2.4](#24-mô-phỏng-giải-thuật-lru-least-recently-used).

**Kiến thức cần dùng:** [mục 2.2](#22-phân-trang-theo-yêu-cầu-và-lỗi-trang-demand-paging--page-fault) để phân biệt fault/replacement, [mục 2.4](#24-mô-phỏng-giải-thuật-lru-least-recently-used) để cập nhật LRU.

**Cách làm:** đánh số bước từ 1; page có trong frame thì hit, nhưng vẫn cập nhật lần dùng. Nếu fault, dùng frame trống trước; nếu đầy, thay page có lần dùng gần nhất xa nhất về quá khứ. Bảng giữ **vị trí frame F1–F4 cố định**, không xáo lại thành thứ tự LRU.

| Bước | Page | F1 | F2 | F3 | F4 | Hit/Fault | Victim | Fault lũy kế |
|---:|---:|---:|---:|---:|---:|---|---:|---:|
| 1 | 1 | 1 | — | — | — | F | — | 1 |
| 2 | 3 | 1 | 3 | — | — | F | — | 2 |
| 3 | 2 | 1 | 3 | 2 | — | F | — | 3 |
| 4 | 4 | 1 | 3 | 2 | 4 | F | — | 4 |
| 5 | 5 | 5 | 3 | 2 | 4 | F | 1 | 5 |
| 6 | 4 | 5 | 3 | 2 | 4 | H | — | 5 |
| 7 | 0 | 5 | 0 | 2 | 4 | F | 3 | 6 |
| 8 | 1 | 5 | 0 | 1 | 4 | F | 2 | 7 |
| **9** | **7** | **7** | **0** | **1** | **4** | **F** | **5** | **8** |
| 10 | 4 | 7 | 0 | 1 | 4 | H | — | 8 |
| 11 | 1 | 7 | 0 | 1 | 4 | H | — | 8 |
| 12 | 3 | 7 | 3 | 1 | 4 | F | 0 | 9 |
| 13 | 2 | 2 | 3 | 1 | 4 | F | 7 | 10 |
| 14 | 7 | 2 | 3 | 1 | 7 | F | 4 | 11 |
| 15 | 1 | 2 | 3 | 1 | 7 | H | — | 11 |
| 16 | 3 | 2 | 3 | 1 | 7 | H | — | 11 |
| 17 | 5 | 5 | 3 | 1 | 7 | F | 2 | 12 |
| 18 | 2 | 5 | 3 | 1 | 2 | F | 7 | 13 |

`—` ở cột frame là frame trống; ở cột victim là không có page bị thay. **Page 0 là một page hợp lệ**, không dùng số 0 để ký hiệu ô trống.

**Kiểm đếm độc lập:** các hit ở bước **6, 10, 11, 15, 16**, tổng 5 hit. Vì vậy `18 − 5 = 13 fault`. Bốn fault đầu chỉ lấp frame trống; còn **9 lần replacement**, nên trả lời 9 là bỏ sót lỗi nạp ban đầu.

**Bẫy và giả thiết:** đề không ghi trạng thái frame ban đầu; kết quả trên dùng giả thiết frame rỗng. Đặc biệt phải cập nhật page 4 ở bước 6 và page 1 ở bước 11, dù hai bước đều là hit. Trang bị đuổi rồi được gọi lại vẫn gây fault.

**Tự kiểm tra:** tự làm lại bảng từ chuỗi gốc; so sánh các bước 9, 12, 14 trước khi đối chiếu tổng. Nếu tổng đúng nhưng victim sai, vẫn cần sửa cách cập nhật thứ tự.

### Câu 22b — Trang bị thay khi dùng trang 7 lần đầu (LRU victim)

**Đề:** với đúng chuỗi và 4 frame ở câu 22a, khi truy xuất page **7 lần đầu tiên**, page nào bị thay? [Đề tr5, C22b; 0,5 điểm]

**Đáp án suy luận, với 4 frame ban đầu rỗng: trang 5.** [C8 s32]; trạng thái trước bước 9 trong bảng câu 22a.

**Kiến thức cần dùng:** [mục 2.4](#24-mô-phỏng-giải-thuật-lru-least-recently-used); LRU so sánh lần dùng **gần nhất** của các page **đang ở RAM**.

**Cách làm và giải thích:** page 7 xuất hiện lần đầu ở **bước 9**, không phải bước 7. Ngay trước đó, các frame chứa `5, 0, 1, 4`:

| Page đang ở RAM | Lần tham chiếu gần nhất trước bước 9 |
|---:|---:|
| **5** | **5 — nhỏ nhất, chọn làm victim** |
| 4 | 6 |
| 0 | 7 |
| 1 | 8 |

Page 4 được **nạp** ở bước 4 nhưng vừa **dùng lại** ở bước 6, nên page 5 mới là page lâu nhất chưa dùng. Thay page 5 bằng page 7, các frame thành `7, 0, 1, 4`.

**Bẫy:** đáp án là **số page 5**, không phải frame F1 hoặc số thứ tự bước 9. Không xét lần tham chiếu 7 thứ hai ở bước 14.

**Tự kiểm tra:** viết thứ tự trước bước 9 theo LRU → MRU: `5 → 4 → 0 → 1`; loại đầu danh sách rồi thêm 7 ở cuối, được `4 → 0 → 1 → 7`.

### Câu 23b — Thuật ngữ lỗi trang (Page fault)

**Đề:** “Trong bộ nhớ ảo, hiện tượng xảy ra khi CPU muốn truy cập một trang nhớ mà trang nhớ đó chưa có trong bộ nhớ chính được gọi là gì?” Trả lời **bằng tiếng Anh, tối đa 2 từ**. [Đề tr5, C23b; 0,5 điểm]

**Đáp án suy luận: `page fault`.** [C8 s13]

**Kiến thức cần dùng:** [mục 2.2](#22-phân-trang-theo-yêu-cầu-và-lỗi-trang-demand-paging--page-fault); [C8 s13].

**Cách làm và giải thích:** dữ kiện “page chưa có trong bộ nhớ chính” xác định hiện tượng page fault. **Demand paging** là kỹ thuật nạp theo yêu cầu; **PFSR** là routine xử lý; **page replacement** là việc có thể phải làm khi hết frame, không phải tên hiện tượng đề hỏi.

**Bẫy:** điền đúng hai từ `page fault`, không thêm phần giải thích dài vào ô đáp án. Việc còn frame trống không ngăn page fault nếu page cần vẫn chưa có trong RAM.

**Tự kiểm tra:** RAM còn trống nhưng process tham chiếu page chưa nạp thì trả lời vẫn là `page fault`.

## 4. Tự kiểm tra

**1. Process có 6 page nhưng chỉ được cấp 2 frame: điều gì cho phép nó chạy, và điều đó có làm RAM không còn cần thiết không?**

<details><summary>Đáp án và giải thích</summary>

Virtual memory cho phép chỉ một phần process nằm trong RAM tại mỗi thời điểm; demand paging đưa page cần dùng vào khi được yêu cầu. Vẫn cần RAM cho phần được truy cập/thực thi. Ví dụ giả sử đủ hỗ trợ và tài nguyên, không khẳng định mọi chương trình đều chạy hiệu quả với 2 frame. [C8 s7–s8, s13]

</details>

**2. CPU cần page chưa có trong RAM nhưng còn frame trống: có page fault không, có victim không, thứ tự xử lý trong mô hình slide là gì?**

<details><summary>Đáp án và giải thích</summary>

Có **page fault**, không có victim vì dùng frame trống. Với trường hợp cần đọc đĩa của slide: `blocked → yêu cầu đọc page, chờ I/O → I/O xong, cập nhật page table, ready`. Không cần thay page mới được tính fault. [C8 s13, s17]

</details>

**3. Hai frame rỗng, chuỗi `1, 2, 1, 3`: FIFO và LRU thay page nào ở lần cuối?**

<details><summary>Đáp án và giải thích</summary>

**FIFO thay 1**, vì page 1 nạp trước page 2. **LRU thay 2**, vì page 1 vừa được dùng ở bước 3. Cả hai có 3 fault trên chuỗi ngắn này, nhưng victim khác nhau; chỉ kiểm tổng fault chưa đủ kiểm cách làm. [C8 s25, s32]

</details>

**4. Trong câu 22, trước khi dùng page 7 lần đầu, page nào là LRU? Vì sao không phải page 4?**

<details><summary>Đáp án và giải thích</summary>

**Page 5**. Trước bước 9: `last_used[5] = 5`, `last_used[4] = 6`, `last_used[0] = 7`, `last_used[1] = 8`. Page 4 đã hit ở bước 6 nên phải cập nhật lần dùng. Kết quả theo giả thiết 4 frame ban đầu rỗng. [Đề tr5, C22; C8 s32]

</details>

**5. Một mô phỏng có 18 tham chiếu và 5 hit, ban đầu 4 frame rỗng; 4 fault đầu lấp đủ các frame. Có bao nhiêu fault và bao nhiêu replacement?**

<details><summary>Đáp án và giải thích</summary>

**13 fault** vì `18 − 5 = 13`; **9 replacement** vì `13 − 4 = 9`. Kết quả giả sử các frame đã nạp tiếp tục được giữ/cập nhật theo mô hình thay trang, không có hành động giải phóng frame khác giữa chuỗi. Đây chính là cách kiểm tổng của câu 22. [C8 s17, s32]

</details>

## 5. Nguồn

| Mã | File gốc và phần đã đối chiếu | Vai trò |
|---|---|---|
| Đề | [Final-Exam-Sample.pdf](Final-Exam-Sample.pdf), mã 01; đã đọc đủ tr1–tr6 | Câu 6, 8 ở tr2; 10, 12 ở tr3; 19 ở tr4; 22a–b, 23b ở tr5; điểm và bảng trả lời tr1, tr5–tr6 |
| C8 | [Copy of #Week13-Chapter8 2024.pdf](../materials/slides/Copy%20of%20%23Week13-Chapter8%202024.pdf), s7–s8, s10, s13, s17, s19, s25, s30, s32, s35 | Định nghĩa VM; demand paging/PFSR; allocation/replacement; FIFO, OPT, LRU |
| C7 | [Copy of #Week12-Chapter7 2024.pdf](../materials/slides/Copy%20of%20%23Week12-Chapter7%202024.pdf), s24 | Phân biệt dynamic linking trong câu 6B |
| L10 | [L10-virtual-memory.md](../lectures/L10-virtual-memory.md) | Ngữ cảnh buổi học và đường dẫn tới slide; không dùng làm bằng chứng lời giảng miệng |
| Map | [exam-map.md](exam-map.md) | Chỉ mục toàn đề, ranh giới với Chương 5 và Chương 7 |

**Kiểm chứng kết quả:** đã chạy nguyên văn code Python ở [mục 2.4](#24-mô-phỏng-giải-thuật-lru-least-recently-used); đối chiếu từng trạng thái, hit/fault và victim của 18 bước bằng một mô phỏng độc lập dùng danh sách LRU → MRU. Tổng điểm được kiểm bằng `5 × 0,3 + 3 × 0,5 = 3,0`. Đây là kiểm chứng logic mô phỏng, không phải đo hoạt động bộ nhớ của OS thực.

**Còn cần xác minh:** nguồn gốc/người ra đề; đáp án chính thức; trạng thái frame ban đầu nếu có chỉ dẫn bổ sung cho câu 22. Không dùng một đề mẫu để kết luận phạm vi thi thật.

## 6. Bạn cần tự làm lại phần nào

- [ ] Làm lại **6, 10**, giải thích vì sao có thể chạy process lớn hơn RAM nhưng vẫn cần RAM.
- [ ] Làm lại **8, 12**, phân biệt thứ tự nạp, lần dùng gần nhất, lần dùng tiếp theo; phân biệt allocation với replacement.
- [ ] Viết thứ tự **19** từ trí nhớ rồi đổi sang đúng nhãn số của đề.
- [ ] Che bảng **22a**, mô phỏng đủ 18 bước; ghi cả hit/fault, victim và tổng lỗi.
- [ ] Giải thích **22b** bằng bốn thời điểm tham chiếu gần nhất trước bước 9.
- [ ] Viết **23b** đúng tiếng Anh, tối đa hai từ; giải thích vì sao không điền demand paging.

**Chuẩn tự đối chiếu, đều là đáp án suy luận:**

| Câu | Kết quả |
|---|---|
| 6 | A |
| 8 | C |
| 10 | A |
| 12 | C |
| 19 | A — `(3) → (1) → (2)` |
| 22a | 13 page fault, giả sử 4 frame ban đầu rỗng |
| 22b | Page 5, cùng giả thiết trên |
| 23b | `page fault` |
