# IT007 — Hệ điều hành

| | |
|---|---|
| Mã lớp | `IT007.F31.CN1.CNTT` |
| Tên tiếng Anh | Operating Systems |
| Giảng viên | **Nguyễn Thanh Thiện** |
| Số tín chỉ | ❓ |
| Học kỳ | HK3 2025–2026 |
| Hình thức | Online qua Microsoft Teams |

> 📌 Mọi thứ ảnh hưởng tới **điểm số** — cách tính điểm, phần sẽ thi, lời dặn của giảng viên —
> nằm ở [`IMPORTANT_NOTES.md`](IMPORTANT_NOTES.md), không phải file này.

---

## Mục lục

- [Môn này nói về cái gì](#môn-này-nói-về-cái-gì)
- [Giáo trình và tài liệu](#giáo-trình-và-tài-liệu)
- [Tiến độ buổi học](#tiến-độ-buổi-học)
- [Bài tập và đồ án](#bài-tập-và-đồ-án)
- [Cảm nhận cá nhân](#cảm-nhận-cá-nhân)
- [Thư mục](#thư-mục)

---

## Môn này nói về cái gì

Môn lõi của CS: process và thread, định thời CPU (CPU scheduling), đồng bộ hoá (synchronization), deadlock, quản lý bộ nhớ, bộ nhớ ảo, file system, I/O.

**Lưu ý riêng cho người đang đi làm:** đây là môn giải thích *tại sao* những thứ bạn dùng hàng ngày lại hoạt động như vậy — vì sao có race condition, vì sao container cô lập được tiến trình, vì sao máy hết RAM lại chậm chứ không crash. Phần dễ bị xem nhẹ là **bài tập tính toán bằng tay** (scheduling, banker's algorithm) — đi làm không bao giờ tính tay, nhưng đề thi thì có.

**Điểm giao với môn khác học kỳ này:** IE101 nhìn cùng thứ từ tầng hạ tầng, IE105 nhìn từ góc bảo mật.

> Viết lúc khởi tạo, dựa trên tên môn. **Sửa lại sau buổi học đầu tiên** khi đã biết
> giảng viên thực sự đi theo hướng nào.

---

## Giáo trình và tài liệu

| Loại | Tên | File trong `materials/` |
|---|---|---|
| Đề cương môn học | ❓ | `materials/syllabus/` |
| Giáo trình chính | ❓ | `materials/books/` |
| Tham khảo | ❓ | `materials/references/` |
| Slide bài giảng | ❓ | `materials/slides/` |

> 📌 Bỏ **đề cương** vào `materials/syllabus/` rồi bảo AI đọc — nó thường chứa sẵn
> cách tính điểm và quy định môn học, tức là mục 1 và 4 của `IMPORTANT_NOTES.md`.

---

## Tiến độ buổi học

| Buổi | Ngày | Chủ đề | Note | Trạng thái |
|---|---|---|---|---|
| 3 | TBD | Quản lý tiến trình (Chương 3) | [`lectures/L03-process-management.md`](lectures/L03-process-management.md) | ✅ (không có transcript, dựa trên slide; ngày chờ cập nhật) |
| 4 | — | CPU scheduling (Chương 4) | [`lectures/L04-cpu-scheduling.md`](lectures/L04-cpu-scheduling.md) | ✅ (dựa trên slide; không có transcript, không gán ngày học) |
| 10 | 2026-09-11 | Bộ nhớ ảo (Chương 8) | [`lectures/L10-virtual-memory.md`](lectures/L10-virtual-memory.md) | ✅ (không có transcript, dựa trên slide) |

---

## Bài tập và đồ án

| Mã | Tên | Hạn nộp | Trạng thái |
|---|---|---|---|
| — | *chưa có* | — | — |

---

## Cảm nhận cá nhân

> Phần này là **dữ liệu đầu vào cho việc chọn chuyên ngành**
> ([`program/specialization/`](../../../program/specialization/README.md)).
> Ghi lúc còn nóng — sau một năm sẽ không nhớ nổi mình có thích môn này không.

| | |
|---|---|
| Thấy thú vị? | ❓ chưa học |
| Làm có tốt? | ❓ |
| Có muốn đi sâu hướng này? | ❓ |
| Ghi chú | |

---

## Thư mục

| | |
|---|---|
| [`materials/`](materials/) | **Tài liệu giảng viên cung cấp** — slide, đề cương, ebook. **Chỉ đọc** |
| [`lectures/_raw/`](lectures/_raw/) | Transcript Teams gốc — **không bao giờ sửa** |
| [`lectures/`](lectures/) | Note theo từng buổi |
| [`notes/`](notes/) | Note theo khái niệm |
| [`assignments/`](assignments/) | Bài tập — mỗi bài một thư mục `a1`, `a2`… |
| [`projects/`](projects/) | Đồ án — mỗi đồ án một thư mục `prj1`… |
| [`research/`](research/) | Tự đào sâu ngoài syllabus |
| [`code/`](code/) | Lab, thử nghiệm nhanh |
| [`exam-prep/`](exam-prep/) | Flashcard, cheatsheet, [map đề thi + blueprint](exam-prep/exam-map.md) |
