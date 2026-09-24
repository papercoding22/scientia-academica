---
name: new-lecture
description: Xử lý một buổi học thành note hoàn chỉnh — chạy script tạo file _raw (nạp được .vtt từ Teams), rồi đọc transcript cùng slide để viết note, trích gợi ý thi vào IMPORTANT_NOTES, trích deadline vào admin/deadlines, sinh flashcard, cập nhật bảng tiến độ. Dùng khi người dùng nói "xử lý buổi N môn X", "tạo note buổi học", "có transcript buổi hôm nay", "init lecture", hoặc đưa file transcript/vtt của một buổi học.
---

# Xử lý một buổi học

Luật nền nằm ở `AGENTS.md` § 5 — skill này là quy trình chi tiết, không thay thế nó.
Riêng **cấu trúc note** (Bước 5) là ngoại lệ có chủ đích của `AGENTS.md` § 3.

Chia hai nửa: **script làm phần cơ học, bạn làm phần đọc hiểu nội dung.**

---

## Mục lục

- [Bước 1 — Xác định đang ở tình huống nào](#bước-1--xác-định-đang-ở-tình-huống-nào)
- [Bước 2 — Chạy script (chỉ khi cần tạo file mới)](#bước-2--chạy-script-chỉ-khi-cần-tạo-file-mới)
- [Bước 3 — Đọc hai nguồn cùng lúc](#bước-3--đọc-hai-nguồn-cùng-lúc)
- [Bước 4 — Đặt tên file note](#bước-4--đặt-tên-file-note)
- [Bước 5 — Viết note](#bước-5--viết-note)
- [Bước 6 — Rút thông tin ra 3 file khác](#bước-6--rút-thông-tin-ra-3-file-khác)
- [Bước 7 — Cập nhật bảng tiến độ](#bước-7--cập-nhật-bảng-tiến-độ)
- [Bước 8 — Commit và báo lại](#bước-8--commit-và-báo-lại)
- [Không làm](#không-làm)

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

Dùng `templates/lecture-note.md`. Mỗi mục (khái niệm) trong `## Nội dung chính` có **bốn phần, đúng thứ tự**:

| # | Phần | Trả lời câu hỏi | Bắt buộc |
|---|---|---|---|
| 1 | 📚 **Lý thuyết** | Khái niệm này là gì **và vì sao buộc phải có** — theo chuẩn học thuật | ✅ |
| 2 | 💡 **Giải thích dễ hiểu** | Nói lại bằng lời thường: trực giác, analogy, ví dụ nhỏ nhất, hình vẽ | ✅ |
| 3 | 💻 **Code & thực tế** | Chạy được thế nào; dev đi làm gặp lại nó ở đâu | Khi áp dụng được |
| 4 | ✍️ **Bài tập** | Biết khái niệm này thì giải được bài gì, giải thế nào | ✅ |

> **Thứ tự này thay cho thứ tự 5 bước ở `AGENTS.md` § 3** — chỉ áp dụng cho **note bài giảng**.
> Trả lời trong chat và phiên `study-tutor` vẫn giữ thứ tự trực giác → analogy → ví dụ → định nghĩa.
> Lý do đổi: note là tài liệu ôn thi dựng lại từ đầu, người đọc cần **nền học thuật chính xác trước**,
> rồi mới cần lời giải thích thân thiện để hiểu nó; đảo ngược lại thì dễ nhớ lệch.

### 5a. Lý thuyết — chuẩn học thuật + gốc rễ

**Gốc rễ (first principles)** đặt **đầu tiên**, ngắn (5–8 dòng). Mục đích: khái niệm hiện ra như *hệ quả tất yếu*
của một vấn đề, không phải một quy ước phải học thuộc. Cấu trúc cố định:

1. **Ngữ cảnh:** khái niệm sống trong bức tranh lớn nào?
2. **Vấn đề gốc:** thiếu nó thì cái gì hỏng hoặc không giải được?
3. **Những sự thật nền:** 2–3 ràng buộc **không bỏ được** (vd *CPU chỉ tính trên thanh ghi*, *OS có thể ngắt bất cứ lúc nào*).
4. **Suy luận:** sự thật 1 + sự thật 2 ⇒ … ⇒ khái niệm. Mỗi bước phải là hệ quả **logic**, không phải lịch sử kể lại.
5. **Nếu không có nó thì sao?** một hậu quả cụ thể, tốt nhất có số.

Cách tìm gốc rễ: hỏi **"nếu chỉ dùng những gì chắc chắn đúng, mình phải tự nghĩ ra thứ này thế nào?"** và **"trong slide,
cái gì được đặt trước cái này, và nó thiếu gì mà phải cần cái này?"**. Các mục liên tiếp trong một buổi thường nối nhau
bằng chính câu hỏi thứ hai — đó là chuỗi ghi ở `## Gốc rễ của cả buổi`.

Luật với gốc rễ:
- Phần suy luận **không có trong slide/transcript** phải ghi nhãn `ngoài slide` (`AGENTS.md` § 12 — không bịa nội dung bài giảng).
- **Không bịa lịch sử** ("Dijkstra nghĩ ra vì…") khi không chắc. Có thể nêu năm/tác giả nếu chắc, kèm nhãn `ngoài slide`.
- Mục thuần quy ước (cú pháp, tên gọi) không có gốc rễ suy luận được → **bỏ dòng đó**, đừng gượng.

**Định nghĩa hình thức:** trích **nguyên văn** slide/giáo trình, giữ thuật ngữ, kèm nhãn nguồn `[mã sN]`. Có ebook ở
`materials/books/` thì dùng làm nguồn chuẩn và ghi số trang (`AGENTS.md` § 8b). Sau đó tách rõ:
**tính chất · điều kiện áp dụng · ký hiệu**, và thuật toán/cơ chế nếu có.

### 5b. Giải thích dễ hiểu

Viết cho **dev đang đi làm** (`AGENTS.md` § 1): bỏ cú pháp cơ bản, đi thẳng vào *vì sao*.

- **Trực giác:** một câu, không thuật ngữ.
- **Analogy đời thường** — không được bỏ — kèm dòng ***Chỗ analogy vỡ***: điểm nào của khái niệm mà analogy mô tả sai.
  Analogy tốt ánh xạ **được từng thành phần** của khái niệm (ai = tiến trình, tờ giấy = biến chung…).
- **Ví dụ nhỏ nhất:** con số cụ thể, ca bé nhất (3 tiến trình, không phải N), **theo dõi từng bước** trong bảng trace.
- **Minh hoạ trực quan:** có **luồng, trạng thái hoặc quan hệ** thì **bắt buộc** vẽ (ASCII hoặc Mermaid); có diễn biến theo thời gian
  thì dùng bảng trace (cột = mỗi biến). Hình phải chỉ ra **chỗ hỏng hoặc chỗ mấu chốt**, không vẽ cho đẹp.

### 5c. Code & thực tế

Code phải chạy được và đã chạy thử; ghi lệnh chạy và kết quả thật. Không áp dụng được thì ghi `không áp dụng — <lý do>`.
Dòng **Trong production** nối khái niệm với thứ dev dùng hàng ngày, luôn gắn nhãn `ngoài slide`.

### 5d. Bài tập — và kiến thức giải bài thế nào

Mỗi mục 1–3 bài (mục nặng điểm nhiều hơn), **từ dễ đến khó** (Nhớ → Hiểu → Vận dụng → Phân tích). Nguồn, theo thứ tự ưu tiên:
1. Bài tập có trong slide · 2. Câu trong đề mẫu (`exam-prep/exam-map.md`, ghi số câu) · 3. **Tự đặt** (ghi rõ `tự đặt`).

Mỗi bài có ba phần:
- **Đề** + mức nhận thức + nguồn.
- **🔑 Kiến thức mở khoá:** *khái niệm hoặc tính chất nào ở phần Lý thuyết giúp giải bài này, và giúp ở bước nào.* Đây là phần quan trọng
  nhất — nó chứng minh kiến thức không phải để thuộc mà để dùng.
- **Hướng giải** gập trong `<details>`, mỗi bước nối về kiến thức ở trên.

Luật:
- **Không** đưa vào đây bài tập **đang có hạn nộp** — chuyển sang `assignment-guide` (`AGENTS.md` § 6).
- Đề mẫu là tài liệu tham khảo, không phải lời giảng viên (`AGENTS.md` § 8).
- Bài tự đặt phải **kiểm được đáp án** (chạy code, tính tay hai lần) trước khi ghi.
- Mục cuối có dòng **Chốt mục**: điều cần mang đi thi và cái bẫy hay gặp.

### 5e. Mục phụ được rút gọn

Không phải mục nào cũng đáng đủ bốn phần. Mục **ít trọng số** (theo `exam-map.md`, hoặc giảng viên chỉ lướt qua) → bản rút gọn:
**Định nghĩa hình thức + Trực giác + 1 bài**. Ghi rõ `*(mục phụ — bản rút gọn)*` ở đầu mục để người đọc biết không phải sót.

### 5f. Phần còn lại của note

- `## Tóm tắt một đoạn` và `## Gốc rễ của cả buổi` (sơ đồ chuỗi suy luận từ vấn đề gốc tới các khái niệm) viết **sau khi** xong các mục.
- Kết thúc bằng **bảng so sánh hoặc sơ đồ tổng**.
- `## Tự kiểm tra`: **5 câu**, đáp án gập trong `<details>` — khác các bài tập trong mục ở chỗ nó **ôn trộn nhiều mục**.

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
- ❌ Không bỏ analogy (và dòng *chỗ analogy vỡ*), kể cả khi khái niệm có vẻ đơn giản.
- ❌ Không viết phần "gốc rễ" bằng lịch sử tự bịa hoặc suy luận không gắn nhãn `ngoài slide`.
- ❌ Không đưa bài tập đang có hạn nộp vào mục ✍️ Bài tập; không ghi bài tự đặt khi chưa kiểm được đáp án.
- ❌ Không đảo thứ tự **Lý thuyết → Dễ hiểu → Code → Bài tập** trong note bài giảng.
- ❌ Không chạy script khi file `_raw` đã tồn tại — sẽ tạo trùng số buổi.
