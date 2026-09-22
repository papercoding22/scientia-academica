# IT007 — Flashcard

Bản đọc trong repo. Bản import Anki: [`flashcards.csv`](flashcards.csv)

| | |
|---|---|
| Số thẻ | 20 |
| Cập nhật | 2026-09-22 (buổi 3, buổi 10) |

> Thẻ được sinh ra khi xử lý note bài giảng. Mỗi lần thêm thẻ vào đây thì
> **đồng thời** thêm vào `flashcards.csv`, hai file phải khớp nhau.

---

## Tag

- `L03` — Quản lý tiến trình (Chương 3)
- `L10` — Bộ nhớ ảo (Chương 8)

---

## Thẻ

### Thẻ L03-1
**Mặt trước:** PCB (Process Control Block) là gì và lưu những thông tin nào?
**Mặt sau:** Cấu trúc dữ liệu hệ điều hành dùng để lưu mọi thông tin cần thiết của một tiến trình: trạng thái, program counter, giá trị thanh ghi, thông tin định thời, quản lý bộ nhớ, thông tin I/O — phục vụ context switch.

### Thẻ L03-2
**Mặt trước:** 5 trạng thái cơ bản của một tiến trình là gì?
**Mặt sau:** New, Ready, Running, Waiting (blocked), Terminated.

### Thẻ L03-3
**Mặt trước:** Context switch là gì?
**Mặt sau:** Việc hệ điều hành lưu trạng thái tiến trình đang chạy vào PCB của nó, rồi nạp trạng thái đã lưu của tiến trình kế tiếp từ PCB tương ứng để tiếp tục thực thi.

### Thẻ L03-4
**Mặt trước:** Sự khác nhau giữa long-term scheduler và short-term scheduler?
**Mặt sau:** Long-term scheduler quyết định tiến trình nào được nạp vào bộ nhớ (kiểm soát mức đa chương), chạy không thường xuyên. Short-term scheduler chọn tiến trình nào trong ready queue được cấp CPU kế tiếp, chạy rất thường xuyên.

### Thẻ L03-5
**Mặt trước:** `fork()` làm gì, và giá trị trả về cho biết điều gì?
**Mặt sau:** Tạo tiến trình con là bản sao của tiến trình cha. Trả về >0: đang ở tiến trình cha (giá trị là PID con); =0: đang ở tiến trình con; <0: fork thất bại.

### Thẻ L03-6
**Mặt trước:** Họ hàm `exec()` làm gì, khác `fork()` ở điểm nào?
**Mặt sau:** Nạp đè một chương trình mới lên không gian địa chỉ của tiến trình gọi hàm, không tạo tiến trình mới (khác với fork() vốn nhân bản thành tiến trình con).

### Thẻ L03-7
**Mặt trước:** Hai mô hình IPC (Inter-Process Communication) cơ bản là gì? Khác nhau ở đâu?
**Mặt sau:** Shared memory (vùng nhớ dùng chung, các tiến trình tự lo đồng bộ) và Message passing (gửi/nhận thông điệp qua hàng đợi do nhân hệ điều hành quản lý).

### Thẻ L03-8
**Mặt trước:** Thread khác Process ở điểm cốt lõi nào?
**Mặt sau:** Thread là đơn vị thực thi nhỏ hơn process — nhiều thread trong cùng một process chia sẻ chung code/data/file, nhưng mỗi thread có stack và tập thanh ghi riêng.

### Thẻ L03-9
**Mặt trước:** 3 mô hình ánh xạ thread người dùng - thread hạt nhân, và mô hình nào phổ biến nhất?
**Mặt sau:** Many-to-One, One-to-One, Many-to-Many. One-to-One phổ biến nhất (Windows, Linux dùng) vì tính đồng thời tốt — một thread block không kéo cả tiến trình block.

### Thẻ L03-10
**Mặt trước:** Nêu 3 lợi ích chính của tiến trình đa luồng (multithreading)?
**Mặt sau:** Đáp ứng nhanh (không bị chặn toàn bộ khi một phần block), kinh tế (tạo/chuyển ngữ cảnh thread rẻ hơn process nhiều), khả năng mở rộng (chạy song song thật trên nhiều lõi CPU).

### Thẻ 1
**Mặt trước:** Bộ nhớ ảo (virtual memory) là gì?
**Mặt sau:** Kỹ thuật cho phép thực thi một tiến trình mà không cần nạp toàn bộ tiến trình đó vào bộ nhớ vật lý.

### Thẻ 2
**Mặt trước:** Demand paging là gì?
**Mặt sau:** Các trang của tiến trình chỉ được nạp vào bộ nhớ chính khi được tham chiếu (yêu cầu), không nạp trước.

### Thẻ 3
**Mặt trước:** Page-fault trap xảy ra khi nào?
**Mặt sau:** Khi CPU tham chiếu một trang có valid bit = invalid (trang không nằm trong RAM) → phần cứng gây ngắt, gọi Page-Fault Service Routine (PFSR).

### Thẻ 4
**Mặt trước:** 3 bước chính của PFSR khi xử lý page fault (có frame trống)?
**Mặt sau:** (1) Chuyển tiến trình về blocked. (2) Phát yêu cầu đọc đĩa nạp trang vào frame trống, CPU giao cho tiến trình khác. (3) Sau khi I/O xong, cập nhật page table, chuyển tiến trình về ready.

### Thẻ 5
**Mặt trước:** Giải thuật thay trang FIFO chọn victim page như thế nào?
**Mặt sau:** Chọn trang được nạp vào bộ nhớ sớm nhất (ở lâu nhất trong RAM), bất kể có đang được dùng hay không.

### Thẻ 6
**Mặt trước:** Nghịch lý Belady (Belady's Anomaly) là gì?
**Mặt sau:** Hiện tượng tăng số frame cấp cho tiến trình lại làm tăng số page fault thay vì giảm — xảy ra với FIFO.

### Thẻ 7
**Mặt trước:** Giải thuật OPT chọn victim page theo tiêu chí gì, và vì sao không cài đặt được thực tế?
**Mặt sau:** Chọn trang sẽ được tham chiếu trễ nhất trong tương lai. Không cài đặt được vì cần biết trước toàn bộ chuỗi tham chiếu tương lai.

### Thẻ 8
**Mặt trước:** Giải thuật LRU chọn victim page theo tiêu chí gì?
**Mặt sau:** Chọn trang có thời điểm tham chiếu gần nhất là lâu nhất (ít được dùng gần đây nhất).

### Thẻ 9
**Mặt trước:** Thrashing là gì, và điều kiện nào (theo locality) khiến nó xảy ra?
**Mặt sau:** Hiện tượng các trang nhớ của tiến trình bị hoán chuyển vào/ra liên tục, CPU utilization giảm mạnh. Xảy ra khi tổng kích thước locality của mọi tiến trình > kích thước bộ nhớ.

### Thẻ 10
**Mặt trước:** Working set WS_i và working-set size WSS_i là gì?
**Mặt sau:** WS_i là tập các trang được tham chiếu trong Δ lần tham chiếu gần nhất của tiến trình P_i. WSS_i là số lượng trang trong WS_i. Nếu tổng D = Σ WSS_i > số frame hệ thống m → nguy cơ thrashing.

<!--
Mẫu:

### Thẻ 1
**Mặt trước:** <câu hỏi>
**Mặt sau:** <đáp án>
**Tag:** L01 concept
-->
