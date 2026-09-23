# L04 — CPU scheduling (Định thời CPU)

| | |
|---|---|
| Môn | `IT007` Hệ điều hành |
| Buổi | 4 — tổng hợp chương 4 theo yêu cầu người dùng |
| Giảng viên | Nguyễn Thanh Thiện |
| Transcript | Không có; note dựa trên ba bộ slide bên dưới |
| Phạm vi | CPU scheduling, thread scheduling, nhiều CPU, real-time và ví dụ hệ điều hành |

> Không gán ngày học. Các analogy, ví dụ nhỏ và code Python là phần minh họa
> bổ sung; không coi là lời giảng được ghi lại. `L04` là số note được yêu cầu,
> không đồng nghĩa toàn bộ ba bộ slide được giảng trong một buổi.

---

## Mục lục

- [Nguồn và cách đọc](#nguồn-và-cách-đọc)
- [Tóm tắt một đoạn](#tóm-tắt-một-đoạn)
- [Nội dung chính](#nội-dung-chính)
  - [1. CPU burst và lý do cần scheduling](#1-cpu-burst-và-lý-do-cần-scheduling)
  - [2. Scheduler, dispatcher và thời điểm chọn lại](#2-scheduler-dispatcher-và-thời-điểm-chọn-lại)
  - [3. Đọc Gantt và tính response, turnaround, waiting time](#3-đọc-gantt-và-tính-response-turnaround-waiting-time)
  - [4. FCFS — ai đến trước chạy trước](#4-fcfs--ai-đến-trước-chạy-trước)
  - [5. SJF, SRTF và dự đoán CPU burst](#5-sjf-srtf-và-dự-đoán-cpu-burst)
  - [6. Priority, starvation, aging và HRRN](#6-priority-starvation-aging-và-hrrn)
  - [7. Round Robin và quantum](#7-round-robin-và-quantum)
  - [8. Multilevel Queue và Multilevel Feedback Queue](#8-multilevel-queue-và-multilevel-feedback-queue)
  - [9. Thread scheduling, nhiều CPU và affinity](#9-thread-scheduling-nhiều-cpu-và-affinity)
  - [10. Real-time scheduling — phần đọc thêm](#10-real-time-scheduling--phần-đọc-thêm)
  - [11. Linux, Windows và Solaris trong bộ slide](#11-linux-windows-và-solaris-trong-bộ-slide)
- [Bảng tổng hợp](#bảng-tổng-hợp)
- [Sơ đồ](#sơ-đồ)
- [Quy trình tự làm bài Gantt](#quy-trình-tự-làm-bài-gantt)
- [Chỗ cần lưu ý khi đối chiếu nguồn](#chỗ-cần-lưu-ý-khi-đối-chiếu-nguồn)
- [Gợi ý thi và deadline phát sinh](#gợi-ý-thi-và-deadline-phát-sinh)
- [Liên kết](#liên-kết)
- [Tự kiểm tra](#tự-kiểm-tra)

---

## Nguồn và cách đọc

Số trang dưới đây là **trang PDF, bắt đầu từ 1**, cũng khớp số slide hiển thị.

| Mã | Tài liệu gốc | Phạm vi đã đọc |
|---|---|---|
| S1 | [Copy of #Week05-Chapter4-1 2024.pdf](../materials/slides/Copy%20of%20%23Week05-Chapter4-1%202024.pdf) | 42 trang: nền tảng, tiêu chí, FCFS và ví dụ |
| S2 | [Copy of #Week06-Chapter4-2 2024.pdf](../materials/slides/Copy%20of%20%23Week06-Chapter4-2%202024.pdf) | 58 trang: các thuật toán, so sánh và bài tập |
| S3 | [Copy of #Week06-Chapter4-3 2024.pdf](../materials/slides/Copy%20of%20%23Week06-Chapter4-3%202024.pdf) | 46 trang: thread, nhiều CPU, real-time, Linux/Windows/Solaris |

Đọc mục 1–3 để biết **chọn ai, khi nào chọn, đo kết quả bằng gì**; mục 4–8
để làm Gantt; mục 9–11 để hiểu hệ thống thực tế. S3 đánh dấu real-time và
Solaris là **đọc thêm**; đây là nhãn trên slide, không phải xác nhận phạm vi thi.

## Tóm tắt một đoạn

CPU scheduling chọn tác vụ sẵn sàng nào được chạy tiếp, nhằm cân bằng độ phản
hồi, thời gian hoàn tất, hiệu suất và công bằng. Mỗi thuật toán khác nhau ở
tiêu chí chọn và thời điểm được phép lấy lại CPU. Khi làm bài, phải dựng lịch
theo các process **đã đến**, rồi tính response, turnaround và waiting time từ
lịch đó. Hệ thống có nhiều CPU còn phải cân bằng tải với lợi ích giữ dữ liệu
trong cache; hệ thống real-time thêm yêu cầu hoàn thành đúng deadline.

## Nội dung chính

### 1. CPU burst và lý do cần scheduling

**Trực giác:** nhiều việc cùng muốn chạy, nhưng một chỗ xử lý chỉ phục vụ được
một việc tại một thời điểm.

**Analogy:** một đầu bếp chuyển sang món khác trong lúc món đầu đang chờ lò,
thay vì đứng đợi và để mọi người cùng chậm.

**Ví dụ nhỏ:** P1 dùng CPU 2 ms rồi chờ đĩa 5 ms; P2 đang Ready có thể dùng CPU
trong lúc P1 Waiting. Khi P1 hết chờ, nó về Ready và cần được chọn lại.

**Định nghĩa:** CPU burst là một khoảng process cần thực thi trên CPU giữa
các lần chờ I/O. CPU-bound dành phần lớn thời gian cho tính toán; I/O-bound
thường có các CPU burst ngắn xen thời gian chờ I/O. CPU scheduling chọn từ
ready queue; một CPU logic chạy một thread tại một thời điểm.

**Code minh họa CPU-bound**, Python 3:

```python
print(sum(range(1, 1_000_001)))  # 500000500000
```

Chạy nhanh hay chậm không tự chứng minh workload là I/O-bound; phải xét nó
dành thời gian cho tính toán hay chờ thiết bị. Nguồn: S1, tr. 5–8, 16.

### 2. Scheduler, dispatcher và thời điểm chọn lại

**Trực giác:** chọn người tiếp theo và bàn giao chỗ làm cho người đó là hai việc.

**Analogy:** lễ tân gọi người kế tiếp; nhân viên thu dọn hồ sơ cũ rồi mở hồ sơ mới.

**Ví dụ nhỏ:** P1 đang Running, P2 ở Ready. Khi P1 chờ I/O, scheduler chọn P2;
dispatcher thực hiện bàn giao để P2 chạy đúng vị trí đã lưu.

**Định nghĩa và vai trò** — S1, tr. 10–18:

| Thành phần | Quyết định / công việc |
|---|---|
| Long-term scheduler | Chấp nhận công việc vào hệ thống; điều chỉnh mức đa chương, phối hợp CPU-bound và I/O-bound |
| Medium-term scheduler | Swap out / swap in để quản lý số process trong bộ nhớ |
| Short-term scheduler | Chọn process hoặc kernel thread trong ready queue để chạy tiếp |
| Dispatcher | Chuyển context, chuyển chế độ phù hợp và tiếp tục tại program counter đã lưu |

Dispatch latency là thời gian dừng tác vụ cũ và bắt đầu tác vụ được chọn.
Slide S1 tr. 18 mô tả các thao tác bàn giao dưới mục short-term scheduling;
note tách tên dispatcher để phân biệt **chọn** với **thực hiện bàn giao**.

**Non-preemptive (không thu hồi CPU giữa chừng):** giữ CPU đến khi kết thúc
CPU burst, block hoặc tự nhường. **Preemptive (có thể thu hồi CPU):** tác vụ
đang chạy có thể bị chuyển về Ready dù chưa hết burst.

| Sự kiện | Ý nghĩa đối với quyết định chọn lại |
|---|---|
| `Running → Waiting` hoặc `Terminated` | Tác vụ rời CPU; chọn tác vụ khác nếu có |
| `Running → Ready` | Ví dụ hết quantum; cần chọn lại theo chính sách |
| `New/Waiting → Ready` | Có thêm ứng viên; chính sách preemptive có thể thay tác vụ đang chạy |

Nguồn: S1, tr. 24–26. **Preemption đưa về Ready, không phải Waiting** — nối
với [chuỗi trạng thái ở L03](L03-process-management.md#bài-tập-bổ-sung--chuỗi-trạng-thái-tiến-trình).

### 3. Đọc Gantt và tính response, turnaround, waiting time

**Trực giác:** được bắt đầu sớm, xong sớm và ít phải xếp hàng là ba mục tiêu khác nhau.

**Analogy:** vào phòng khám, được gọi lần đầu chưa có nghĩa đã khám xong;
thời gian ngồi chờ cũng khác toàn bộ thời gian có mặt ở phòng khám.

**Ví dụ nhỏ:** P đến lúc 2, chạy `[4, 6)` rồi `[9, 12)`, không chờ I/O.
P được chạy lần đầu sau 2 đơn vị, hoàn tất sau 10 đơn vị, dùng CPU 5 đơn vị
và chờ Ready tổng cộng `2 + 3 = 5` đơn vị.

**Định nghĩa/công thức** — S1, tr. 20–22:

| Ký hiệu | Nghĩa |
|---|---|
| `AT` | Arrival time: thời điểm đến |
| `ST` | Start time: thời điểm được chạy lần đầu |
| `CT` | Completion/finishing time: thời điểm kết thúc |
| `BT` | Tổng thời gian cần CPU trong bài |
| `RT = ST − AT` | Response time: đợi đến lần chạy đầu |
| `TAT = CT − AT` | Turnaround time: từ khi đến đến khi xong |
| `WT = TAT − BT` | Waiting time trong bài chỉ gồm thời gian chạy CPU và chờ Ready |

Nếu có thời gian block, **không tính thời gian block vào WT**; hãy cộng các
khoảng ở Ready. S1 dùng `r, t₀, f, E` tương ứng `AT, ST, CT, BT`, dùng `F`
cho turnaround. **Thời điểm CT khác khoảng thời gian TAT**.

**Code** tính ví dụ trên:

```python
arrival, first_start, finish, burst = 2, 4, 12, 5
response = first_start - arrival
turnaround = finish - arrival
waiting = turnaround - burst  # Ví dụ này không có thời gian block
print(response, turnaround, waiting)  # 2 10 5
```

RT, WT, TAT thường cần giảm; throughput (số việc xong trên một đơn vị thời
gian) và CPU utilization thường cần tăng. Fairness yêu cầu tránh bỏ quên
các tác vụ. Các mục tiêu có thể xung đột, không có một lịch tốt nhất cho mọi tải.

### 4. FCFS — ai đến trước chạy trước

**Trực giác:** phục vụ theo thứ tự đến, giữ lượt đến khi xong phần đang làm.

**Analogy:** quầy tính tiền theo hàng; khách mua ít vẫn phải đợi khách mua nhiều phía trước.

**Ví dụ nhỏ:** P1, P2, P3 cùng đến lúc 0, vào queue theo thứ tự đó, BT lần lượt
`6, 2, 1`. Gantt: `0 — P1 — 6 — P2 — 8 — P3 — 9`.
WT lần lượt `0, 6, 8`; trung bình `14/3`.

**Định nghĩa:** First-Come, First-Served dùng FIFO và non-preemptive; lấy đầu
ready queue. Khi block, process rời CPU; khi sẵn sàng trở lại nó xếp vào cuối
queue. Nguồn: S1, tr. 29–34.

**Code chọn thứ tự** cho ví dụ cùng arrival ở trên:

```python
ready = [("P1", 6), ("P2", 2), ("P3", 1)]
print([pid for pid, burst in ready])  # ['P1', 'P2', 'P3']
```

Đơn giản, nhưng một burst dài có thể khiến nhiều việc ngắn phải đợi phía sau.

### 5. SJF, SRTF và dự đoán CPU burst

**Trực giác:** làm việc ngắn trước giúp nhiều người được giải quyết sớm hơn.

**Analogy:** quầy nhận sửa đồ ưu tiên việc sửa nhanh; nếu cho phép dừng việc
đang sửa để nhận việc còn nhanh hơn thì đó là một chính sách khác.

**Ví dụ nhỏ:** P1 đến lúc 0 cần 8 đơn vị; P2 đến lúc 1 cần 2 đơn vị.

| Chính sách | Lịch chạy | Tại lúc 1 |
|---|---|---|
| SJF non-preemptive | `P1 [0,8) → P2 [8,10)` | P1 giữ CPU |
| SRTF | `P1 [0,1) → P2 [1,3) → P1 [3,10)` | P1 còn 7, P2 cần 2 nên P2 lấy CPU |

**Định nghĩa:** SJF chọn CPU burst ngắn nhất trong các process đã Ready;
SRTF là biến thể preemptive, chọn **remaining time** ngắn nhất, gồm cả tác vụ
đang chạy. Không chọn một process chưa đến. Với tập burst biết trước và cùng
sẵn sàng, SJF giảm WT trung bình; không mở rộng kết luận đó thành mọi kịch bản.
Nguồn: S2, tr. 4–17.

**Code minh họa lựa chọn**, không mô phỏng toàn bộ scheduler:

```python
ready = [("P1", 6), ("P2", 2), ("P3", 1)]
print(min(ready, key=lambda p: p[1])[0])  # P3: SJF
remaining = {"P1": 7, "P2": 2}
print(min(remaining, key=remaining.get))  # P2: SRTF tại lúc 1
```

**Vì không biết burst tương lai**, dùng exponential averaging (trung bình hàm mũ):
như dự báo thời gian đi làm, kết hợp lần đo mới với ước lượng cũ. Ví dụ đo mới
6, dự đoán cũ 10, trọng số 0.5 thì dự đoán mới là 8.

`τ[n+1] = α × t[n] + (1 − α) × τ[n]`, với `0 ≤ α ≤ 1`.
`t[n]` là burst vừa đo, `τ[n]` là dự đoán trước đó. α lớn coi trọng lần đo
mới hơn. Nguồn: S2, tr. 18–19.

```python
alpha, measured, predicted = 0.5, 6, 10
print(alpha * measured + (1 - alpha) * predicted)  # 8.0
```

### 6. Priority, starvation, aging và HRRN

**Trực giác:** ưu tiên việc quan trọng, nhưng phải có cách giúp người chờ lâu được đến lượt.

**Analogy:** phòng khám ưu tiên ca khẩn cấp; nếu người thường bị lùi mãi thì
cần tăng ưu tiên cho họ theo thời gian chờ.

**Ví dụ nhỏ:** quy ước số nhỏ ưu tiên cao: P1 có priority 3, P2 có priority 1
thì chọn P2. Nếu tác vụ ưu tiên cao liên tục đến, P1 có thể chờ vô hạn.

**Định nghĩa:** Priority scheduling chọn mức ưu tiên cao nhất, có thể
preemptive hoặc non-preemptive. **Luôn đọc quy ước số lớn/nhỏ** của đề.
Starvation (chờ vô hạn) xảy ra khi một tác vụ liên tục không được chọn;
aging tăng ưu tiên theo thời gian chờ để chống tình trạng đó. Nguồn: S2, tr. 21–25.

```python
priority = {"P1": 3, "P2": 1}  # Quy ước số nhỏ ưu tiên cao
print(min(priority, key=priority.get))  # P2
```

**HRRN:** ưu tiên theo cả độ ngắn và thời gian đã đợi, giống nâng lượt cho
người đã đứng hàng lâu. Ví dụ A chờ 6, cần 3 có ratio `3`; B chờ 2, cần 2
có ratio `2`, nên chọn A.

Highest Response Ratio Next chọn ratio lớn nhất:
`ratio = (WT + BT) / BT = 1 + WT/BT`, với `BT > 0` (S2, tr. 39).
HRRN chuẩn là non-preemptive. Ratio này **không phải RT** và ký hiệu `RR`
trên slide HRRN **không phải thuật toán Round Robin**.

```python
jobs = {"A": (6, 3), "B": (2, 2)}  # (waiting, burst)
print(max(jobs, key=lambda p: 1 + jobs[p][0] / jobs[p][1]))  # A
```

Phần khái niệm dùng lại: [Starvation và aging](../../../../knowledge-base/starvation-and-aging.md).

### 7. Round Robin và quantum

**Trực giác:** mỗi người dùng một lượt ngắn rồi nhường cho người tiếp theo.

**Analogy:** ba người thay phiên dùng một dụng cụ; người chưa xong quay về cuối hàng.

**Ví dụ nhỏ:** P1, P2, P3 cùng đến lúc 0, BT `5, 3, 1`, quantum `q = 2`:

```text
0 — P1 — 2 — P2 — 4 — P3 — 5 — P1 — 7 — P2 — 8 — P1 — 9
```

**Định nghĩa:** RR dùng time slice/quantum. Nếu hết q mà chưa xong burst,
process về cuối ready queue. Nếu xong hoặc block trước q thì nhường CPU ngay,
không chiếm đủ q cho bằng được. Nguồn: S2, tr. 27–37.

**Code chạy được** cho đúng ví dụ trên, bỏ qua I/O và chi phí chuyển context:

```python
from collections import deque

ready = deque([("P1", 5), ("P2", 3), ("P3", 1)])
quantum, clock = 2, 0
while ready:
    pid, remaining = ready.popleft()
    run = min(quantum, remaining)
    print(f"{pid}: [{clock}, {clock + run})")
    clock += run
    remaining -= run
    if remaining:
        ready.append((pid, remaining))
```

| Chọn quantum | Đánh đổi |
|---|---|
| Lớn đến mức mọi burst xong trong một lượt | RR trở thành FCFS |
| Nhỏ | Nhiều cơ hội phản hồi, nhưng tốn nhiều lần chuyển context |
| q lớn so với chi phí chuyển context c | Giảm tỷ lệ chi phí: `c / (q + c)` trong chu kỳ đủ q rồi một lần chuyển |

Ví dụ từ S2 tr. 37: `q=20 ms`, `c=5 ms` → overhead `5/25 = 20%`.
Với `n` process luôn sẵn sàng luân phiên, bỏ qua overhead, thời gian đợi giữa
hai lượt bị chặn trên bởi `(n−1)q`; đây không phải tổng WT của cả chương trình.

**Quy tắc khi sự kiện trùng nhau:** S2 tr. 28 đưa P5 mới đến tại lúc 12 vào
queue trước P1 vừa hết quantum; tr. 52 cũng đặt câu hỏi về tình huống này.
Đề không nói rõ thì phải ghi quy ước đang dùng, vì nó có thể đổi Gantt.

### 8. Multilevel Queue và Multilevel Feedback Queue

**Trực giác:** chia người chờ thành nhóm; khác biệt là có được đổi nhóm hay không.

**Analogy:** các làn phục vụ cố định so với làn cho phép chuyển người chờ lâu
sang ưu tiên cao hơn.

**Ví dụ nhỏ từ slide:** MQ có thể dành 80% CPU cho foreground dùng RR, 20%
cho background dùng FCFS. MLFQ có Q0 dùng RR 8 ms, Q1 dùng RR 16 ms, Q2 dùng
FCFS; tác vụ dùng hết lượt mà còn việc có thể bị chuyển xuống hàng thấp hơn.

**Định nghĩa** — S2, tr. 41–48:

| | MQ | MLFQ |
|---|---|---|
| Gán queue | Cố định theo nhóm | Có thể đổi theo hành vi CPU burst / thời gian chờ |
| Trong mỗi queue | Thuật toán riêng | Thuật toán và quantum riêng |
| Giữa các queue | Ưu tiên cố định hoặc chia tỷ lệ CPU | Chính sách ưu tiên và điều kiện chuyển queue |
| Vấn đề cần xử lý | Queue thấp có thể starvation | Chọn số queue, quy tắc lên/xuống và aging |

```text
Tác vụ mới → Q0 (RR, 8 ms)
                 ↓ hết lượt, còn việc
             Q1 (RR, 16 ms)
                 ↓ hết lượt, còn việc
             Q2 (FCFS)
          chờ lâu → có thể nâng ưu tiên theo chính sách aging
```

Đây là cấu hình ví dụ ở S2 tr. 47, không phải quantum cố định cho mọi MLFQ.

### 9. Thread scheduling, nhiều CPU và affinity

**Trực giác:** nhiều chỗ xử lý giúp chia việc, nhưng chuyển việc qua lại cũng có giá.

**Analogy:** hai thợ có bàn riêng. Chuyển việc sang bàn đang rỗi giúp cân tải,
nhưng người nhận phải tìm lại dụng cụ và tài liệu mà bàn cũ đã có sẵn.

**Ví dụ nhỏ:** CPU0 có 3 thread Ready, CPU1 rỗi. Chuyển 1 thread sang CPU1
có thể giảm chờ, nhưng dữ liệu thread từng dùng trong cache CPU0 có thể
không sẵn trong cache CPU1.

**Định nghĩa và phân biệt** — S3, tr. 4–15:

| Khái niệm | Điều cần nhớ |
|---|---|
| PCS — process-contention scope | Thư viện chọn giữa user thread trong một process, tùy mô hình ánh xạ |
| SCS — system-contention scope | Kernel chọn giữa kernel thread trong toàn hệ thống |
| Asymmetric multiprocessing | Một CPU làm việc điều phối hệ thống; đơn giản nhưng có thể nghẽn ở CPU đó |
| SMP — symmetric multiprocessing | Các CPU tự scheduling; dùng queue chung hoặc queue riêng |
| Queue chung | Cần đồng bộ truy cập để tránh hai CPU chọn cùng tác vụ |
| Queue riêng | Giảm tranh chấp queue chung nhưng phải xử lý lệch tải |
| Push / pull migration | Đẩy việc từ CPU bận / CPU rỗi kéo việc về |
| Soft / hard affinity | Cố giữ tác vụ trên CPU cũ / giới hạn tập CPU được phép chạy |

Trên hệ thống hỗ trợ kernel thread, đơn vị được OS chọn chạy là **kernel
thread**. Đánh đổi cốt lõi là **load balancing với cache locality**, không
phải cứ di chuyển nhiều là nhanh. Không cần đổi affinity máy thật để hiểu ví dụ.

### 10. Real-time scheduling — phần đọc thêm

**Trực giác:** làm đúng nhưng quá muộn vẫn có thể là thất bại.

**Analogy:** giao suất ăn sau khi chuyến bay cất cánh không còn đáp ứng yêu cầu,
dù món ăn được nấu đúng.

**Ví dụ nhỏ tự dựng:** A cần 1 ms mỗi 4 ms; B cần 2 ms mỗi 5 ms. RM ưu tiên A
vì chu kỳ ngắn hơn. Nếu job A hiện có deadline tuyệt đối 8 còn job B là 5,
EDF ưu tiên B vì hạn gần hơn.

**Định nghĩa** — S3, tr. 16–24:

| Khái niệm | Quy tắc |
|---|---|
| Soft / hard real-time | Có thể chấp nhận trễ với suy giảm chất lượng / yêu cầu bảo đảm deadline trong mô hình thiết kế |
| Periodic task | Đến lặp theo chu kỳ T; cần C thời gian CPU mỗi lần |
| Relative deadline D | Hạn tính từ lúc release r; absolute deadline = `r + D` |
| RM — Rate Monotonic | Ưu tiên tĩnh theo chu kỳ: T nhỏ ưu tiên cao |
| EDF — Earliest Deadline First | Ưu tiên động theo absolute deadline gần nhất |
| TBS — Total Bandwidth Server | Dùng ngân sách CPU và deadline gán cho tác vụ aperiodic, phối hợp với EDF |

S3 tr. 18 xét `0 ≤ C ≤ D ≤ T`; tr. 22 dùng trường hợp `D=T`, nên viết
deadline là `r+T`. Với các tác vụ độc lập, periodic, `D=T`, một CPU,
preemptive và bỏ qua overhead, điều kiện EDF là `U = Σ(C/T) ≤ 1`.
Không dùng điều kiện này như bảo đảm chung khi giả định thay đổi.

**Code** minh họa khác biệt RM/EDF:

```python
period = {"A": 4, "B": 5}
absolute_deadline = {"A": 8, "B": 5}
print(min(period, key=period.get))  # A: RM
print(min(absolute_deadline, key=absolute_deadline.get))  # B: EDF
```

S3 tr. 19 đánh dấu sporadic tasks là tự đọc; tr. 20, 24 còn liệt kê CBS,
partition/global scheduling, PFAIR, RUN. Các tên này là hướng mở rộng,
không cần suy diễn chi tiết triển khai từ vài dòng giới thiệu.

### 11. Linux, Windows và Solaris trong bộ slide

**Trực giác:** mỗi hệ thống phối hợp nhiều quy tắc để phục vụ các nhóm việc khác nhau.

**Analogy:** một bệnh viện có làn thường, làn ưu tiên và khu cấp cứu; không dùng
một hàng FIFO duy nhất cho tất cả.

**Ví dụ nhỏ:** theo CFS được mô tả trong slide, hai tác vụ cùng trọng số có
virtual runtime 10 và 15 thì tác vụ có giá trị 10 được ưu tiên chạy tiếp.

**Cơ chế được slide mô tả:**

| Hệ thống / nguồn | Nội dung chính |
|---|---|
| Linux — S3 tr. 26–30 | Lịch sử UNIX/O(1)/CFS; CFS tính thời gian chạy theo trọng số và chọn virtual runtime nhỏ; nice từ −20 đến 19, số nhỏ ưu tiên cao hơn |
| Android — S3 tr. 31 | Dựa trên Linux, có các nhóm ưu tiên; ưu tiên thu hồi process khác với quyết định chọn CPU |
| Windows — S3 tr. 33–38 | Preemptive priority; queue theo priority; 1–15 variable, 16–31 real-time, 0 dành cho quản lý bộ nhớ theo slide; lớp của process kết hợp độ ưu tiên tương đối của thread |
| Solaris — S3 tr. 39–43, đọc thêm | Các lớp TS, IA, RT, SYS, FSS, FP; ánh xạ ra global priority; cùng priority có thể dùng RR; TS dùng feedback |

**Code mô hình lựa chọn CFS trong ví dụ**, không phải triển khai kernel:

```python
vruntime = {"A": 10, "B": 15}
print(min(vruntime, key=vruntime.get))  # A
```

Đây là mô tả theo **tài liệu mang tên 2024**, có ví dụ kernel Linux 2.6.23 và
Windows 7. Không coi là tài liệu xác nhận scheduler của mọi phiên bản hiện nay.

## Bảng tổng hợp

| Thuật toán | Chọn theo | Có thu hồi CPU? | Đánh đổi chính |
|---|---|---|---|
| FCFS | Thứ tự vào ready queue | Không | Đơn giản, việc ngắn dễ bị chặn sau việc dài |
| SJF | CPU burst ngắn nhất | Không trong cách gọi của note | Giảm chờ cho việc ngắn, phải ước lượng burst |
| SRTF | Thời gian còn lại ngắn nhất | Có | Phản ứng khi việc ngắn đến, thêm chi phí chuyển |
| Priority | Mức ưu tiên | Tùy biến thể | Cần quy ước số và chống starvation |
| RR | FIFO theo lượt q | Có | q cân bằng phản hồi và overhead |
| HRRN | `1 + WT/BT` lớn nhất | Không | Chờ lâu làm tăng cơ hội, vẫn cần ước lượng BT |
| MQ | Nhóm cố định | Tùy trong/giữa queue | Tách workload nhưng kém linh hoạt |
| MLFQ | Nhóm thay đổi theo hành vi | Có theo slide | Thích nghi hơn, nhiều tham số chính sách |

Nguồn: S1 tr. 29; S2 tr. 4–50. Phần so sánh là tổng hợp của note.

## Sơ đồ

```text
New / I/O hoàn tất → Ready queue → scheduler chọn → dispatcher → Running
                         ↑                                      │
                         ├──── hết quantum / bị preempt ─────────┤
                         │                                      ├→ Terminated
                         └──── I/O hoàn tất ← Waiting ← yêu cầu I/O
```

Chương 3 trả lời **đang ở trạng thái nào**; chương 4 trả lời **Ready rồi thì ai
được chạy tiếp**. Việc I/O hoàn tất không tự cho phép bỏ qua scheduler.

## Quy trình tự làm bài Gantt

1. Ghi AT, BT, priority, q; chốt preemptive hay non-preemptive, quy tắc hòa
   và chi phí context switch. Thiếu thông tin thì ghi giả định.
2. Ở mỗi mốc quyết định, liệt kê **đã đến và chưa xong**. Chưa có ai Ready
   thì ghi đoạn Idle đến arrival kế tiếp.
3. Chọn theo đúng thuật toán. Với SRTF cập nhật remaining; với RR ghi thứ tự
   queue sau mỗi lượt, kể cả arrival trùng lúc hết q.
4. Lấy ST lần đầu, CT lần cuối từ Gantt; tính RT, TAT, WT cho từng process
   rồi mới lấy trung bình. Không có block thì kiểm tra `WT + BT = TAT`.
5. Kiểm tra tổng độ dài các đoạn CPU của mỗi process bằng BT đã cho.

Bài tự luyện có sẵn: **S1 tr. 35–41; S2 tr. 52–57**. Note hướng dẫn phương
pháp; chưa có bằng chứng đây là bài phải nộp hay có hạn nộp.

## Chỗ cần lưu ý khi đối chiếu nguồn

- **S2 tr. 14:** dòng cộng ATaT in các số của response time. Từ CT và AT
  trên biểu đồ, TAT là `36, 7, 21, 3, 6`; tổng đúng là `73`, trung bình
  **14.6**, khớp kết quả cuối trên slide nhưng không khớp biểu thức in kèm.
- **S2 tr. 31:** dòng cộng AWT in các số turnaround. WT đúng theo biểu đồ
  là `18, 10, 21, 10, 18`; trung bình **15.4**. Kết quả cuối đúng,
  các số trong biểu thức cộng bị lặp từ trang trước.
- **❓ CẦN XÁC MINH:** quy tắc xử lý trường hợp hòa trong một đề cụ thể nếu
  không được nêu; không mặc định mọi đề RR đều dùng cùng thứ tự tại mốc trùng.
- TBS và các thuật toán mở rộng chỉ được giới thiệu ngắn; chưa đủ nguồn để
  coi note là hướng dẫn triển khai đầy đủ.

## Gợi ý thi và deadline phát sinh

Không có transcript để trích lời dặn thi hoặc quy định chấm điểm. Slide có
câu hỏi ôn tập (S2 tr. 51, S3 tr. 45), nhưng không xác nhận câu nào sẽ thi.
Không tìm thấy hạn nộp mới trong ba bộ slide; không phát sinh cập nhật cho
`IMPORTANT_NOTES.md` hoặc `admin/deadlines.md` từ note này.

## Liên kết

- [L03 — Process management](L03-process-management.md)
- [Starvation và aging](../../../../knowledge-base/starvation-and-aging.md)
- [Flashcard của môn](../exam-prep/flashcards.md) · [CSV import Anki](../exam-prep/flashcards.csv)
- [Ghi chú quan trọng](../IMPORTANT_NOTES.md)

## Tự kiểm tra

**1.** P1 Running, P2 Waiting. Khi I/O của P2 xong, P2 có chạy ngay không?

<details><summary>Đáp án</summary>

P2 về Ready. Có được chọn ngay hay không phụ thuộc thuật toán; chính sách
preemptive có thể thu hồi CPU của P1 nếu P2 thỏa tiêu chí ưu tiên. Non-preemptive
không lấy CPU khỏi P1 chỉ vì P2 mới Ready.

</details>

**2.** P đến lúc 2, chạy lần đầu lúc 4, xong lúc 12, dùng CPU tổng 5 đơn vị,
không block. RT, TAT, WT bằng bao nhiêu?

<details><summary>Đáp án</summary>

RT = 4 − 2 = 2; TAT = 12 − 2 = 10; WT = 10 − 5 = 5.
CT là thời điểm 12, không phải turnaround 10.

</details>

**3.** P1 cần 8 đơn vị, đến lúc 0; P2 cần 2, đến lúc 1. SJF và SRTF khác nhau ở đâu?

<details><summary>Đáp án</summary>

SJF giữ P1 đến lúc 8 rồi chạy P2. SRTF so sánh lúc 1: P1 còn 7, P2 cần 2,
nên chạy P2 từ 1 đến 3, rồi P1 từ 3 đến 10.

</details>

**4.** RR có q = 20 ms, mỗi lần chuyển context tốn 5 ms. Overhead trong một
chu kỳ chạy đủ q rồi chuyển là bao nhiêu? Tăng q giải quyết được mọi mục tiêu không?

<details><summary>Đáp án</summary>

5/(20+5) = 20%. Tăng q giảm tỷ lệ chi phí nhưng có thể tăng thời gian đợi
được phản hồi; q đủ lớn khiến RR giống FCFS.

</details>

**5.** CPU0 bận, CPU1 rỗi: vì sao không chuyển mọi thread sang CPU1? RM và EDF
lại bổ sung tiêu chí chọn nào so với việc chỉ cân tải?

<details><summary>Đáp án</summary>

Chuyển mọi thread chỉ đổi CPU bị quá tải và có thể mất cache locality;
cần cân bằng load với affinity. RM chọn theo chu kỳ ngắn, EDF chọn deadline
tuyệt đối gần; tải cân bằng chưa tự bảo đảm deadline.

</details>
