# IT007 — Flashcard

Bản đọc trong repo. Bản import Anki: [`flashcards.csv`](flashcards.csv)

| | |
|---|---|
| Số thẻ | 50 |
| Cập nhật | 2026-09-23 (buổi 3, buổi 4, buổi 5, buổi 10) |

> Thẻ được sinh ra khi xử lý note bài giảng. Mỗi lần thêm thẻ vào đây thì
> **đồng thời** thêm vào `flashcards.csv`, hai file phải khớp nhau.

---

## Tag

- `L03` — Quản lý tiến trình (Chương 3)
- `L04` — CPU scheduling (Chương 4)
- `L05` — Đồng bộ tiến trình (Chương 5)
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

> Nguồn thẻ L04: [note chương 4 và bảng tài liệu S1/S2/S3](../lectures/L04-cpu-scheduling.md#nguồn-và-cách-đọc). Số trang tính từ 1.

### Thẻ L04-1
**Mặt trước:** CPU-bound và I/O-bound khác nhau thế nào về CPU burst?
**Mặt sau:** CPU-bound dành nhiều thời gian tính toán, thường có burst dài. I/O-bound thường có burst ngắn xen thời gian chờ I/O; lúc một process block, scheduler có thể chọn process Ready khác.
**Tag:** L04
**Nguồn:** S1 tr. 5–8.

### Thẻ L04-2
**Mặt trước:** Short-term scheduler và dispatcher khác nhau ở đâu?
**Mặt sau:** Scheduler chọn tác vụ Ready được chạy tiếp. Dispatcher thực hiện bàn giao: chuyển context, chuyển chế độ phù hợp và tiếp tục tại program counter đã lưu. Dispatch latency là thời gian bàn giao.
**Tag:** L04
**Nguồn:** S1 tr. 16–18; L04 phân biệt tên dispatcher.

### Thẻ L04-3
**Mặt trước:** Preemption chuyển process sang trạng thái nào? I/O hoàn tất có làm process chạy ngay không?
**Mặt sau:** Preemption đưa Running về Ready. I/O hoàn tất đưa Waiting về Ready; process phải được scheduler chọn mới chạy. Chính sách non-preemptive không thu hồi CPU chỉ vì có process mới Ready.
**Tag:** L04
**Nguồn:** S1 tr. 24–26.

### Thẻ L04-4
**Mặt trước:** AT=2, ST=4, CT=12, tổng BT=5, không block: RT, TAT, WT bằng bao nhiêu?
**Mặt sau:** RT=ST−AT=2; TAT=CT−AT=10; WT=TAT−BT=5. Nếu có block, phải cộng riêng các khoảng chờ Ready, không tính thời gian block vào WT.
**Tag:** L04
**Nguồn:** S1 tr. 20–22; ví dụ tự dựng trong L04.

### Thẻ L04-5
**Mặt trước:** FCFS khiến nhiều việc ngắn chờ lâu trong tình huống nào?
**Mặt sau:** Một CPU burst dài đứng trước nhiều burst ngắn. FCFS phục vụ FIFO và non-preemptive nên các việc ngắn phải đợi burst dài kết thúc hoặc block.
**Tag:** L04
**Nguồn:** S1 tr. 29–34.

### Thẻ L04-6
**Mặt trước:** P1 đến lúc 0 cần 8, P2 đến lúc 1 cần 2: SJF và SRTF cho lịch nào?
**Mặt sau:** SJF: P1 [0,8), P2 [8,10). SRTF: P1 [0,1), P2 [1,3), P1 [3,10), vì lúc 1 P1 còn 7 lớn hơn 2 của P2. Chỉ xét các process đã đến.
**Tag:** L04
**Nguồn:** S2 tr. 4–17; ví dụ tự dựng trong L04.

### Thẻ L04-7
**Mặt trước:** Exponential averaging dự đoán CPU burst thế nào? α lớn có ý nghĩa gì?
**Mặt sau:** τ[n+1]=α×t[n]+(1−α)×τ[n], với 0≤α≤1. α lớn coi trọng burst vừa đo hơn. Đo mới 6, dự đoán cũ 10, α=0.5 thì dự đoán mới là 8.
**Tag:** L04
**Nguồn:** S2 tr. 18–19.

### Thẻ L04-8
**Mặt trước:** Priority scheduling có luôn chọn con số priority nhỏ nhất và luôn preemptive không?
**Mặt sau:** Không. Phải đọc quy ước số của đề: số nhỏ hay lớn biểu thị ưu tiên cao. Priority scheduling có cả biến thể preemptive lẫn non-preemptive.
**Tag:** L04
**Nguồn:** S2 tr. 21–25.

### Thẻ L04-9
**Mặt trước:** Starvation là gì và aging xử lý nó như thế nào?
**Mặt sau:** Starvation là một tác vụ đủ điều kiện nhưng có thể bị bỏ qua vô hạn. Aging tăng dần mức ưu tiên theo thời gian chờ. Nếu số nhỏ ưu tiên cao thì phải giảm số priority; cần quy tắc xử lý cùng mức.
**Tag:** L04
**Nguồn:** S2 tr. 23, 46.

### Thẻ L04-10
**Mặt trước:** HRRN chọn theo công thức nào? Ratio đó có phải response time không?
**Mặt sau:** Chọn (WT+BT)/BT = 1+WT/BT lớn nhất, BT>0; HRRN chuẩn là non-preemptive. Đây là response ratio, không phải RT; ký hiệu RR ở công thức này cũng không phải Round Robin.
**Tag:** L04
**Nguồn:** S2 tr. 39.

### Thẻ L04-11
**Mặt trước:** RR: quantum rất lớn hoặc quá nhỏ ảnh hưởng gì? q=20 ms, switch=5 ms thì overhead bao nhiêu?
**Mặt sau:** q đủ lớn khiến RR giống FCFS. q nhỏ tạo nhiều lượt nhưng tăng chi phí chuyển context. Một chu kỳ chạy đủ 20 ms rồi chuyển 5 ms có overhead 5/(20+5)=20%.
**Tag:** L04
**Nguồn:** S2 tr. 27–37.

### Thẻ L04-12
**Mặt trước:** RR: process mới đến đúng lúc process đang chạy hết quantum thì xếp queue thế nào?
**Mặt sau:** Phải theo quy ước của đề, hoặc ghi rõ giả định. Ví dụ S2 tr. 28 xếp P5 mới đến tại lúc 12 trước P1 vừa hết quantum. Thứ tự này có thể làm thay đổi Gantt.
**Tag:** L04
**Nguồn:** S2 tr. 28, 52.

### Thẻ L04-13
**Mặt trước:** MQ và MLFQ khác nhau ở khả năng chuyển queue thế nào?
**Mặt sau:** MQ gán process vào nhóm cố định. MLFQ cho phép chuyển queue theo hành vi CPU burst hoặc thời gian chờ; thường hạ tác vụ dùng hết lượt và có thể nâng tác vụ chờ lâu bằng aging.
**Tag:** L04
**Nguồn:** S2 tr. 41–48.

### Thẻ L04-14
**Mặt trước:** Vì sao load balancing nhiều CPU phải cân nhắc processor affinity?
**Mặt sau:** Chuyển thread từ CPU bận sang CPU rỗi giúp cân tải nhưng có thể mất cache locality. Soft affinity cố giữ CPU cũ; hard affinity giới hạn tập CPU được phép chạy.
**Tag:** L04
**Nguồn:** S3 tr. 6–15.

### Thẻ L04-15
**Mặt trước:** RM và EDF chọn tác vụ theo tiêu chí nào? Khi nào dùng được điều kiện EDF Σ(C/T)≤1?
**Mặt sau:** RM ưu tiên chu kỳ T ngắn; EDF ưu tiên absolute deadline gần nhất. Điều kiện Σ(C/T)≤1 áp dụng cho tác vụ periodic độc lập, D=T, một CPU, preemptive và bỏ qua overhead.
**Tag:** L04
**Nguồn:** S3 tr. 18–22.

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

### Thẻ L05-1
**Mặt trước:** Race condition là gì?
**Mặt sau:** Hiện tượng các tiến trình cùng truy cập đồng thời dữ liệu chia sẻ, kết quả cuối phụ thuộc thứ tự thực thi. Có thể làm dữ liệu sai, không nhất quán.
**Tag:** L05
**Nguồn:** C5-1 s15–16.

### Thẻ L05-2
**Mặt trước:** 3 yêu cầu mà lời giải bài toán critical section phải đảm bảo?
**Mặt sau:** (1) Mutual exclusion: P đang trong CS thì không Q nào trong CS. (2) Progress: tiến trình dừng bên ngoài CS không được cản người khác vào CS. (3) Bounded waiting: chỉ phải chờ vào CS trong thời gian có hạn định, không starvation.
**Tag:** L05
**Nguồn:** C5-1 s21–25.

### Thẻ L05-3
**Mặt trước:** Giải thuật Peterson thuộc nhóm giải pháp nào và dùng những biến chia sẻ nào?
**Mặt sau:** Giải pháp phần mềm (cùng nhóm Bakery, Dekker). Dùng int turn và boolean flag[2]. Đạt cả 3 yêu cầu cho 2 tiến trình.
**Tag:** L05
**Nguồn:** C5-1 s27, s42–46.

### Thẻ L05-4
**Mặt trước:** Vì sao Peterson có thể sai trên kiến trúc hiện đại và sửa bằng gì?
**Mặt sau:** CPU/compiler có thể sắp xếp lại các thao tác độc lập (gán flag[] và turn) → cả hai cùng vào CS. Sửa bằng memory barrier.
**Tag:** L05
**Nguồn:** C5-1 s47–51.

### Thẻ L05-5
**Mặt trước:** Giải pháp dùng một biến turn cho 2 tiến trình vi phạm yêu cầu nào?
**Mặt sau:** Đạt mutual exclusion nhưng vi phạm progress và bounded waiting: tiến trình đang chạy remainder section rất lâu vẫn giữ turn, chặn tiến trình kia vào CS.
**Tag:** L05
**Nguồn:** C5-1 s34–36.

### Thẻ L05-6
**Mặt trước:** Spinlock là gì, nhược điểm chính?
**Mặt sau:** Mutex cài bằng vòng while(!available) — busy waiting liên tục kiểm tra khoá, lãng phí CPU.
**Tag:** L05
**Nguồn:** C5-2 s8.

### Thẻ L05-7
**Mặt trước:** Mutex lock không busy waiting hoạt động thế nào?
**Mặt sau:** Khoá đang bị khoá → block(): đưa tiến trình vào hàng đợi, trạng thái ngủ. Khi khoá được mở → wakeup(): đưa một tiến trình từ hàng đợi về ready queue.
**Tag:** L05
**Nguồn:** C5-2 s10–11.

### Thẻ L05-8
**Mặt trước:** wait(S) và signal(S) của semaphore làm gì với giá trị S, dùng khi nào?
**Mặt sau:** wait (P): S không dương thì chờ, vào được thì giảm S đi 1 — dùng khi muốn sử dụng tài nguyên. signal (V): tăng S lên 1 — dùng khi trả tài nguyên.
**Tag:** L05
**Nguồn:** C5-2 s15–16.

### Thẻ L05-9
**Mặt trước:** Counting semaphore khác binary semaphore thế nào?
**Mặt sau:** Counting: giá trị nguyên không giới hạn. Binary: chỉ 0 hoặc 1, tác dụng giống mutex. Counting semaphore dùng được như binary semaphore.
**Tag:** L05
**Nguồn:** C5-2 s26.

### Thẻ L05-10
**Mặt trước:** Semaphore cài bằng hàng đợi có S->value = −4. Nghĩa là gì?
**Mặt sau:** Có 4 tiến trình đang bị block trong hàng đợi của S. Khi value ≥ 0 thì value là số lần còn gọi wait mà không bị block.
**Tag:** L05
**Nguồn:** C5-2 s38.

### Thẻ L05-11
**Mặt trước:** Monitor là gì? x.signal() khác signal() của semaphore ở đâu?
**Mặt sau:** Kiểu dữ liệu trừu tượng gói biến nội bộ + thủ tục + code khởi tạo, chỉ một tiến trình ở trong monitor tại một thời điểm. x.signal() không có tiến trình nào chờ thì không có tác dụng, còn signal() của semaphore luôn tăng giá trị.
**Tag:** L05
**Nguồn:** C5-2 s44–48.

### Thẻ L05-12
**Mặt trước:** Liveness là gì? Kể 3 dạng lỗi liveness trong slide.
**Mặt sau:** Tập các đặc điểm hệ thống phải thỏa mãn để đảm bảo tiến trình thực sự chạy. Deadlock, starvation, priority inversion (giải bằng priority inheritance protocol).
**Tag:** L05
**Nguồn:** C5-2 s51–53.

### Thẻ L05-13
**Mặt trước:** Bounded-buffer dùng những semaphore nào, khởi tạo bao nhiêu?
**Mặt sau:** empty = n (số chỗ có thể thêm), full = 0 (số phần tử có thể xoá), mutex = 1 (bảo vệ CS truy cập buffer và count).
**Tag:** L05
**Nguồn:** C5-3 s9–10.

### Thẻ L05-14
**Mặt trước:** Readers-writers biến thể 1 và 2: ai có thể bị starvation?
**Mặt sau:** Biến thể 1 (ưu tiên Readers): Writers có thể bị starvation. Biến thể 2 (ưu tiên Writers): Readers có thể bị starvation.
**Tag:** L05
**Nguồn:** C5-3 s17.

### Thẻ L05-15
**Mặt trước:** Dining-philosophers: khi nào deadlock và 3 cách tránh trong slide?
**Mặt sau:** Cả 5 triết gia cùng lúc cầm đũa trái. Tránh: tối đa 4 người ngồi, chỉ cầm khi cả 2 đũa sẵn sàng (cầm trong CS), bất đối xứng lẻ cầm trái trước và chẵn cầm phải trước. Starvation vẫn có thể xảy ra.
**Tag:** L05
**Nguồn:** C5-3 s26–27.

<!--
Mẫu:

### Thẻ 1
**Mặt trước:** <câu hỏi>
**Mặt sau:** <đáp án>
**Tag:** L01 concept
-->
