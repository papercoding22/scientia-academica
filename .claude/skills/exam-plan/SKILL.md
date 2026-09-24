---
name: exam-plan
description: Lập kế hoạch ôn thi cho một hoặc nhiều môn khi đã biết ngày thi — đọc lịch Google Calendar (lịch học UIT Class, lịch Work) để tìm khung giờ trống, xếp buổi ôn lùi từ ngày thi theo trọng số exam blueprint, in bảng xem trước, rồi (sau khi duyệt) tạo task Notion theo template và sự kiện Google Calendar trên lịch Work. Dùng khi người dùng nói "lên kế hoạch ôn thi", "lịch ôn thi môn X", "tạo task ôn thi và lịch", "sắp xếp ôn thi", "tôi thi ngày … thì ôn thế nào", hoặc vừa cung cấp lịch thi.
---

# Lập kế hoạch ôn thi → Notion + Google Calendar

Người dùng là dev đi làm, học từ xa, quỹ thời gian hẹp. Kế hoạch tốt là kế hoạch **nhét vừa
khung giờ thật còn trống** — không phải kế hoạch lý tưởng mỗi ngày một chương.

```
 deadlines.md ─┐                                    ┌─▶ Notion ☕ Tasks (template)
 exam-map      ├─▶ xếp lùi từ ngày thi ─▶ xem trước ─┤
 IMPORTANT_NOTES│   (tránh giờ học, giờ bận)   duyệt │
 Google Calendar┘                                    └─▶ Google Calendar (lịch Work)
```

Skill này **điều phối**. Việc ghi Notion tuân theo skill `notion-tasks` (template trang task, map
property, `notion-map.json`) — đọc phần đó thay vì tự nghĩ lại.

---

## Mục lục

