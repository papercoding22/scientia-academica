# FAQ nhanh — Chương 3

Câu hỏi ngắn, trả lời nhanh khi ôn chương 3. Đầy đủ hơn thì xem
`lectures/L<nn>-*.md`.

## Mục lục

1. [Một tiến trình có bao nhiêu trạng thái](#q1-một-tiến-trình-có-bao-nhiêu-trạng-thái)
2. [Tại sao một tiến trình cần những trạng thái này](#q2-tại-sao-một-tiến-trình-cần-những-trạng-thái-này)
3. [PCB là gì? có vai trò gì?](#q3-pcb-là-gì-có-vai-trò-gì)

---

## Q1. Một tiến trình có bao nhiêu trạng thái

5 trạng thái chính: **New → Ready → Running → Waiting (Blocked) → Terminated**.

| Trạng thái | Ý nghĩa |
|---|---|
| New | Vừa được tạo |
| Ready | Sẵn sàng, chờ CPU cấp phát |
| Running | Đang chạy trên CPU |
| Waiting/Blocked | Chờ I/O hoặc sự kiện, không chạy được dù có CPU |
| Terminated | Đã kết thúc |

Chuyển trạng thái: `Ready → Running` do scheduler dispatch · `Running → Waiting`
khi gọi I/O · `Waiting → Ready` khi I/O xong (không nhảy thẳng vào Running).

**Ví dụ:** chạy `python script.py` đọc 1 file rồi in kết quả.

| Bước | Trạng thái | Vì sao |
|---|---|---|
| 1 | New | Shell `fork()` + `exec()`, OS tạo PCB |
| 2 | Ready | Nạp xong, xếp hàng đợi CPU |
| 3 | Running | Scheduler dispatch, thực thi bytecode |
| 4 | Waiting | Gọi `open("data.txt")` → chờ đĩa, nhường CPU |
| 5 | Ready | Đĩa trả xong dữ liệu, quay lại hàng đợi |
| 6 | Running | Được cấp CPU tiếp, in kết quả |
| 7 | Terminated | Chạy xong, gọi `exit()` |

Script đọc file nhiều lần → bước 4-5-6 lặp lại nhiều vòng.

**Liên hệ đời thường:** giống khách chờ khám bệnh — *New* (mới đăng ký) ·
*Ready* (ngồi phòng chờ) · *Running* (đang được bác sĩ khám — 1 bác sĩ = 1 CPU) ·
*Waiting* (đi chụp X-quang, nhường chỗ cho người khác khám) · *Terminated* (khám xong về).

**Mô tả trực quan:**

```
      admit           dispatch
New ────────► Ready ◄──────────┐
                │               │
                ▼               │
             Running            │
             │     │            │
   I/O/event │     └── exit ──► Terminated
   wait      ▼
           Waiting
                │
         I/O/event completion
                └──────────────► (về lại Ready)
```

## Q2. Tại sao một tiến trình cần những trạng thái này

Vì CPU giới hạn còn tiến trình thì nhiều và không phải lúc nào cũng cần CPU —
không có trạng thái, hệ điều hành không phân biệt được tiến trình nào *đang cần*
CPU với tiến trình nào *đang chờ việc khác* (I/O), sẽ phí phạm dispatch nhầm chỗ.

| Trạng thái | Giải quyết vấn đề gì |
|---|---|
| New | Tách "đang khởi tạo" (cấp PCB, load code) khỏi "đã sẵn sàng chạy" |
| Ready | Cần hàng đợi các tiến trình *đủ điều kiện* chạy để scheduler chọn |
| Running | 1 CPU chỉ chạy đúng 1 tiến trình tại một thời điểm — cần biết ai đang chiếm |
| Waiting | Tách riêng để scheduler không phí thời gian dispatch tiến trình đang chờ đĩa/mạng, chưa làm được gì |
| Terminated | Giữ thông tin (exit code, PCB) cho tiến trình cha đọc qua `wait()`, chưa dọn ngay |

**Cốt lõi:** tách Ready và Waiting là quan trọng nhất — nhờ đó CPU không bao giờ
đứng im khi còn tiến trình khác thật sự sẵn sàng chạy, thay vì multitasking mù
quáng kiểu round-robin không phân biệt trạng thái.

## Q3. PCB là gì? có vai trò gì?

**PCB (Process Control Block)** là cấu trúc dữ liệu OS dùng làm **hồ sơ quản lý
của một process**: process đang ở trạng thái nào, dùng tài nguyên gì và cần
tiếp tục chạy từ đâu.

**Liên hệ đời thường:** giống phiếu lưu ván chơi — ghi lại đang tới đâu và
trạng thái hiện tại, để tạm dừng rồi tiếp tục đúng chỗ.

**PCB gồm những gì?** Theo slide chương 3, có 7 nhóm thông tin chính:

| Thành phần | Lưu những gì? | Dùng để làm gì? |
|---|---|---|
| **Process state** | New, Ready, Running, Waiting, Terminated | Biết process đang ở trạng thái nào |
| **Program counter** | Địa chỉ lệnh tiếp theo sẽ thực thi | Biết tiếp tục chạy từ đâu sau khi tạm dừng |
| **CPU registers** | Giá trị các thanh ghi đã lưu, như thanh ghi đa dụng, stack pointer, thanh ghi trạng thái | Khôi phục dữ liệu làm việc và ngữ cảnh CPU khi chạy tiếp |
| **CPU scheduling information** | Priority, con trỏ/liên kết tới các hàng đợi scheduling | Hỗ trợ scheduler quản lý và chọn process được cấp CPU |
| **Memory-management information** | Thông tin ánh xạ bộ nhớ, như con trỏ tới page table hoặc giá trị base/limit tùy cơ chế | Xác định và bảo vệ không gian nhớ của process |
| **Accounting information** | Thời gian CPU đã dùng, thời gian sử dụng và giới hạn tài nguyên | Thống kê, theo dõi mức sử dụng tài nguyên của process |
| **I/O status information** | Thiết bị I/O được cấp, danh sách file đang mở | Theo dõi tài nguyên I/O của process |

PCB gắn với **PID (Process ID)** để OS nhận diện process. Tên trường và cách
tổ chức cụ thể có thể khác nhau giữa các OS; các ví dụ trong bảng mô tả chức năng
của từng nhóm, không phải một cấu trúc cố định cho mọi OS.

**Ví dụ context switch (chuyển ngữ cảnh):** P1 đang tính dở thì hết lượt CPU.
OS lưu ngữ cảnh P1 vào PCB của P1, nạp ngữ cảnh P2 từ PCB của P2 rồi chạy P2.
Khi đến lượt P1, OS khôi phục ngữ cảnh đã lưu; P1 tiếp tục công việc đang dở,
không chạy lại từ đầu.

```text
P1 Running → lưu ngữ cảnh vào PCB₁ → nạp ngữ cảnh từ PCB₂ → P2 Running
```

PCB lưu **thông tin quản lý và ngữ cảnh**, không chứa toàn bộ code/data/stack
của chương trình; các vùng đó thuộc không gian nhớ của process.

**Nguồn ôn tập:** [L03 — Process Control Block và context switch](../lectures/L03-process-management.md#3-process-control-block-pcb).
Danh sách thành phần: [slide Chapter3-1](../materials/slides/Copy%20of%20%23Week03-Chapter3-1%202024.pdf),
trang PDF **16**; định danh process được nhắc ở trang **9**.
