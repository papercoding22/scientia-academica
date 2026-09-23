# Race condition và critical section

> Khi kết quả phụ thuộc vào việc ai chạy trước, mà không ai kiểm soát được ai chạy trước.

**Xuất hiện ở:** `IT007` — [L05, chương 5](../semesters/2025-2026-S3/IT007-operating-systems/lectures/L05-process-synchronization.md).
Ứng dụng mở rộng: lost update trong database, cập nhật cache, đếm request trong service
đa luồng — đây là liên hệ thực tế, chưa phải nội dung đã xác nhận ở môn khác.

---

## Mục lục

- [Một câu](#một-câu)
- [Analogy](#analogy)
- [Ví dụ nhỏ nhất](#ví-dụ-nhỏ-nhất)
- [Định nghĩa hình thức](#định-nghĩa-hình-thức)
- [Code](#code)
- [Khi nào dùng / không dùng](#khi-nào-dùng--không-dùng)
- [Nhầm lẫn thường gặp](#nhầm-lẫn-thường-gặp)
- [Liên quan](#liên-quan)
- [Nguồn](#nguồn)

---

## Một câu

Hai luồng cùng sửa một dữ liệu chung mà không phối hợp thì một bên có thể ghi đè kết quả
của bên kia.

## Analogy

Hai thu ngân cùng cập nhật số tồn kho trên một tờ giấy: cả hai đọc "5", một người ghi "6",
người kia ghi "4". Tờ giấy chỉ giữ con số của người ghi sau cùng.

## Ví dụ nhỏ nhất

`count = 5`; `count++` và `count--` mỗi phép gồm load → tính → store. Lịch chạy
`P load 5 · P inc 6 · C load 5 · C dec 4 · P store 6 · C store 4` cho ra **4** thay vì 5.

## Định nghĩa hình thức

> **Race condition:** các tiến trình cùng truy cập đồng thời dữ liệu chia sẻ, kết quả cuối
> phụ thuộc thứ tự thực thi. **Critical section:** đoạn code thay đổi dữ liệu chia sẻ. Lời
> giải phải đạt **mutual exclusion**, **progress**, **bounded waiting**.

## Code

C với pthread: [`race-condition.c`](../semesters/2025-2026-S3/IT007-operating-systems/code/L05/race-condition.c).
Không khoá thì mỗi lần chạy ra một số khác; bật `-DUSE_MUTEX` thì luôn ra 5.

## Khi nào dùng / không dùng

| Cần đồng bộ khi | Không cần khi |
|---|---|
| Có **ghi** vào dữ liệu mà luồng khác cũng đọc hoặc ghi | Dữ liệu chỉ đọc, không ai sửa sau khi khởi tạo |
| Phép "đọc – tính – ghi" không nguyên tử (`x++`, `SELECT` rồi `UPDATE`) | Mỗi luồng chỉ đụng dữ liệu riêng của nó |
| Kiểm tra điều kiện rồi mới hành động (`if (count < n) add()`) | Thao tác đã nguyên tử sẵn (atomic, `UPDATE ... SET x = x - 1`) |

## Nhầm lẫn thường gặp

- ❌ "Chạy thử 100 lần đều đúng là không có race" → ✅ race phụ thuộc lịch chạy; hiếm
  không có nghĩa là không có.
- ❌ "`x++` là một lệnh nên an toàn" → ✅ nó là load/inc/store, có thể bị ngắt giữa chừng.
- ❌ "Race condition = critical section" → ✅ race condition là **hiện tượng**; critical
  section là **đoạn code** cần bảo vệ để tránh hiện tượng đó.
- ❌ "Có khoá là xong" → ✅ khoá sai thứ tự sinh deadlock; xem [[starvation-and-aging]]
  cho vấn đề chờ vô hạn.

## Liên quan

- [[starvation-and-aging]] — bounded waiting bị vi phạm chính là starvation.

## Nguồn

- [Copy of #Week07-Chapter5-1 2024.pdf](../semesters/2025-2026-S3/IT007-operating-systems/materials/slides/Copy%20of%20%23Week07-Chapter5-1%202024.pdf),
  slide 11 (lịch chạy count++/count--), 15–16 (định nghĩa race condition), 18–25 (critical
  section và 3 yêu cầu).
- [IT007 — L05](../semesters/2025-2026-S3/IT007-operating-systems/lectures/L05-process-synchronization.md):
  các công cụ mutex, semaphore, monitor.
