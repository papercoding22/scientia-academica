# Knowledge Base

Khái niệm **dùng chung, sống lâu hơn một học kỳ**. Đây là tầng tích luỹ của repo —
môn học kết thúc, học kỳ trôi qua, nhưng nội dung ở đây vẫn đúng.

---

## Khi nào một khái niệm được vào đây

Vào đây khi khái niệm **xuất hiện ở nhiều hơn một môn**, hoặc chắc chắn sẽ còn gặp lại.

| Tình huống | Bỏ vào đâu |
|---|---|
| Chỉ liên quan một buổi học | `lectures/L<nn>-….md` |
| Gom từ nhiều buổi trong **một môn** | `notes/` của môn đó |
| **Nhiều môn** dùng, hoặc còn gặp lại lâu dài | **`knowledge-base/`** ← đây |
| Tự đào sâu ngoài syllabus | `research/` của môn |

Khi tạo file ở đây, **link hai chiều**: note của môn trỏ tới đây, file ở đây ghi rõ
xuất hiện ở những môn nào.

---

## Quy ước

- Tên file tiếng Anh, `kebab-case.md` → `process-scheduling.md`, `acid-transactions.md`
- Nội dung tiếng Việt, thuật ngữ giữ tiếng Anh
- Dùng `templates/concept.md`
- Liên kết giữa các khái niệm bằng `[[tên-file]]`

---

## Index

| Khái niệm | Xuất hiện ở môn | Ghi chú |
|---|---|---|
| [Starvation và aging](starvation-and-aging.md) | IT007 — L04, L05 | Chờ vô hạn và tăng ưu tiên theo thời gian chờ; dùng lại khi thiết kế queue |
| [Race condition và critical section](race-condition.md) | IT007 — L05 | Vì sao phải đồng bộ, 3 yêu cầu của lời giải; dùng lại cho lost update ở database |