- [Bước 1 — Thu thập đầu vào](#bước-1--thu-thập-đầu-vào)
- [Bước 2 — Kiểm tra nguồn ôn có đủ không](#bước-2--kiểm-tra-nguồn-ôn-có-đủ-không)
- [Bước 3 — Hỏi ràng buộc](#bước-3--hỏi-ràng-buộc)
- [Bước 4 — Đọc lịch](#bước-4--đọc-lịch)
- [Bước 5 — Xếp buổi ôn](#bước-5--xếp-buổi-ôn)
- [Bước 6 — Xem trước và duyệt](#bước-6--xem-trước-và-duyệt)
- [Bước 7 — Ghi](#bước-7--ghi)
- [Khi kế hoạch lệch](#khi-kế-hoạch-lệch)
- [Bước 8 — Báo lại](#bước-8--báo-lại)
- [Không làm](#không-làm)

---

## Bước 1 — Thu thập đầu vào

| Cần | Lấy ở đâu | Nếu thiếu |
|---|---|---|
| **Ngày + giờ thi** (tuyệt đối) | `admin/deadlines.md` mục *Lịch thi* | **Hỏi.** Không đoán ngày, không đoán ca |
| Hình thức, thời lượng, được mang gì | `IMPORTANT_NOTES.md` mục 5, `exam-prep/EXAM_PREP.pdf` nếu có | Ghi `❓` vào task thi, nhắc người dùng tra |
| Phạm vi + trọng số | Theo thứ tự tin cậy: (1) `exam-prep/exam-map.md` blueprint · (2) phạm vi ôn tập giảng viên đưa (`EXAM_PREP.pdf`) · (3) `IMPORTANT_NOTES.md` mục 2, 3 — **có nguồn mới dùng** · (4) `materials/slides/knowledge-map.md` hoặc danh sách `lectures/` | Chia đều theo chương và **nói rõ đó là chia đều** |
| Mã ca thi → giờ | Người dùng cung cấp (vd *ca 4 = 15:00*) | Hỏi; không suy ca khác từ một ca |

Nhiều môn thi sát nhau → **lập một kế hoạch chung**, không lập từng môn rời rạc.

**Đầu phiên:** nếu có deadline giảng viên trong 7 ngày tới, báo trước (`AGENTS.md` § 10).

---

## Bước 2 — Kiểm tra nguồn ôn có đủ không

Kế hoạch xếp buổi ôn mà **không có tài liệu để ôn** là kế hoạch rỗng. Trước khi xếp, quét và báo:

| Lỗ hổng | Cách phát hiện | Đề xuất |
|---|---|---|
| Slide hỏng / thiếu chương | Skill `slide-knowledge-map` đã báo, hoặc PDF không mở được | Xin bản mới; ôn tạm bằng transcript |
| Buổi học chưa thành note | `lectures/_raw/` có mà `lectures/` chưa có | `new-lecture` |
| `cheatsheet.md` / `flashcards` trống | Đọc file | Sinh cheatsheet **trước** buổi ôn đầu tiên |
| Chưa có `exam-map.md` mà đã có đề mẫu | Có `SAMPLE_*`, `*exam*` trong `exam-prep/` | `exam-map` |
| Chương nặng điểm mà chưa có note | So blueprint với `lectures/` | Xếp buổi ôn chương đó vào **sau** lúc note có, hoặc ôn thẳng từ slide và nói rõ |

Lỗ hổng thuộc chương nặng điểm → đưa vào bảng xem trước ở dạng cảnh báo, không giấu.

---

## Bước 3 — Hỏi ràng buộc

Chỉ hỏi cái **chưa biết** (đã trả lời trong phiên thì không hỏi lại):

1. **Bắt đầu ôn từ ngày nào?** (mặc định: ngày mai)
2. **Khung giờ ôn được:** ngày thường sau giờ học/làm, cuối tuần. Người dùng đi làm — **đừng giả định ôn mỗi ngày**.

Không hỏi những thứ đọc được từ lịch (giờ học, buổi bận) — đọc ở bước 4.

---

## Bước 4 — Đọc lịch

Tra `calendarId` **theo tên** bằng `list_calendars` (không hardcode id vào repo):

| Lịch | Dùng để |
|---|---|
| **`UIT Class`** | Giờ học lớp — **đọc, đừng giả định**. Mọi buổi học ban đêm là khung cấm |
| **`Work`** | Nơi **ghi** sự kiện ôn/thi; cũng đọc để tránh trùng |
| Lịch chính, `Gym`, `Life` | Đọc để tránh trùng. **Không ghi vào đây** |

Gọi `list_events` từ ngày bắt đầu ôn tới ngày thi cho các lịch trên, `timeZone = Asia/Ho_Chi_Minh`.

Rút ra **khung giờ trống**. Mặc định khi chưa có ràng buộc riêng:

| Loại ngày | Khung | Độ dài buổi |
|---|---|---|
| Ngày thường có lớp tối | Bắt đầu **sau khi lớp kết thúc + 15 phút**, tối đa tới 23:00 | ≤ 1,5 giờ |
| Ngày thường không có lớp | Tối, tránh sự kiện có sẵn | ≤ 2 giờ |
| Cuối tuần | Sáng ~09:00–11:30, chiều ~14:00–16:30 | ≤ 2,5 giờ / buổi |

Đọc thêm `admin/deadlines.md`: **tránh xếp buổi ôn nặng vào ngày sát hạn bài nộp** của giảng viên.

---

## Bước 5 — Xếp buổi ôn

Xếp **lùi từ ngày thi**. Mỗi kỳ thi có khung:

```
 [Ôn từng chương/cụm]  →  [Làm đề mẫu có bấm giờ]  →  [Ôn tổng + sửa chỗ sai]  →  [Thi]
   trọng số cao xếp sớm     ≥ 2 ngày trước thi          sáng ngày thi hoặc tối hôm trước
```

- **Chương/cụm:** mỗi task một chương hoặc cụm nhỏ (vd *Playfair + hàm băm*). Blueprint điểm cao → xếp **sớm hơn**, Priority cao hơn, buổi dài hơn. Mục có `⚠️ GỢI Ý THI` (có nguồn) cũng vậy.
- **Đề mẫu có bấm giờ:** đúng thời lượng thi thật, không mở tài liệu; chừa thời gian sửa sau đó. Chưa có đề mẫu → thay bằng *tự hỏi đáp* dựa trên `flashcards` / `Tự kiểm tra`.
- **Ôn tổng:** chỉ sửa chỗ sai và ôn nhanh flashcard. **Không học phần mới.** Nếu thi buổi chiều thì sáng cùng ngày; thi buổi sáng thì tối hôm trước, nhẹ.
- **Hai kỳ thi liền nhau** (vd T7 chiều rồi CN sáng): ngày thi môn A **không** ôn môn B trong 2 giờ trước giờ thi A; có thể ôn môn B vào tối sau khi thi xong A, ≤ 2,5 giờ.
- **Không xếp trùng** sự kiện có sẵn. Không đủ khung trống → **nói thẳng** thiếu bao nhiêu giờ, đề xuất bỏ mục trọng số thấp; không nhồi.
- Blueprint chỉ có một phần đề (đề mẫu thiếu câu) → **nói rõ** thứ tự ưu tiên là suy luận từ dữ liệu một phần.

**Tên task:**

| Loại | Tên |
|---|---|
| Ôn | `<TT>: Ôn <phạm vi>` |
| Đề mẫu | `<TT>: Làm đề mẫu có bấm giờ` |
| Tổng | `<TT>: Ôn tổng + sửa chỗ sai` |
| Thi | `<TT>: Thi <mã môn> — ca <n>` |

`<TT>` = viết tắt môn (bảng trong `notion-tasks`). **Deadline task = giờ kết thúc buổi.**

**Câu hỏi "Kết quả đầu ra"** (bắt buộc, 3–4 câu mỗi task ôn — xem quy tắc ở `notion-tasks`):
tự trả lời được khái niệm chính chưa? · làm lại câu đề mẫu thuộc mục này, sai câu nào? ·
(với chương tính toán) tự làm được bài tính không nhìn lời giải chưa? Task thi có câu về phòng thi,
được mang gì, và cảm nhận sau thi để ghi vào `IMPORTANT_NOTES.md`.

**Mô tả (Notes + trang):** phạm vi mục/slide, đường dẫn note/blueprint trong repo. Task nhiều chương
nối nhau bằng mục **Phụ thuộc** (ôn → đề mẫu → ôn tổng → thi).

**Priority:** `High` cho mọi task của kỳ thi còn ≤ 14 ngày; xa hơn thì theo luật ở `notion-tasks`.

---

## Bước 6 — Xem trước và duyệt

**Bắt buộc.** In một bảng:

| # | Ngày | Giờ | Việc | Priority | Câu hỏi đầu ra (rút gọn) |
|---|---|---|---|---|---|

Kèm ngay dưới:

- **Cảnh báo lỗ hổng nguồn ôn** (bước 2) và **xung đột lịch** đã né.
- Nếu tạo được cả Google Calendar: nhắc nhở mỗi loại — buổi ôn **30 phút**, buổi thi **1 ngày + 2 giờ**.
- Câu hỏi cụ thể để duyệt: *OK* hoặc chỉnh (vd *"cuối tuần bắt đầu 8:00"*). Người dùng có thể duyệt một phần.

Chưa có chữ *OK* thì **chưa ghi gì** — cả Notion lẫn Calendar.

---

## Bước 7 — Ghi

Thứ tự **Notion trước, Calendar sau**, vì sự kiện cần link trang Notion.

**1. Notion** (`notion-create-pages` lên data source ☕ Tasks; schema đọc bằng `notion-fetch` đầu phiên):

- `Category = University`, `Status = To Do`, `Priority` theo bước 5, `Deadline` datetime `+07:00`, **không gắn 📺 Projects**.
- Nội dung trang **đúng template** ở `notion-tasks` (Mô tả · Kết quả đầu ra · Các bước · Phụ thuộc · Nhật ký), điền sẵn, không để trống.
- Task đã có trong `admin/notion-map.json` (chạy lại lần 2) → **cập nhật**, không tạo trùng.

**2. Google Calendar** — lịch **`Work`** (`calendarId` tra theo tên), `timeZone = Asia/Ho_Chi_Minh`:

| Sự kiện | Thời gian | Nhắc | Khác |
|---|---|---|---|
| Buổi ôn / đề mẫu | đúng khung đã duyệt | popup 30 phút | Mô tả: phạm vi + link task Notion |
| Thi | giờ thi → + thời lượng | popup **1 ngày** + **2 giờ** | `location` = nơi thi; mô tả: hình thức, được mang gì, phòng thi `❓` nếu chưa biết |

Tiêu đề sự kiện = tên task bỏ dấu `:` (vd `HDH Ôn chương 7 — Quản lý bộ nhớ`).

**3. `admin/notion-map.json`** (gitignore): khoá `<MÃ>/exam-<final|mid>` cho task thi và
`<MÃ>/exam-<final|mid>/r<nn>` cho task ôn, ghi ngay sau khi tạo — đứt giữa chừng thì lần sau
vẫn biết cái nào đã có. Lưu thêm `event` (id sự kiện Calendar) nếu muốn dời/xoá sau này.

**Không ghi kế hoạch ôn vào `admin/deadlines.md`** — file đó chỉ giữ hạn của giảng viên. Ngày thi mới
là dữ liệu của nó, và đã ghi từ trước.

Sau khi ghi, **mở lại** một task Notion và một sự kiện để kiểm tra giờ hiển thị đúng (lệch múi giờ là lỗi âm thầm).

---

## Khi kế hoạch lệch

Người dùng trượt buổi ôn, đổi giờ thi, hay xong sớm → **cập nhật** thay vì lập lại:

- Dời buổi: sửa `Deadline` task (`notion-update-page`) **và** sự kiện (`update_event`). Hỏi trước khi dời.
- Sự kiện tạo nhầm lịch: Google Calendar không cho chuyển lịch → tạo lại trên `Work`, rồi xoá bản cũ (`notificationLevel = NONE`).
- Buổi bỏ hẳn: chuyển task sang `Archived` (nếu được duyệt), **không xoá**; xoá sự kiện tương ứng.
- Đổi ngày thi: cập nhật `deadlines.md` trước (nguồn sự thật), rồi mới tính lại kế hoạch.

---

## Bước 8 — Báo lại

Bao nhiêu task và sự kiện đã tạo · **link** database Notion · buổi ôn đầu tiên sắp tới · lỗ hổng nguồn ôn
còn lại và skill nào xử lý được · deadline giảng viên trong 7 ngày tới.

Kế hoạch chỉ nằm trên Notion và Calendar nên **thường không có gì để commit**. Chỉ commit khi kèm sửa file
tracked (`deadlines.md`, `IMPORTANT_NOTES.md`): `<MÃ MÔN>: kế hoạch ôn thi`.

---

## Không làm

- ❌ **Không ghi Notion hay Calendar trước khi người dùng duyệt bảng xem trước.**
- ❌ **Không xếp buổi ôn vào giờ học** (UIT Class) hay giờ đã có sự kiện. Không bao giờ dùng lịch chính.
- ❌ **Không đoán ngày thi hay giờ của ca.**
- ❌ Không bịa phạm vi thi hay "gợi ý thi". Chia đều thì ghi *chia đều*; suy luận từ đề mẫu thì ghi *suy luận*.
- ❌ Không giấu lỗ hổng nguồn ôn (slide hỏng, chưa có note) — chúng quyết định kế hoạch có làm được không.
- ❌ Không ghi kế hoạch ôn vào `admin/deadlines.md`.
- ❌ Không tạo task trùng; không xoá task Notion (tối đa `Archived`, và chỉ khi được duyệt).
- ❌ Không hạ Priority người dùng đã tự đặt.
- ❌ Không nhồi buổi ôn khi khung trống không đủ — nói thiếu bao nhiêu giờ.
