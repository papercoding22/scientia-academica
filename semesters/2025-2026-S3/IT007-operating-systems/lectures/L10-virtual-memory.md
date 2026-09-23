# L10 — Bộ nhớ ảo (Virtual Memory)

| | |
|---|---|
| Môn | `IT007` Hệ điều hành |
| Buổi | 10 |
| Ngày | 2026-09-11 |
| Giảng viên | Nguyễn Thanh Thiện |
| Transcript | ❌ Không dùng — transcript Teams bị lỗi dịch/ngôn ngữ. Note này dựa hoàn toàn vào slide. |
| Slide | [`../materials/slides/Copy of #Week13-Chapter8 2024.pdf`](../materials/slides/) |

> ❓ **CẦN XÁC MINH:** Không có transcript nên note này chỉ phản ánh nội dung slide.
> Không bắt được phần giảng viên nói thêm, ví dụ minh hoạ ngoài slide, hay gợi ý thi.
> Nếu buổi học có nói gì thêm ngoài slide, bổ sung thủ công sau.

---

## Mục lục

- [Tóm tắt một đoạn](#tóm-tắt-một-đoạn)
- [Nội dung chính](#nội-dung-chính)
- [Bảng tổng hợp](#bảng-tổng-hợp)
- [Sơ đồ](#sơ-đồ)
- [Chỗ chưa rõ](#chỗ-chưa-rõ)
- [Tự kiểm tra](#tự-kiểm-tra)
- [Liên kết](#liên-kết)

---

## Tóm tắt một đoạn

Bộ nhớ ảo cho phép chạy một tiến trình mà không cần nạp toàn bộ nó vào RAM — chỉ nạp phần đang cần dùng (demand paging), phần còn lại nằm ở đĩa (swap space) và được nạp khi có page fault. Khi RAM đầy, hệ điều hành phải chọn một trang "hy sinh" để đẩy ra đĩa, nhường chỗ cho trang mới — đây là bài toán page-replacement (FIFO, OPT, LRU). Cấp quá ít frame cho một tiến trình khiến nó liên tục page fault (thrashing); giải pháp là theo dõi working set — tập trang tiến trình *thực sự đang dùng* — để cấp đúng đủ.

---

## Nội dung chính

### 1. Bộ nhớ ảo là gì, tại sao cần

**Trực giác:** máy bạn có RAM 8GB nhưng vẫn mở được ứng dụng nặng 20GB, vì hệ điều hành chỉ nạp phần đang dùng vào RAM, phần còn lại nằm chờ ở ổ đĩa.

**Analogy:** giống một bàn làm việc nhỏ (RAM) và một tủ hồ sơ lớn ở phòng bên (đĩa). Bạn không bê cả tủ hồ sơ lên bàn — chỉ lấy đúng tài liệu đang cần đọc. Cần tài liệu khác thì cất tài liệu cũ lại, đi lấy tài liệu mới. Chuyện "đi lấy" đó chính là page fault.

**Ví dụ nhỏ nhất:** một chương trình có đoạn code xử lý lỗi hiếm khi chạy — nếu không có bộ nhớ ảo, đoạn code đó vẫn chiếm RAM suốt dù gần như không bao giờ dùng tới. Có bộ nhớ ảo, nó chỉ được nạp lúc thực sự xảy ra lỗi.

**Định nghĩa hình thức:**
> Bộ nhớ ảo (virtual memory) là kỹ thuật cho phép thực thi một tiến trình mà không cần nạp toàn bộ tiến trình đó vào bộ nhớ vật lý.

**Ưu điểm:** nhiều tiến trình chạy đồng thời hơn, tiến trình có thể lớn hơn RAM thực, giảm gánh nặng cho lập trình viên. Không gian trên đĩa dùng để tráo đổi gọi là **swap space** — Linux dùng swap partition, Windows dùng `pagefile.sys`.

---

### 2. Demand paging — cơ chế nạp trang theo yêu cầu

**Trực giác:** trang chỉ được nạp vào RAM đúng lúc bị đụng tới, không nạp trước.

**Analogy:** giống streaming video thay vì tải cả file về máy trước khi xem — chỉ tải đoạn sắp phát.

**Ví dụ nhỏ nhất:** page table có một bit gọi là valid bit. Khi CPU truy cập một địa chỉ mà trang tương ứng có valid bit = invalid (chưa nằm trong RAM), phần cứng phát sinh ngắt gọi là **page-fault trap**, gọi vào **page-fault service routine (PFSR)** của hệ điều hành.

**PFSR xử lý theo 3 bước:**
1. Chuyển tiến trình đang gây lỗi về trạng thái `blocked`.
2. Gửi yêu cầu đọc đĩa để nạp trang cần vào một frame trống; trong lúc chờ I/O, CPU được giao cho tiến trình khác chạy.
3. Sau khi I/O xong, đĩa phát ngắt, PFSR cập nhật page table và chuyển tiến trình về `ready`.

Nếu **không có frame trống**, PFSR phải làm thêm bước thay trang trước bước 2: chọn một **victim page** (trang hy sinh) bằng giải thuật thay trang, ghi nó ra đĩa, cập nhật page table và frame table, rồi mới đọc trang mới cần vào.

**Định nghĩa hình thức:**
> Demand paging: các trang của tiến trình chỉ được nạp vào bộ nhớ chính khi được tham chiếu (yêu cầu), không nạp trước.

---

### 3. Giải thuật thay trang (Page Replacement Algorithms)

**Trực giác:** khi RAM đầy và cần chỗ cho trang mới, phải chọn "đuổi" trang nào ra — chọn sai thì phải nạp lại nhiều lần, tốn thời gian.

**Analogy:** tủ lạnh đầy đồ, muốn cho món mới vào phải bỏ bớt món cũ ra — bỏ món nào để lần sau đỡ phải mua lại là bài toán y hệt việc chọn victim page.

**Mục tiêu chung:** số lượng page-fault nhỏ nhất, đánh giá bằng cách chạy giải thuật trên một **chuỗi tham chiếu bộ nhớ** (memory reference string) cụ thể.

#### 3.1 FIFO — First In First Out

**Trực giác:** đuổi trang nào ở lâu nhất trong RAM, bất kể có đang dùng hay không.

**Ví dụ nhỏ nhất:** chuỗi tham chiếu `7,0,1,2,0,3,0,4,2,3,0,3,2,1,2,0,1,7,0,1`, 3 khung trang trống ban đầu → **15 lần page fault** (đếm số dấu `*` trong bảng slide trang 25).

**Nhược điểm nổi bật — Nghịch lý Belady (Belady's Anomaly):** tăng số frame cấp cho tiến trình *lẽ ra* phải giảm page fault, nhưng với FIFO có trường hợp tăng frame lại làm **tăng** page fault. Ví dụ slide: chuỗi `1,2,3,4,1,2,5,1,2,3,4,5` — dùng 3 khung trang cho 9 lỗi trang, dùng 4 khung trang lại cho 10 lỗi trang.

#### 3.2 OPT — Optimal (tối ưu lý thuyết)

**Trực giác:** đuổi trang nào mà lần tới nó được dùng là **xa nhất trong tương lai**.

**Vấn đề:** muốn biết "xa nhất trong tương lai" thì phải biết trước cả chuỗi tham chiếu tương lai — điều không thể trong hệ thống thực. OPT chỉ dùng để làm chuẩn so sánh (lower bound), không cài đặt được thực tế.

**Ví dụ nhỏ nhất:** cùng chuỗi tham chiếu như FIFO ở trên, OPT chỉ tạo ra **9 lần page fault** — ít hơn hẳn FIFO (15 lần).

#### 3.3 LRU — Least Recently Used

**Trực giác:** đuổi trang **lâu nhất chưa được dùng tới** (không phải lâu nhất nằm trong RAM như FIFO) — dựa trên giả định trang ít dùng gần đây thì cũng ít khả năng dùng sắp tới.

**Ví dụ nhỏ nhất:** cùng chuỗi tham chiếu, LRU cho **12 lần page fault** — giữa FIFO (15) và OPT (9), gần với tối ưu hơn FIFO nhiều.

**Đánh đổi:** LRU cần phần cứng ghi lại thời điểm tham chiếu mỗi trang, tốn chi phí tìm kiếm trang LRU mỗi lần page fault → ít CPU hỗ trợ đủ phần cứng cho LRU "thuần".

**Bảng tổng hợp (theo ví dụ slide, chuỗi giống nhau, 3 khung trang):**

| Giải thuật | Cần biết trước tương lai? | Số page fault (ví dụ slide) |
|---|---|---|
| OPT | Có (không khả thi thực tế) | 9 |
| LRU | Không | 12 |
| FIFO | Không | 15 |

> ❓ **CẦN XÁC MINH:** slide không nói rõ giải thuật nào giảng viên nhấn mạnh sẽ ra thi — không có transcript để xác nhận.

---

### 4. Cấp phát Frames (Frame Allocation)

**Trực giác:** hệ điều hành phải quyết định chia bao nhiêu frame RAM cho mỗi tiến trình — chia ít quá thì tiến trình đó page fault liên tục, chia nhiều quá thì các tiến trình khác không đủ chỗ chạy (giảm mức độ đa chương — multiprogramming).

**Analogy:** giống chia ngân sách phòng ban trong công ty — phòng nào cũng cần đủ tiền hoạt động, nhưng ngân sách tổng thì có hạn.

**Hai chiến lược:**
- **Cấp phát tĩnh (fixed-allocation):** số frame cố định ngay từ lúc nạp tiến trình.
  - *Chia đều:* ví dụ có 100 frame, 5 tiến trình → mỗi tiến trình 20 frame.
  - *Chia theo tỷ lệ kích thước:* công thức `a_i = (s_i / S) × m`, với `s_i` = kích thước tiến trình i, `S` = tổng kích thước mọi tiến trình, `m` = tổng số frame hệ thống.
    - Ví dụ slide: `m=64`, `s1=10`, `s2=127` → `a1 = (10/137)×64 ≈ 5`, `a2 = (127/137)×64 ≈ 59`.
  - *Chia theo độ ưu tiên.*
- **Cấp phát động (variable-allocation):** số frame thay đổi khi tiến trình đang chạy — tỷ lệ page-fault cao thì cấp thêm frame, thấp thì giảm bớt. Tốn thêm chi phí để hệ điều hành theo dõi từng tiến trình.

---

### 5. Thrashing — hiện tượng trì trệ hệ thống

**Trực giác:** khi một tiến trình không có đủ frame, nó liên tục page fault, dành phần lớn thời gian đi "đổi trang" thay vì thực sự chạy — giống như càng cố làm nhiều việc thì càng làm được ít việc.

**Analogy:** một người ôm quá nhiều việc cùng lúc, cứ chuyển qua chuyển lại giữa các việc mà chẳng việc nào xong — công sức đổ hết vào việc "chuyển ngữ cảnh" chứ không phải làm việc thật.

**Định nghĩa hình thức:**
> Thrashing: hiện tượng các trang nhớ của một tiến trình bị hoán chuyển (swap in/out) vào/ra liên tục, khiến CPU utilization giảm mạnh dù mức độ đa chương (degree of multiprogramming) tăng.

Đồ thị slide cho thấy: CPU utilization tăng dần theo mức đa chương, đạt đỉnh, rồi **sụp đột ngột** khi vượt một ngưỡng — đó là điểm bắt đầu thrashing.

#### Nguyên lý Locality

**Trực giác:** trong một khoảng thời gian ngắn, một tiến trình chỉ đụng tới một nhóm nhỏ các trang gần nhau (locality), rồi sau đó chuyển sang nhóm khác.

**Định nghĩa hình thức:**
> Locality là tập các trang được tham chiếu gần nhau về mặt thời gian/không gian trong quá trình thực thi.

Thrashing xảy ra khi: `Σ (kích thước locality của mọi tiến trình) > kích thước bộ nhớ`.

#### Giải pháp Working Set

**Trực giác:** thay vì đoán mò, hệ điều hành theo dõi "tập làm việc" — những trang tiến trình *thực sự* vừa dùng trong một cửa sổ thời gian gần đây — để cấp đúng số frame cần thiết.

**Định nghĩa hình thức:**
> Working set `WS_i` của tiến trình `P_i` là tập các trang được tham chiếu trong Δ lần tham chiếu gần nhất (Δ = khoảng thời gian tham chiếu, working-set window).
> `WSS_i` (working-set size) = số lượng trang trong `WS_i`.

**Ví dụ nhỏ nhất (từ slide, Δ=10):**
chuỗi tham khảo: `...2 6 1 5 7 7 7 7 5 1 6 2 3 4 1 2 3 4 4 4 3 4 3 4 4 4 1 3 2 3 4 4 4 3 4 4 4...`
- Tại thời điểm t1: `WS(t1) = {1,2,5,6,7}` → `WSS(t1) = 5`
- Tại thời điểm t2: `WS(t2) = {3,4}` → `WSS(t2) = 2`

**Ảnh hưởng của Δ:**
- Δ quá nhỏ → không bao phủ hết một locality thật sự.
- Δ quá lớn → gộp luôn nhiều locality khác nhau, mất ý nghĩa "đang dùng gần đây".
- Δ = ∞ → bằng tất cả các trang từng dùng (vô nghĩa để giới hạn).

**Áp dụng:** đặt `D = Σ WSS_i` (tổng working-set size mọi tiến trình trong hệ thống).
- Nếu `D > m` (số frame hệ thống có) → có nguy cơ thrashing → hệ điều hành phải **tạm dừng bớt một tiến trình** (swap ra đĩa, thu hồi frame) để giữ `D ≤ m`.
- Lúc khởi tạo tiến trình mới, cấp ngay số frame bằng đúng working-set size ước tính của nó.

---

## Bảng tổng hợp

| Khái niệm | Ý nghĩa cốt lõi | Đánh đổi |
|---|---|---|
| Demand paging | Chỉ nạp trang khi cần | Có page fault, cần PFSR xử lý |
| FIFO | Đuổi trang cũ nhất trong RAM | Đơn giản nhưng có Nghịch lý Belady |
| OPT | Đuổi trang xa nhất trong tương lai | Không cài đặt được thực tế, chỉ để so sánh |
| LRU | Đuổi trang lâu nhất chưa dùng | Cần hỗ trợ phần cứng, tốn chi phí tìm kiếm |
| Fixed-allocation | Frame cố định từ lúc nạp | Không thích ứng khi tiến trình đổi hành vi |
| Variable-allocation | Frame thay đổi theo tỷ lệ page-fault | Tốn chi phí giám sát |
| Thrashing | RAM không đủ → page fault liên tục | CPU utilization sụp đổ |
| Working set | Tập trang tiến trình đang thực sự dùng | Phải chọn đúng Δ |

---

## Sơ đồ

```
Page fault xảy ra (valid bit = invalid)
        │
        ▼
  Ngắt page-fault trap → gọi PFSR
        │
        ▼
  Tiến trình → trạng thái blocked
        │
        ▼
  Có frame trống? ──── Không ──▶ Chọn victim page (FIFO/OPT/LRU)
        │ Có                          │
        │                       Ghi victim ra đĩa,
        │                       cập nhật page table
        │                             │
        ▼◀────────────────────────────┘
  Đọc trang cần từ đĩa vào frame trống
        │
        ▼
  Cập nhật page table, frame table
        │
        ▼
  Tiến trình → trạng thái ready → chạy tiếp
```

```
CPU utilization
   ▲
   │         ___----___
   │      _-'           `-.
   │    ,'                  \
   │  ,'                     \  ← thrashing bắt đầu
   │,'                         \
   └──────────────────────────────▶ degree of multiprogramming
```

---

## Gợi ý thi

> Không có — không có transcript nên không bắt được lời dặn dò trực tiếp của giảng viên trong buổi này.

---

## Deadline phát sinh

Không có — slide và bối cảnh buổi học không đề cập deadline nào mới.

---

## Chỗ chưa rõ

> ❓ **CẦN XÁC MINH:** Toàn bộ note dựa trên slide, không có transcript. Chưa biết giảng viên có nhấn mạnh phần nào sẽ thi, có ví dụ thực tế nào ngoài slide, hay có giải bài tập cuối slide (trang 49) trên lớp hay không.
>
> ❓ **CẦN XÁC MINH:** Bài tập ở trang 49 slide (`1,2,3,4,2,1,5,6,2,1,2,3,7,6,3,2,1`, 4 khung trang, tính LRU/FIFO/OPT) — không rõ đây là bài tập về nhà hay bài tập tại lớp, không rõ deadline.

---

## Tự kiểm tra

**1.** Vì sao Demand Paging cần một bit trạng thái (valid bit) trong page table?

<details><summary>Đáp án</summary>

Để phần cứng biết trang tương ứng có đang nằm trong RAM hay không mà không cần tra cứu thêm — nếu invalid thì gây page-fault trap để hệ điều hành nạp trang đó vào.

</details>

**2.** Nghịch lý Belady là gì, và giải thuật nào trong ba giải thuật (FIFO, OPT, LRU) mắc phải nó theo slide?

<details><summary>Đáp án</summary>

Là hiện tượng tăng số frame cấp cho tiến trình lại làm tăng số page fault thay vì giảm. FIFO là giải thuật mắc lỗi này (ví dụ slide: 3 frame → 9 lỗi, 4 frame → 10 lỗi).

</details>

**3.** Vì sao giải thuật OPT không thể cài đặt trong hệ thống thực?

<details><summary>Đáp án</summary>

Vì OPT cần biết trước toàn bộ chuỗi tham chiếu bộ nhớ trong tương lai để chọn trang xa nhất sẽ được dùng lại — điều không thể xác định trước khi tiến trình đang chạy. OPT chỉ dùng làm mốc so sánh lý thuyết.

</details>

**4.** Thrashing xảy ra khi điều kiện nào về locality và bộ nhớ được thoả?

<details><summary>Đáp án</summary>

Khi tổng kích thước locality của tất cả tiến trình đang chạy (Σ size of locality) lớn hơn kích thước bộ nhớ vật lý sẵn có.

</details>

**5.** Working-set size (WSS) khác gì so với số frame cố định cấp theo chiến lược fixed-allocation?

<details><summary>Đáp án</summary>

WSS được đo động dựa trên hành vi thực tế gần đây của tiến trình (trong cửa sổ Δ), phản ánh đúng nhu cầu bộ nhớ tại từng thời điểm. Fixed-allocation cấp một số frame cố định ngay từ đầu, không đổi theo hành vi thực tế của tiến trình khi chạy.

</details>

---

## Liên kết

- Khái niệm dùng chung: [`knowledge-base/`](../../../../knowledge-base/)
- Ghi chú quan trọng của môn: [`../IMPORTANT_NOTES.md`](../IMPORTANT_NOTES.md)
