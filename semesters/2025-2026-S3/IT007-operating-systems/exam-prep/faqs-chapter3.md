# FAQ nhanh — Chương 3

Câu hỏi ngắn, trả lời nhanh khi ôn chương 3. Đầy đủ hơn thì xem
`lectures/L<nn>-*.md`.

## Mục lục

1. [Một tiến trình có bao nhiêu trạng thái](#q1-một-tiến-trình-có-bao-nhiêu-trạng-thái)
2. [Tại sao một tiến trình cần những trạng thái này](#q2-tại-sao-một-tiến-trình-cần-những-trạng-thái-này)

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
