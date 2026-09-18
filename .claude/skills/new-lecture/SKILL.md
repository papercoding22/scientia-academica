---
name: new-lecture
description: Xử lý một buổi học thành note hoàn chỉnh — chạy script tạo file _raw (nạp được .vtt từ Teams), rồi đọc transcript cùng slide để viết note, trích gợi ý thi vào IMPORTANT_NOTES, trích deadline vào admin/deadlines, sinh flashcard, cập nhật bảng tiến độ. Dùng khi người dùng nói "xử lý buổi N môn X", "tạo note buổi học", "có transcript buổi hôm nay", "init lecture", hoặc đưa file transcript/vtt của một buổi học.
---

# Xử lý một buổi học

Luật nền nằm ở `AGENTS.md` § 5 — skill này là quy trình chi tiết, không thay thế nó.

Chia hai nửa: **script làm phần cơ học, bạn làm phần đọc hiểu nội dung.**

---

## Bước 1 — Xác định đang ở tình huống nào

| Tình huống | Làm gì |
|---|---|
| Chưa có file `_raw` | Chạy script (bước 2) |
| Người dùng đưa file `.vtt`/`.txt` | Chạy script với `--from` |
| File `_raw` đã có sẵn, đã dán nội dung | **Bỏ qua bước 2**, sang bước 3 |

Kiểm tra trước: `ls semesters/*/[MÃ MÔN]-*/lectures/_raw/`

Người dùng thường nói gọn `xử lý buổi 3 IT007` khi file `_raw` đã dán sẵn.
Đừng chạy script trong trường hợp đó — nó sẽ tạo file trùng số buổi.

---

## Bước 2 — Chạy script (chỉ khi cần tạo file mới)

```bash
# Chưa có gì, tạo chỗ trống để dán
scripts/new-lecture.sh --course IT007

# Có file .vtt tải từ Teams — script tự chuyển sang markdown,
# giữ timestamp và gộp các cue liên tiếp của cùng người nói
scripts/new-lecture.sh --course IT007 --from ~/Downloads/meeting.vtt --date 2026-10-06
```

Script tự tìm số buổi tiếp theo, tự đọc tên môn và giảng viên từ `README.md` của môn.

**Đừng truyền `--topic` ở bước này** trừ khi người dùng đã nói rõ chủ đề.
Chủ đề chỉ biết chắc sau khi đọc nội dung — đặt tên ở bước 4.

---

## Bước 3 — Đọc hai nguồn cùng lúc

Đọc **cả hai**, đừng chỉ đọc một:

| Nguồn | Cho gì | Thiếu gì |
|---|---|---|
| `lectures/_raw/L<nn>-*.md` | Lời giảng viên nói thêm ngoài slide, **gợi ý thi**, deadline | Sai chính tả thuật ngữ rất nhiều |
| `materials/slides/L<nn>-*.pdf` | Cấu trúc bài, thuật ngữ viết đúng, công thức | Không có phần nói miệng |

Transcript Teams tiếng Việt lẫn thuật ngữ tiếng Anh **luôn sai chính tả** —
`"đét lốc"` là `deadlock`, `"ét gio rítừm"` là `algorithm`. Slide sửa lại cho đúng.
Ngược lại, câu *"cái này chắc chắn sẽ thi"* chỉ có trong transcript.

Không có slide → vẫn làm được, nhưng đánh dấu `> ❓ **CẦN XÁC MINH:**` ở chỗ
thuật ngữ nghe không chắc. **Không đoán bừa thuật ngữ.**

---

## Bước 4 — Đặt tên file note

`lectures/L<nn>-<topic-slug>.md` — slug **tiếng Anh**, kebab-case, mô tả nội dung chính.

| Buổi nói về | ✅ | ❌ |
|---|---|---|
| Định thời CPU | `cpu-scheduling` | `dinh-thoi-cpu` |
| Quản lý bộ nhớ | `memory-management` | `quan-ly-bo-nho` |
| Tổng quan hệ điều hành | `os-overview` | `tong-quan` |

Slide có sẵn tên buổi thì bám theo đó. Buổi dạy nhiều chủ đề → lấy chủ đề chiếm
thời lượng nhiều nhất, đừng ghép ba thứ vào một tên.

---

## Bước 5 — Viết note

Dùng `templates/lecture-note.md`. Bắt buộc theo `AGENTS.md` § 3 — **5 bước, đúng thứ tự**:

