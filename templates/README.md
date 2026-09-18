# Templates

Hai loại template, hai người dùng khác nhau. Đừng lẫn.

| Loại | Ai dùng | Làm gì |
|---|---|---|
| **`.docx`** | **Bạn** — mở bằng Word | Soạn báo cáo bài tập để nộp cho giảng viên |
| **`.md`** | **AI** — copy rồi điền | Sinh file mới trong repo |

---

## Mục lục

- [ASSIGNMENT_TEMPLATE.docx — template nộp bài](#assignment_templatedocx--template-nộp-bài)
- [Template markdown](#template-markdown)
- [Template có token](#template-có-token)

---

## ASSIGNMENT_TEMPLATE.docx — template nộp bài

Trang bìa chuẩn UIT + khung `Câu 1` · `Bảng` · `Kết luận`, các ô thông tin để trống.

**Cách dùng — `scripts/new-assignment.sh` tự copy và đặt tên cho bạn:**

```bash
scripts/new-assignment.sh --course IE105 --num 8 --due 2026-09-25
```

Mẫu tên file nộp được **suy ra từ bài đã nộp trước đó của cùng môn**, không hardcode.

> ⚠️ **Mẫu tên file do giảng viên quy định, mỗi môn mỗi khác.**
> Tra bảng ở [`AGENTS.md` § 13.3](../AGENTS.md) hoặc mục 4 trong `IMPORTANT_NOTES.md` của môn
> trước khi đặt tên. IE105 dùng `Bài tập <N>_Họ tên_MSSV`.

Cần điền trên trang bìa: `MÃ MÔN` · `MÔN HỌC` · `GVHD` · `Sinh viên thực hiện` · `MSSV` · `Lớp`
— lấy từ `README.md` của môn.

**File này cố tình để trống thông tin cá nhân.** Đừng điền sẵn tên và MSSV rồi commit —
repo đang public.

**Nộp file gốc `.docx`**, không phải PDF. Giảng viên IE105 nói rõ lý do: file gốc cho thấy
quá trình làm bài, *"nộp file PDF thì giống như nộp cái ảnh"*.

---

## Template markdown

AI copy rồi điền khi sinh file mới. Không phải để bạn mở đọc.

| Template | Sinh ra file | Khi nào |
|---|---|---|
| `course-readme.md` | `<môn>/README.md` | tạo môn mới |
| `important-notes.md` | `<môn>/IMPORTANT_NOTES.md` | tạo môn mới |
| `materials-readme.md` | `<môn>/materials/README.md` | tạo môn mới |
| `flashcards.md` | `exam-prep/flashcards.md` | tạo môn mới |
| `cheatsheet.md` | `exam-prep/cheatsheet.md` | tạo môn mới |
| `lecture-raw.md` | `lectures/_raw/L<nn>-*.md` | tạo buổi học |
| `lecture-note.md` | `lectures/L<nn>-*.md` | xử lý buổi học |
| `assignment.md` | `assignments/aN/README.md` | tạo bài tập |
| `assignment-guide.md` | `assignments/aN/GUIDE.md` | hướng dẫn cách làm bài |
| `project.md` | `projects/prjN/README.md` | tạo đồ án |
| `research.md` | `research/<chu-de>.md` | đào sâu chủ đề |
| `concept.md` | `knowledge-base/<khái-niệm>.md` | khái niệm dùng chung |
| `thesis-idea.md` | `program/thesis/ideas/<slug>.md` | ý tưởng đồ án tốt nghiệp |
| `specialization-track.md` | `program/specialization/tracks/<hướng>.md` | đánh giá hướng chuyên ngành |

---

## Template có token

Bảy template đầu bảng trên được **script render** bằng token `{{CODE}}`, `{{NAME_VI}}`,
`{{LECTURER}}`, `{{NUM}}`, `{{DATE}}`…

**Sửa template thì môn/buổi tạo sau sẽ đổi theo** — đó là chủ ý, một nguồn sự thật duy nhất.
Bảy template còn lại không có token, AI điền tay.

Danh sách token đầy đủ: xem hàm `render()` trong `scripts/new-course.sh` và
`scripts/new-lecture.sh`.
