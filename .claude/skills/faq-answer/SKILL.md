---
name: faq-answer
description: Trả lời nhanh, ngắn gọn một câu hỏi về một chương/chủ đề, đồng thời append câu hỏi đó vào file faqs-<chapter-or-concept>.md để dồn thành kho FAQ tra cứu lại được. Dùng khi người dùng hỏi dồn dập nhiều câu về cùng một chương ("tập trung vào chương 3, trả lời nhanh"), hoặc nói "lưu câu này vào FAQ", "tạo FAQ cho chương/chủ đề X".
---

# Trả lời nhanh + dồn vào FAQ

Hai việc trong một lượt: **trả lời ngay trong chat** (ngắn) + **append vào file FAQ** (đầy đủ hơn một chút để tra cứu sau).

---

## Mục lục

- [Bước 1 — Xác định chương/chủ đề và đường dẫn file](#bước-1--xác-định-chươngchủ-đề-và-đường-dẫn-file)
- [Bước 2 — Trả lời trong chat](#bước-2--trả-lời-trong-chat)
- [Bước 3 — Ghi vào file FAQ](#bước-3--ghi-vào-file-faq)
- [Bước 4 — Commit](#bước-4--commit)
- [Không làm](#không-làm)

---

## Bước 1 — Xác định chương/chủ đề và đường dẫn file

Người dùng đã nói "tập trung vào chương N" hoặc "chủ đề X" ở đầu phiên → dùng luôn,
đừng hỏi lại mỗi câu.

File nằm ở: `<môn>/exam-prep/faqs-<slug>.md`

| Slug theo | Ví dụ |
|---|---|
| Số chương | `faqs-chapter3.md` |
| Chủ đề xuyên chương | `faqs-security.md`, `faqs-deadlock.md` |

Chưa có file → tạo mới với khung ở Bước 3. Đã có → đọc để tránh trùng câu hỏi
(câu hỏi trùng ý thì gộp, không tạo mục thứ hai).

---

## Bước 2 — Trả lời trong chat

**Ngắn, đúng trọng tâm — đây là điểm khác biệt với note bài giảng đầy đủ.**

Không áp cứng nhắc đủ 5 bước của `AGENTS.md` § 3. Chỉ giữ phần có giá trị nhất
cho câu hỏi cụ thể đó:

- Câu hỏi khái niệm mới, dễ nhầm → **1 câu trực giác + 1 analogy đời thường**
- Câu hỏi "khác nhau chỗ nào" → **bảng so sánh**, không văn xuôi
- Câu hỏi "tại sao" → đi thẳng vào nguyên nhân, bỏ qua định nghĩa lại từ đầu
- Câu hỏi tính toán/cơ chế → **ví dụ số cụ thể** (3 process, không phải N)

Không mở đầu bằng "Đây là câu hỏi hay" hay tóm tắt lại câu hỏi. Trả lời thẳng.

Vẫn giữ luật ngôn ngữ `AGENTS.md` § 2: nội dung tiếng Việt, thuật ngữ giữ tiếng Anh.

---

## Bước 3 — Ghi vào file FAQ

Append một mục mới, KHÔNG ghi đè mục cũ. **Mỗi câu hỏi đánh số thứ tự `Q<n>`**
tăng dần theo thứ tự xuất hiện trong file (đếm câu hỏi đã có + 1, không đánh lại
số cũ khi thêm câu mới). Khung mỗi mục:

```markdown
## Q<n>. <câu hỏi, giữ nguyên cách hỏi của người dùng>

<trả lời — có thể dài hơn bản chat một chút, đủ để đọc lại mà không cần hỏi lại>

**Ví dụ:** <ví dụ cụ thể, số liệu/code nhỏ nếu hợp>

**Liên hệ đời thường:** <analogy, chỉ thêm nếu thực sự giúp hình dung>

**Mô tả trực quan:** <bảng so sánh / sơ đồ ASCII hoặc Mermaid — chỉ thêm nếu
khái niệm có luồng, trạng thái, hoặc so sánh nhiều chiều>
```

Ba mục cuối (**Ví dụ**, **Liên hệ đời thường**, **Mô tả trực quan**) là **tùy chọn theo
câu hỏi** — không phải khái niệm nào cũng cần cả ba. Ép đủ ba mục cho câu hỏi đơn giản
(vd "X là viết tắt của gì") sẽ làm file dài vô ích.

File mới tạo → thêm heading, mô tả, và **mục lục đánh số ngay từ câu hỏi đầu tiên**
(không đợi đủ 5 câu như `AGENTS.md` § 2b — FAQ dùng để tra cứu nhanh nên mục lục
cần có ngay):

```markdown
# FAQ nhanh — <tên chương/chủ đề>

Câu hỏi ngắn, trả lời nhanh khi ôn <chương/chủ đề>. Đầy đủ hơn thì xem
`lectures/L<nn>-*.md`.

## Mục lục

1. [<câu hỏi 1>](#q1-<anchor>)

---

## Q1. <câu hỏi 1>
...
```

**Mỗi lần append câu hỏi mới: thêm cả dòng vào Mục lục lẫn heading `## Q<n>.`**
— hai chỗ phải khớp số thứ tự, đừng chỉ sửa một chỗ.

---

## Bước 4 — Commit

```
<MÃ MÔN>: thêm FAQ chương <N> — <n> câu
```

Gộp nhiều câu hỏi trong cùng phiên hỏi-đáp thành **một commit cuối phiên**,
không commit sau mỗi câu — tránh làm loãng lịch sử git.

Sau khi ghi file, báo lại một câu ngắn: đã lưu vào FAQ nào, tổng bao nhiêu câu.
Không cần in lại toàn bộ nội dung file đã ghi.

---

## Không làm

- ❌ Không bắt người dùng chờ đọc file rồi mới trả lời trong chat — trả lời chat
  trước, ghi file là việc nền song song về mặt tổ chức nội dung.
- ❌ Không viết lại câu hỏi thành văn phong khác khi lưu vào heading `##` —
  giữ nguyên ý người dùng hỏi để tra cứu bằng Ctrl+F sau này còn khớp.
- ❌ Không thêm analogy/ví dụ/sơ đồ khi không cần — ba mục đó tùy chọn, không bắt buộc.
- ❌ Không tạo file FAQ mới nếu đã có file cùng slug — luôn append.
- ❌ Không bịa nội dung ngoài kiến thức đã có trong note/slide của môn khi trả lời
  câu hỏi chuyên sâu — không chắc thì nói không chắc, đừng đoán.
