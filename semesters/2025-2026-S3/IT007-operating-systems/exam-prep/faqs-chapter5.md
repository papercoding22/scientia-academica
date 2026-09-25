# FAQ nhanh — Chương 5: Process synchronization

Câu hỏi ngắn, trả lời nhanh khi ôn Chương 5. Xem thêm [Lecture L05](../lectures/L05-process-synchronization.md) và [hướng dẫn các câu Chương 5 trong đề mẫu](chapter5-exam-study-guide.md).

---

## Mục lục

1. [bounded waiting là gì?](#q1-bounded-waiting-là-gì)
2. [Producer-Consumer là gì?](#q2-producer-consumer-là-gì)

---

## Q1. bounded waiting là gì?

**Bounded waiting (chờ có giới hạn)** nghĩa là sau khi một tiến trình yêu cầu vào critical section (CS), phải có một giới hạn hữu hạn về **số lần các tiến trình khác được vào CS trước khi yêu cầu đó được phục vụ**. Mục tiêu là tránh để một tiến trình bị vượt lượt vô hạn, dẫn đến starvation (đói tài nguyên).

**Liên hệ đời thường:** giống xếp hàng — bạn có thể phải chờ, nhưng không thể để người khác liên tục chen lên trước khiến bạn không bao giờ tới lượt. Bounded waiting không bắt buộc phải phục vụ đúng FIFO; điều quan trọng là số lượt được phép vượt trước phải có giới hạn.

**Ví dụ:** giả sử một lời giải bảo đảm giới hạn `k = 2`. Khi P0 đã xin vào CS, P1 và P2 chỉ được vào **tổng cộng tối đa 2 lần** trước khi P0 được vào. Đây là giới hạn giả định để minh họa, không phải mọi thuật toán đều có `k = 2`.

```text
P0 xin vào → P1 vào/ra → P2 vào/ra → P0 được vào
             lượt 1       lượt 2
```

Nếu P1 và P2 cứ thay nhau vào mãi, còn P0 chờ vô hạn, bounded waiting bị vi phạm dù hệ thống vẫn có tiến trình đang làm việc.

**Đừng nhầm:**

- **Progress:** việc xét cho tiến trình vào CS không bị trì hoãn vô hạn khi CS trống và có tiến trình muốn vào; tiến trình ở ngoài không được cản người muốn vào.
- **Bounded waiting:** xét quyền lợi của **từng tiến trình đã yêu cầu**, không để nó bị vượt lượt vô hạn.
- Giới hạn số lượt **không tự cho biết phải chờ bao nhiêu giây**; muốn có giới hạn thời gian thực còn cần giả thiết về scheduler và thời gian chạy của CS.

**Nguồn:** [C5-1, slide 21 và 25](../materials/slides/Copy%20of%20%23Week07-Chapter5-1%202024.pdf) diễn đạt là chờ trong khoảng có hạn định, tránh starvation. Cách phát biểu bằng số lượt vượt trước được làm rõ ở mục 2.2 của [hướng dẫn ôn Chương 5](chapter5-exam-study-guide.md); ví dụ `k = 2` là minh họa tự dựng.

## Q2. Producer-Consumer là gì?

**Producer–Consumer** là mô hình một bên **tạo dữ liệu/công việc**, bên kia **lấy dữ liệu/công việc đó để xử lý**, thông qua một buffer (vùng đệm) dùng chung. Buffer thường được tổ chức thành queue (hàng đợi), giúp hai bên hoạt động với tốc độ khác nhau mà không phải bàn giao trực tiếp từng phần tử.

**Liên hệ đời thường:** đầu bếp là Producer, quầy đặt món là buffer, nhân viên phục vụ lấy món đi giao là Consumer. Có thể có nhiều đầu bếp và nhiều người phục vụ.

```text
Producer                   Buffer / queue                   Consumer
Tạo công việc ── thêm ──→ [A] [B] [C] ── lấy từng việc ──→ Xử lý
```

**Ví dụ frontend — minh họa tự dựng:** người dùng chọn ảnh; tác vụ tiếp nhận đưa từng ảnh vào queue, các upload worker lấy ảnh ra để gửi lên server. “Consumer lấy ảnh” là lấy một công việc để xử lý, không phải người dùng tải ảnh về.

Giả sử queue chỉ chứa **3 ảnh đang chờ**, ban đầu rỗng:

1. Consumer muốn lấy ảnh phải chờ vì chưa có việc.
2. Producer thêm A, B, C; nếu chưa có worker lấy ra, queue đã đầy.
3. Producer muốn thêm D phải chờ còn chỗ.
4. Consumer lấy A ra → một chỗ trống xuất hiện → Producer có thể thêm D trong khi Consumer upload A.

Giới hạn 3 ở đây là số ảnh **đang chờ trong queue**, không phải số upload đang chạy. Đây là biến thể **bounded-buffer (buffer có sức chứa hữu hạn)** của Producer–Consumer, cũng là bài toán đang học ở Chương 5.

**Ba yêu cầu đồng bộ trong lời giải semaphore của bài:**

| Yêu cầu | Công cụ | Vai trò |
|---|---|---|
| Producer không thêm khi buffer đầy | `empty`, khởi tạo bằng sức chứa | Xin một chỗ trống trước khi thêm |
| Consumer không lấy khi buffer rỗng | `full`, khởi tạo 0 nếu buffer rỗng | Chờ có một phần tử trước khi lấy |
| Thao tác sửa buffer và biến đếm không xung đột | `mutex`, ban đầu mở | Bảo vệ critical section (đoạn code truy cập dữ liệu chung) |

Trong lời giải này, chờ `empty`/`full` **trước khi giữ mutex**. Mutex chỉ bảo vệ đoạn thêm/lấy và cập nhật dữ liệu chung; phần tạo hoặc xử lý công việc có thể diễn ra bên ngoài khóa. Producer–Consumer là **bài toán/mô hình phối hợp**; mutex và semaphore là **công cụ giải quyết** nó.

**Nguồn:** [Lecture L05, mục 10 — Bài toán bounded-buffer](../lectures/L05-process-synchronization.md#10-bài-toán-bounded-buffer), dẫn slide C5-3 s5–s10; lỗi thiếu mutex ở s11–s13. Ví dụ quán ăn và upload là minh họa bổ sung, không phải code triển khai queue React.
