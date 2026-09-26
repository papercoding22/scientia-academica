---
name: tidy-files
description: Chuẩn hoá tên file và xếp file vào đúng thư mục theo cấu trúc repo, sau khi người dùng thả file thủ công vào một môn học. Chạy scripts/check-layout.sh để tìm file sai chỗ hoặc sai tên, đọc nội dung từng file để biết nó là gì, rồi git mv vào đúng chỗ và cập nhật các bảng tham chiếu. Dùng khi người dùng nói "tôi vừa thêm file vào...", "sắp xếp lại", "tổ chức lại", "chuẩn hoá tên file", "dọn thư mục", "file này để đâu", hoặc đưa một đống file rời vào thư mục môn học.
---

# Dọn và chuẩn hoá file

Người dùng thả file thủ công vào repo — transcript, slide, bài tập đã làm — với tên
theo thói quen của họ hoặc của giảng viên. Việc của skill này là xếp đúng chỗ
**mà không làm mất thông tin có sẵn trong tên file**.

---

## Mục lục

- [Luật quan trọng nhất](#luật-quan-trọng-nhất)
- [Bước 1 — Quét](#bước-1--quét)
- [Bước 2 — Nhận dạng từng file](#bước-2--nhận-dạng-từng-file)
- [Bước 3 — Quyết định đích đến](#bước-3--quyết-định-đích-đến)
- [Bước 4 — Trình bày kế hoạch và hỏi](#bước-4--trình-bày-kế-hoạch-và-hỏi)
- [Bước 5 — Thực hiện](#bước-5--thực-hiện)
- [Bước 6 — Cập nhật bảng tham chiếu](#bước-6--cập-nhật-bảng-tham-chiếu)
- [Bước 7 — Commit và báo lại](#bước-7--commit-và-báo-lại)
- [Không làm](#không-làm)

---

## Luật quan trọng nhất

> ⚠️ **Tên file mang thông tin thì KHÔNG được chuẩn hoá mất đi.**

Đây là lỗi dễ mắc nhất, và đã suýt xảy ra hai lần trong repo này:

| Tên gốc | Phản xạ sai | Đúng |
|---|---|---|
| `Bài tập 3A_Nguyễn Quốc Trung_25730081.docx` | đổi thành `BT3A-…` | **giữ nguyên** — giảng viên dặn mẫu này |
| `Bài 3A - Dò tìm lỗ hổng - Thăm dò.pdf` | đổi thành `L05-…` | **giữ nguyên** — "Bài 3A" là số chương, `L05` là số buổi, hai thứ khác nhau |
| `07.08.docx` | giữ nguyên | **đổi** — `MM.DD` mơ hồ, không mang thông tin gì thêm |

**Cách phân biệt:** hỏi *"đổi tên này có làm mất thông tin nào không?"*
- Mất → giữ nguyên, hoặc thêm tiền tố chứ không thay thế.
- Không mất → chuẩn hoá thoải mái.

**Ba loại luôn giữ nguyên tên:**
1. **File nộp cho giảng viên** — mẫu tên do giảng viên quy định (`AGENTS.md` § 13.3).
   Mẫu của IE105: `Bài tập <N>_Họ tên_MSSV`. Môn khác có thể khác — kiểm tra
   `IMPORTANT_NOTES.md` mục 4 của môn đó trước.
2. **File trong `materials/`** — bản gốc của giảng viên, tên thường có số chương.
3. **File trong `brief/`** — đề bài gốc.

---

## Bước 1 — Quét

```bash
scripts/check-layout.sh --course IE105    # một môn
scripts/check-layout.sh                   # toàn repo
```

Script báo cáo, **không tự sửa**. Nó bắt: file nằm trơ trong thư mục chứa ·
tên transcript sai quy ước · tên note sai quy ước · slide có tên vô nghĩa ·
thư mục bài tập thiếu khung · tên có dấu tiếng Việt ngoài chỗ được miễn.

Người dùng nói rõ vừa thả file vào đâu → xem thẳng chỗ đó, không cần quét cả repo.

---

## Bước 2 — Nhận dạng từng file

**Không bao giờ đoán từ tên file.** Tên cũ chính là thứ đang sai.

```bash
scripts/peek.py <file>          # .pdf .docx .pptx .xlsx .vtt .txt .md — metadata + 15 đoạn đầu
scripts/peek.py --full <file>   # toàn bộ
```

**PDF:** `peek.py` in số trang và chữ trích từ trang đầu. Báo `Không có lớp chữ` hoặc
chữ trích ra không đủ để nhận dạng → dùng công cụ **Read** cho vài trang đầu.
Sau khi xếp PDF vào `materials/`, chạy `scripts/slides-to-md.py --course <mã>` để bộ đệm
tìm kiếm có file mới.

Cần rút ra:

| Câu hỏi | Tìm ở đâu |
|---|---|
| Đây là loại gì? | Tiêu đề đầu file: "BÀI TẬP 4", "Bản ghi cuộc họp", "ĐỀ CƯƠNG" |
| Ngày nào? | Metadata trong file — vd `20260708_182915` trong tiêu đề bản ghi Teams |
| Buổi/bài số mấy? | Tiêu đề, hoặc đối chiếu nội dung với `IMPORTANT_NOTES.md` mục 6 |
| Môn nào? | Mã lớp trong file, vd `IE105.F31.CN1.CNTT` |

> ⚠️ **Ngày lấy từ TRONG file, không từ tên file.** `07.08` mơ hồ giữa 8/7 và 7/8 —
> đã gặp thật: tên file ghi `07.08` (MM.DD) còn tiêu đề bên trong ghi `08.07.2026` (DD.MM).
> Metadata `20260708` mới là thứ quyết định.

---

## Bước 3 — Quyết định đích đến

| Nội dung file | Đích | Tên |
|---|---|---|
| Transcript Teams, note gõ trong lớp | `lectures/_raw/` | `L<nn>-<YYYY-MM-DD>-transcript.<đuôi>` |
| Note đã cấu trúc hoá | `lectures/` | `L<nn>-<topic-tiếng-anh>.md` |
| Đề cương môn học | `materials/syllabus/` | giữ nguyên |
| Slide bài giảng | `materials/slides/` | giữ nguyên nếu có "Bài N"; đặt tên mô tả nếu vô nghĩa |
| Giáo trình, ebook | `materials/books/` | giữ nguyên |
| Bài báo, chuẩn, tài liệu lẻ | `materials/references/` | giữ nguyên |
| **Bài tập đã làm** | `assignments/a<số bài>/` | **giữ nguyên tên** |
| Đề bài giảng viên gửi | `assignments/a<n>/brief/` | giữ nguyên |
| Ảnh chụp lúc làm bài | `assignments/a<n>/images/` | `<mô-tả-tiếng-anh>.png` |
| Đồ án | `projects/prj<n>/` | giữ nguyên bản nộp |
| Code thử nghiệm | `code/` | tự do |
| Note theo khái niệm | `notes/` | `<concept-tiếng-anh>.md` |

### Đánh số thư mục bài tập

**Bám theo số bài giảng viên đặt, KHÔNG đánh lại tuần tự** (`AGENTS.md` § 13.4):

```
Bài tập 3A → a3a/     Bài tập 4 → a4/     Bài tập 7 → a7/
```

Số bài hay nhảy cóc và có phần A/B. Đánh tuần tự thì khi bổ sung bài còn thiếu
sẽ phải xáo lại toàn bộ.

**Thư mục bài tập mới phải đủ:** `README.md` · `brief/` · `resources/` · `images/`
Dùng `templates/assignment.md`, điền đề bài trích từ transcript nếu có
(`lectures/_raw/` thường ghi lại lời thầy giao bài).

---

## Bước 4 — Trình bày kế hoạch và hỏi

**Luôn in bảng kế hoạch trước khi di chuyển bất cứ thứ gì:**

```
File                                    →  Đích
────────────────────────────────────────────────────────────────
Bài tập 3A_Nguyễn Quốc Trung_…docx      →  assignments/a3a/  (giữ tên)
07.08.docx                              →  lectures/_raw/L01-2026-07-08-transcript.docx
de cuong.pdf                            →  materials/syllabus/  (giữ tên)
```

**Hỏi trước khi làm nếu:**
- Không chắc file thuộc buổi/bài nào
- Số buổi có khoảng trống, có thể lệch cả chuỗi
- File trùng tên với thứ đã có
- Nội dung không khớp môn nào trong repo

**Không hỏi, cứ làm** khi file tự nói rõ nó là gì và đích đến chỉ có một.

---

## Bước 5 — Thực hiện

**Luôn dùng `git mv`** để giữ lịch sử. File chưa được track thì `git add` trước rồi `mv`.

```bash
git mv "<cũ>" "<mới>"
```

Sau khi xong, chạy lại `scripts/check-layout.sh --course <mã>` để xác nhận sạch.

---

## Bước 6 — Cập nhật bảng tham chiếu

Chuyển file xong mà không cập nhật các bảng thì repo mất đồng bộ:

| File | Cập nhật khi |
|---|---|
| `<môn>/README.md` — bảng **Tiến độ buổi học** | thêm transcript hoặc note |
| `<môn>/README.md` — bảng **Bài tập và đồ án** | thêm bài tập hoặc đồ án |
| `admin/deadlines.md` | bài tập có hạn nộp, hoặc đã nộp xong |
| `<môn>/IMPORTANT_NOTES.md` mục 6 | có buổi học mới |
| `semesters/<kỳ>/README.md` — bảng tiến độ | số buổi, số bài thay đổi |

**Nếu phát hiện lỗ hổng, nói ra.** Ví dụ đã gặp thật: bài tập 6 và 7 nói về nội dung
không có trong transcript nào → suy ra còn buổi 8, 9, 10 chưa có transcript.
Những suy luận kiểu này có giá trị hơn việc dọn file.

---

## Bước 7 — Commit và báo lại

```
<MÃ MÔN>: dọn <n> file vào đúng cấu trúc
```

Báo lại: đã chuyển gì đi đâu · **tên nào giữ nguyên và vì sao** ·
bảng nào đã cập nhật · **lỗ hổng phát hiện được** · chỗ nào còn `❓` cần người dùng xác nhận.

---

## Không làm

- ❌ **Không đổi tên file nộp cho giảng viên.** Kiểm tra `IMPORTANT_NOTES.md` mục 4 của môn
  để biết mẫu tên giảng viên yêu cầu trước khi động vào.
- ❌ **Không sửa nội dung** file trong `materials/`, `lectures/_raw/`, `brief/` — chỉ di chuyển và đổi tên.
- ❌ **Không đoán ngày, số buổi, số bài từ tên file cũ.** Đọc nội dung.
- ❌ **Không đánh lại số bài tập tuần tự** khi số gốc có khoảng trống.
- ❌ **Không xoá file nào** — kể cả file trông như trùng lặp. Báo cho người dùng, để họ quyết.
- ❌ Không dùng `mv` trần khi file đã được git track — dùng `git mv`.