1. Một câu trực giác (không thuật ngữ)
2. **Analogy đời thường** — người dùng yêu cầu rõ, không được bỏ
3. Ví dụ nhỏ nhất (con số cụ thể, 3 process chứ không phải N)
4. Định nghĩa hình thức
5. Code chạy được

Kết thúc bằng bảng so sánh hoặc outline. Có luồng xử lý → sơ đồ ASCII/Mermaid.

**Người dùng là dev đang đi làm** (`AGENTS.md` § 1): bỏ qua cú pháp cơ bản.
Nếu buổi học giải thích thứ họ dùng hàng ngày mà chưa hiểu gốc — nói ra, đó là
phần đáng giá nhất của buổi.

Mục `## Tự kiểm tra`: **5 câu**, đáp án gập trong `<details>`.

---

## Bước 6 — Rút thông tin ra 3 file khác

Đây là phần dễ quên nhất, và cũng là phần làm repo có giá trị dồn.

### 6a. Gợi ý thi → `IMPORTANT_NOTES.md`

Quét transcript tìm: *"cái này sẽ thi"* · *"nhớ kỹ chỗ này"* · *"đề hay ra"* ·
*"năm nào cũng có"* · *"về nhà xem lại"* · *"phần này quan trọng"*

Tìm thấy → ghi **cả hai chỗ**:
- Trong note: `> ⚠️ **GỢI Ý THI:** <câu giảng viên nói>`
- Append vào `IMPORTANT_NOTES.md` mục 2 hoặc 3, **kèm nguồn**:
  `> *Nguồn: buổi 3, 2026-10-06 — "chương 3 năm nào cũng ra"*`

Có timestamp trong transcript thì ghi luôn phút — sau này tra lại được.

> ⚠️ **Không suy diễn.** Chỉ ghi khi giảng viên **nói ra**. Giảng viên dành 30 phút
> cho một chủ đề **không phải** là bằng chứng nó sẽ thi. `IMPORTANT_NOTES.md`
> là nguồn dựng cheatsheet — bịa vào đó là làm hỏng kỳ ôn thi.

### 6b. Quy định, cách tính điểm → `IMPORTANT_NOTES.md` mục 1 và 4

Buổi đầu tiên thường công bố cách tính điểm. Nghe thấy → điền ngay vào mục 1.

### 6c. Deadline → `admin/deadlines.md`

**Luôn chuyển sang ngày tuyệt đối.** *"nộp tuần sau"* + buổi ngày `2026-10-06`
→ `2026-10-13`. Không đủ thông tin quy đổi → hỏi, không đoán.

### 6d. Flashcard → `exam-prep/flashcards.md` **và** `.csv`

Hai file phải khớp nhau. CSV: `Mặt trước;Mặt sau;Tag`, phân cách `;`, giữ UTF-8 BOM.
Tag theo buổi: `L03`. Khoảng 8–15 thẻ mỗi buổi — thẻ tốt hơn thẻ nhiều.

---

## Bước 7 — Cập nhật bảng tiến độ

| File | Sửa gì |
|---|---|
| `<môn>/README.md` | Thêm dòng vào **Tiến độ buổi học**: buổi · ngày · chủ đề · link note · ✅ |
| `semesters/<kỳ>/README.md` | Cộng số ở bảng **Tiến độ**: số buổi đã có note, số flashcard |

Khái niệm dùng được cho môn khác → tạo file trong `knowledge-base/`, **link hai chiều**.
Buổi học gợi ra hướng đồ án tốt nghiệp → `program/thesis/ideas/<slug>.md` kèm nguồn gốc.

---

## Bước 8 — Commit và báo lại

```
<MÃ MÔN>: note buổi <nn> + <n> flashcard
```

Báo ngắn gọn: đã tạo note nào, **gợi ý thi bắt được mấy cái**, deadline mới,
số flashcard, và **chỗ nào còn `❓ CẦN XÁC MINH`** để người dùng tự xác nhận.

---

## Không làm

- ❌ **Không sửa file trong `lectures/_raw/`** — đó là bằng chứng gốc (`AGENTS.md` § 12).
- ❌ Không bịa nội dung không có trong transcript. Thiếu → `> ❓ **CẦN XÁC MINH:**`.
- ❌ Không ghi vào `IMPORTANT_NOTES.md` thứ giảng viên không nói ra.
- ❌ Không đặt tên file note bằng tiếng Việt bỏ dấu.
- ❌ Không bỏ bước analogy ở § 3, kể cả khi khái niệm có vẻ đơn giản.
- ❌ Không chạy script khi file `_raw` đã tồn tại — sẽ tạo trùng số buổi.
