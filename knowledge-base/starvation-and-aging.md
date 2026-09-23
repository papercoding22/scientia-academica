# Starvation và aging

> Khi ưu tiên việc này liên tục khiến việc khác không bao giờ đến lượt.

**Xuất hiện ở:** `IT007` — [L04, chương 4](../semesters/2025-2026-S3/IT007-operating-systems/lectures/L04-cpu-scheduling.md) · [L05, chương 5](../semesters/2025-2026-S3/IT007-operating-systems/lectures/L05-process-synchronization.md) (bounded waiting, readers-writers, dining-philosophers).
Ứng dụng mở rộng: chọn job trong worker queue; đây là liên hệ thực tế, chưa phải
nội dung đã xác nhận ở môn khác.

---

## Mục lục

- [Một câu](#một-câu)
- [Analogy](#analogy)
- [Ví dụ nhỏ nhất](#ví-dụ-nhỏ-nhất)
- [Định nghĩa hình thức](#định-nghĩa-hình-thức)
- [Code](#code)
- [Khi nào dùng / không dùng](#khi-nào-dùng--không-dùng)
- [Nhầm lẫn thường gặp](#nhầm-lẫn-thường-gặp)
- [Nguồn](#nguồn)
- [Nhớ nhanh](#nhớ-nhanh)

---

## Một câu

Người đến trước vẫn có thể đợi mãi nếu cứ có người khác được ưu tiên vượt lên.

## Analogy

Một quầy luôn phục vụ khách ưu tiên trước khách thường. Nếu khách ưu tiên
liên tục đến, khách thường có thể không bao giờ được phục vụ. Cho khách chờ
lâu tăng dần mức ưu tiên giúp họ có cơ hội đến lượt.

## Ví dụ nhỏ nhất

Quy ước **số nhỏ ưu tiên cao**. P1 có priority 4 và đang Ready; P2 có priority 1.
Nếu luôn có việc priority 1 thay P2, P1 có thể chờ vô hạn.

Chính sách minh họa: mỗi 5 đơn vị chờ Ready, giảm số priority của P1 đi 1.
Sau 15 đơn vị, P1 có priority 1; nếu cùng mức dùng FIFO, P1 được xếp trước
các tác vụ mới vào cùng mức đó.

```text
P1: priority 4 → chờ 5 → 3 → chờ 5 → 2 → chờ 5 → 1
                                                   ↓
                                  cùng mức: xét thứ tự FIFO
```

Các con số và quy tắc FIFO là **ví dụ tự dựng**, không phải tham số bắt buộc
của aging.

## Định nghĩa hình thức

**Starvation (chờ vô hạn):** một tác vụ đủ điều kiện được phục vụ nhưng liên tục
không được chọn vì chính sách ưu tiên các tác vụ khác. Trong CPU scheduling,
tác vụ có thể ở Ready trong khi CPU vẫn chạy tác vụ khác.

**Aging:** tăng dần mức ưu tiên theo thời gian chờ để chống starvation.
Ví dụ với số nhỏ ưu tiên cao: `effective_priority = base_priority − floor(W / k)`,
trong đó `W` là thời gian chờ và `k > 0` là khoảng tăng ưu tiên. Công thức này
là một lựa chọn minh họa; hệ thống phải quy định giới hạn priority và cách xử
lý các tác vụ cùng mức. Không phải mọi cách cộng điểm chờ đều bảo đảm được phục vụ.

## Code

Python 3, tính priority của P1 ở các mốc chờ trong ví dụ:

```python
base_priority, interval = 4, 5
for waited in (0, 5, 10, 15):
    effective_priority = base_priority - waited // interval
    print(waited, effective_priority)
# 0 4
# 5 3
# 10 2
# 15 1
```

Code chỉ minh họa cách đổi priority, chưa mô phỏng lịch phục vụ hay chứng
minh mọi tác vụ đều có thời gian chờ hữu hạn.

## Khi nào dùng / không dùng

| Dùng aging khi | Không tự động áp dụng khi |
|---|---|
| Priority scheduling khiến việc ưu tiên thấp bị bỏ qua lâu | Priority thể hiện yêu cầu hard real-time cần phân tích deadline |
| Queue thấp trong MLFQ cần cơ hội được nâng lên | Tác vụ đang chờ I/O; tăng priority không làm I/O hoàn tất |
| Worker queue cần cân bằng mức quan trọng với thời gian chờ | Công việc mắc deadlock; phải xử lý nguyên nhân chờ tài nguyên |

Hai liên hệ hard real-time/worker queue là suy luận ứng dụng từ khái niệm.

## Nhầm lẫn thường gặp

- **Chờ lâu chưa đủ kết luận starvation:** starvation nói đến khả năng bị trì hoãn vô hạn.
- **Aging không phải luôn tăng con số priority:** số nhỏ ưu tiên cao thì phải giảm số.
- **Starvation khác deadlock:** starvation có thể xảy ra khi hệ thống vẫn phục vụ việc khác;
  deadlock là một nhóm tác vụ không thể tiến lên do chờ tài nguyên lẫn nhau.

## Nguồn

- [Copy of #Week06-Chapter4-2 2024.pdf](../semesters/2025-2026-S3/IT007-operating-systems/materials/slides/Copy%20of%20%23Week06-Chapter4-2%202024.pdf),
  tr. 16, 23: starvation trong SJF/Priority và aging; tr. 39: HRRN kết hợp thời gian
  chờ với độ dài việc; tr. 46: MLFQ cho phép đổi queue và áp dụng aging.
- [IT007 — L04](../semesters/2025-2026-S3/IT007-operating-systems/lectures/L04-cpu-scheduling.md):
  ngữ cảnh CPU scheduling và các ví dụ thuật toán.

## Nhớ nhanh

| Khái niệm | Câu hỏi cốt lõi |
|---|---|
| Starvation | Có ai đủ điều kiện nhưng mãi không được chọn? |
| Aging | Người chờ lâu có được tăng cơ hội đến lượt? |
| Chính sách hoàn chỉnh | Tăng bao nhiêu, đến mức nào, cùng mức thì ai trước? |
