# SS009 — Tài liệu từ giảng viên

> ⚠️ **Đây là thư mục ĐẦU VÀO — chỉ đọc.**
> AI **không bao giờ** sửa, đổi tên, hay xoá file ở đây. Đây là bản gốc của giảng viên.
> Muốn ghi chú thì viết file mới ở `../notes/`, không động vào file gốc.

---

## Bỏ file vào đâu

| Thư mục | Nội dung | Ví dụ |
|---|---|---|
| [`syllabus/`](syllabus/) | Đề cương môn học, kế hoạch giảng dạy | `de-cuong-SS009.pdf` |
| [`slides/`](slides/) | Slide bài giảng, theo từng buổi | `L01-gioi-thieu.pdf` |
| [`books/`](books/) | Giáo trình, ebook, sách tham khảo | `operating-system-concepts-10e.pdf` |
| [`references/`](references/) | Tài liệu lẻ: bài báo, chuẩn, hướng dẫn | `rfc-2119.pdf` |

**Phân biệt với chỗ khác:**

| | |
|---|---|
| `materials/` | Tài liệu tầm **cả môn**, giảng viên cung cấp |
| `assignments/aN/brief/` | Đề bài của **một** bài tập cụ thể |
| `assignments/aN/resources/` | Tài liệu chỉ phục vụ **một** bài tập |
| `lectures/_raw/` | Transcript Teams — bản ghi lời nói, không phải file giảng viên gửi |

---

## Quy ước đặt tên

- **Slide gắn với buổi học** → tiền tố `L<nn>` cho khớp với note:
  `slides/L03-cpu-scheduling.pdf` ↔ `lectures/L03-cpu-scheduling.md`
- Slide không gắn buổi cụ thể → tên mô tả, tiếng Anh, `kebab-case`.
- **Giữ nguyên tên gốc** nếu tên đó có ý nghĩa (mã tài liệu, số hiệu chuẩn).
  Đổi tên cho đẹp mà mất thông tin thì lợi bất cập hại.

---

## 📌 Đề cương là mỏ vàng — xử lý ngay khi có

File trong `syllabus/` thường chứa sẵn **cách tính điểm**, **nội dung từng buổi**,
và **quy định môn học** — tức là phần lớn mục 1, 4, 5 của
[`../IMPORTANT_NOTES.md`](../IMPORTANT_NOTES.md).

Bỏ đề cương vào đây rồi bảo AI: *"đọc đề cương SS009, điền IMPORTANT_NOTES"*.

---

## ⚠️ Về file nặng

Git giữ mọi phiên bản file **vĩnh viễn**, kể cả khi bạn xoá sau này.
Một ebook 80MB commit vào đây là repo nặng thêm 80MB mãi mãi.

- Slide, đề cương (vài MB) → commit thoải mái.
- Ebook lớn → cân nhắc. Nếu repo phình to, chuyển sang Git LFS hoặc để ebook ngoài repo.
- **File video** (`.mp4`, `.m4a`…) đã bị `.gitignore` chặn sẵn — bỏ vào đây sẽ không được
  commit, nằm ở máy local thôi. Đó là chủ ý.
