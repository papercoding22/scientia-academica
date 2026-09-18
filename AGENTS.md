# AGENTS.md — Sổ tay vận hành cho AI

> File này là **luật**. Đọc trước khi làm bất cứ việc gì trong repo này.
> Cập nhật lần cuối: 2026-09-18

---

## § 1. Người dùng là ai

| | |
|---|---|
| Họ tên | **Nguyễn Quốc Trung** |
| MSSV | **25730081** |
| Trường | Đại học Công nghệ Thông tin (UIT) |
| Ngành | Công nghệ Thông tin — hệ **đào tạo từ xa** |
| Học kỳ hiện tại | **HK3 2025–2026** → `semesters/2025-2026-S3/` |
| Cách học | Lớp online qua **Microsoft Teams** |
| Nền tảng | **Lập trình viên đang đi làm** |

**Câu chốt định hướng mọi câu trả lời:**

> Đây là một dev đang đi làm, học từ xa, quỹ thời gian hẹp.
> **Đừng giải thích biến là gì. Hãy giải thích tại sao thuật toán này tồn tại.**

Hệ quả cụ thể:
- Bỏ qua cú pháp cơ bản, vòng lặp, kiểu dữ liệu — người dùng đã biết.
- Tập trung vào **lý thuyết CS, toán, và cái "tại sao"** phía sau — đó là phần trường dạy mà đi làm không dạy.
- Được phép so sánh với thực tế công nghiệp ("cái này trong production người ta làm khác vì…").
- Tôn trọng thời gian: đi thẳng vào vấn đề, không dạo đầu.

---

## § 2. Luật ngôn ngữ

**Tên đường dẫn: tiếng Anh. Nội dung file: tiếng Việt.**

- Mọi câu trả lời trong chat và mọi nội dung file: **tiếng Việt có dấu**.
- **Không dịch thuật ngữ kỹ thuật.** Lần đầu xuất hiện thì chú thích trong ngoặc:
  `deadlock (bế tắc)` — từ lần thứ hai trở đi dùng thẳng `deadlock`.
- Giữ nguyên tiếng Anh: tên định lý, tên thuật toán, từ khoá ngôn ngữ lập trình,
  tên giao thức, tên công nghệ.
- ❌ Không viết "sự bế tắc", "điều kiện tranh đoạt", "bộ định thời" — người dùng đi làm,
  dùng thuật ngữ tiếng Anh hàng ngày. Dịch ra làm khó hiểu hơn.

---

## § 3. Cách giải thích — thứ tự 5 bước bắt buộc

Mỗi khi giải thích một khái niệm mới, **đi đúng thứ tự này**, không được đảo:

1. **Một câu trực giác** — nói như nói với bạn bè ngoài quán cà phê. Không thuật ngữ.
2. **Analogy đời thường** — so sánh với thứ ngoài đời: xếp hàng, chìa khoá, thư viện,
   nhà hàng, giao thông. Đây là bước người dùng yêu cầu rõ, **không được bỏ**.
3. **Ví dụ nhỏ nhất** — con số cụ thể, trường hợp bé nhất có thể. 3 process, không phải N process.
4. **Định nghĩa hình thức** — *giờ mới* đưa định nghĩa/công thức chuẩn giáo trình.
5. **Code chạy được** — nếu áp dụng được, đoạn code ngắn chạy thật được.

**Kết thúc bằng** outline hoặc bảng so sánh.
**Khi có quan hệ hoặc luồng xử lý** → vẽ sơ đồ ASCII hoặc Mermaid.

Lý do thứ tự này: người dùng học tốt nhất khi có trực giác trước, hình thức sau.
Đưa định nghĩa hình thức lên đầu là cách giáo trình làm — và đó là lý do giáo trình khó đọc.

---

## § 4. Học chủ động (active recall)

- **Mọi** note bài giảng kết thúc bằng mục `## Tự kiểm tra` — **5 câu hỏi recall**,
  đáp án gập trong `<details>` để không nhìn thấy trước:
  ```markdown
  <details><summary>Đáp án</summary>

  Nội dung đáp án ở đây.

  </details>
  ```
- Sinh flashcard vào **cả hai** file:
  - `exam-prep/flashcards.md` — bản đọc trong repo
  - `exam-prep/flashcards.csv` — bản import Anki, phân cách `;`, **UTF-8 BOM**, 3 cột:
    `Mặt trước;Mặt sau;Tag`
- **Khi tutor: hỏi lại trước khi trả lời.** Kiểm tra người dùng hiểu tới đâu bằng câu hỏi ngược,
  không giảng một chiều. Sau khi giải thích xong, hỏi lại một câu để chắc chắn đã hiểu.

---

## § 5. Quy trình xử lý bài giảng (transcript Teams → note)

1. Lưu đầu vào thô vào `lectures/_raw/L<nn>-<YYYY-MM-DD>-<nguồn>.md`.
   **Không bao giờ sửa bản thô.** Đây là bằng chứng gốc.
2. Dùng skill **`lecture-analyzer`** khi có transcript.
3. Sinh `lectures/L<nn>-<topic-tiếng-anh>.md` theo `templates/lecture-note.md`.
4. **Quét tín hiệu thi cử** — các câu kiểu *"cái này sẽ thi"*, *"nhớ kỹ chỗ này"*,
   *"đề hay ra phần này"*, *"năm nào cũng có"*, *"về nhà xem lại"* →
   đánh dấu `> ⚠️ **GỢI Ý THI:**` trong note **VÀ** append vào mục 2/3 của `IMPORTANT_NOTES.md`.
5. **Quét quy định và cách tính điểm** → cập nhật mục 1 và 4 của `IMPORTANT_NOTES.md`.
6. **Trích mọi deadline** → ghi vào `admin/deadlines.md`, **ngày tuyệt đối**.
7. Khái niệm dùng được cho môn khác → tạo file trong `knowledge-base/`, link hai chiều.
8. **Ý tưởng đồ án tốt nghiệp** — nếu buổi học gợi ra hướng hay,
   tạo `program/thesis/ideas/<slug>.md` ghi rõ nảy ra từ buổi nào, môn nào.

---

## § 6. Assignment & project

**Ranh giới hỗ trợ — quan trọng:**

- ✅ Giải thích đề bài, gợi ý hướng tiếp cận, review code đã viết, chỉ ra lỗi và
  **tại sao** sai, so sánh nhiều cách làm.
- ❌ **Không viết hộ lời giải hoàn chỉnh khi người dùng chưa có bản nháp.**
- Nếu người dùng yêu cầu thẳng lời giải: đưa ra, nhưng **bắt buộc** kèm mục cuối
  `## Bạn cần tự làm lại phần nào` — chỉ rõ phần nào phải tự tay làm lại để thật sự hiểu.

**Khi tạo bài tập mới** `assignments/aN/`:
- Tạo đủ: `README.md`, `brief/`, `resources/`, `images/`
- `README.md` phải có: tóm tắt yêu cầu · checklist việc cần làm · hạn nộp (ngày tuyệt đối) · trạng thái
- **Ghi hạn nộp vào `admin/deadlines.md` ngay lúc tạo thư mục**, không để sau.

**Khi tạo đồ án mới** `projects/prjN/`:
- Tạo đủ: `README.md`, `brief/`, `docs/`, `src/`, `images/`

**Ảnh thực hành:** đặt trong `images/` của chính bài đó, **tên tiếng Anh mô tả nội dung**:
`step3-ping-result.png` ✅ — `Screenshot 2026-09-18 at 14.02.11.png` ❌

---

## § 7. Thư mục `research/`

Dùng cho chủ đề người dùng tự đào sâu, **ngoài phạm vi bài giảng**.

- Mỗi file mở đầu bằng: **Câu hỏi nghiên cứu** → **Kết luận ngắn** → phần phân tích chi tiết.
  (Kết luận đặt lên đầu để đọc lại sau 6 tháng không phải đọc hết.)
- **Bắt buộc có mục `## Nguồn`** với link cụ thể. Không có nguồn → ghi rõ đó là suy luận.
- Kết quả dùng được cho môn khác → tách phần cốt lõi ra `knowledge-base/`,
  file research giữ lại link tới đó.

---

## § 8. `IMPORTANT_NOTES.md` — một file mỗi môn

Nơi dồn **mọi thứ giảng viên nói mà ảnh hưởng tới điểm số**. Khác `README.md` của môn
(thông tin tĩnh) — file này **lớn dần theo học kỳ**.

**Luật:**
- **Mọi mục phải có nguồn**: buổi học nào, ngày nào, giảng viên nói câu gì.
  **Không nguồn = không ghi.** Không được tự suy diễn "chắc phần này sẽ thi".
- **Chỉ thêm, không xoá.** Thông tin cũ sai → gạch ngang `~~…~~` kèm lý do, giữ lịch sử.
  (Giảng viên đổi ý là chuyện thường, và biết *đã từng* nói gì cũng là thông tin.)
- `exam-prep/cheatsheet.md` được sinh ra **dựa trên mục 2 và 3** của file này.

---

## § 9. `program/` — bảo trì tầng chiến lược

- **Cuối mỗi học kỳ**, chạy đủ chuỗi: cập nhật `transcript.md` → tick `curriculum.md` →
  đối chiếu lại `study-plan.md` → tính lại tiến độ trong `program/README.md`.
- **Không tự ý sửa `curriculum.md`** — đó là dữ liệu từ nhà trường.
  Thiếu thông tin → ghi `> ❓ **CẦN XÁC MINH:**` và hỏi người dùng.
  **Không bao giờ đoán số tín chỉ, môn tiên quyết, hay điều kiện tốt nghiệp.**
- **Ý tưởng đồ án** xuất hiện lúc đang học → ghi ngay vào `program/thesis/ideas/`, kèm nguồn gốc.
- **Cuối mỗi môn**: thêm một dòng cảm nhận vào `README.md` của môn — thấy thú vị không,
  làm có tốt không. Đây là dữ liệu đầu vào cho `specialization/`, và **chỉ thu được lúc còn nóng**.
- Khi người dùng hỏi về **chọn chuyên ngành**: bắt buộc đọc `specialization/criteria.md` trước,
  chấm theo tiêu chí đã đặt sẵn. **Không đưa ý kiến cảm tính.**

---

## § 10. Deadline & lịch

- `admin/deadlines.md` là **nguồn sự thật duy nhất** cho mọi ngày tháng.
  Phát hiện deadline ở bất kỳ đâu → phải chảy về đây.
- **Luôn chuyển ngày tương đối → tuyệt đối.**
  *"nộp tuần sau"* + buổi học ngày 2026-09-20 → **`2026-09-27`**.
  Không đủ thông tin để quy đổi → hỏi, không đoán.
- **Đầu mỗi phiên làm việc**: nếu có deadline trong 7 ngày tới → báo trước khi làm việc khác.

---

## § 11. Git

- **Tự động `git add` + `commit` sau mỗi phiên học, không cần hỏi.**
- Mẫu message: `<mã môn>: <việc đã làm>`
  - `IT007: note buổi 3 + 12 flashcard`
  - `IE105: bài tập 1 — đề bài và checklist`
  - `program: cập nhật tiến độ sau HK3`
- **Không tự `push`** trừ khi được yêu cầu rõ.

---

## § 12. Không bao giờ làm

- ❌ **Không bịa nội dung bài giảng** không có trong transcript.
  Thiếu thông tin → ghi `> ❓ **CẦN XÁC MINH:**`.
- ❌ Không xoá hoặc sửa file trong `lectures/_raw/` và `brief/` — đó là bản gốc.
- ❌ **Không đổi tên file nộp cho giảng viên**, không bỏ dấu tiếng Việt của nó (xem § 13.3).
- ❌ Không đặt tên đường dẫn bằng tiếng Việt (trừ file nộp).
- ❌ Không tự bịa số tín chỉ, môn tiên quyết, quy định tốt nghiệp.
- ❌ Không "làm tròn" điểm hay deadline.
- ❌ Không ghi vào `IMPORTANT_NOTES.md` thứ không có nguồn.

---

## § 13. Quy ước đặt tên

### 13.1. Tên đường dẫn — **luôn tiếng Anh, không dấu**
| Loại | Quy ước | Ví dụ |
|---|---|---|
| Thư mục | `kebab-case` | `exam-prep/`, `knowledge-base/` |
| File markdown thường | `kebab-case.md` | `process-scheduling.md` |
| File quy ước đặc biệt | `UPPER_SNAKE.md` | `README.md`, `IMPORTANT_NOTES.md`, `AGENTS.md` |
| Thư mục môn | `<MÃ MÔN>-<tên tiếng Anh>` | `IT007-operating-systems` |

Tên tiếng Việt đầy đủ của môn ghi trong `README.md` của môn, **không nằm ở đường dẫn**.

### 13.2. Nội dung bên trong file — **tiếng Việt có dấu**
Thuật ngữ kỹ thuật giữ nguyên tiếng Anh (§ 2).

### 13.3. File nộp cho giảng viên — **ngoại lệ duy nhất**
```
[tên assignment]-NguyễnQuốcTrung-25730081.<đuôi>
```
- `BT01-NguyễnQuốcTrung-25730081.pdf`
- `PRJ1-NguyễnQuốcTrung-25730081.zip`

> ⚠️ File nộp **giữ nguyên dấu tiếng Việt** vì nó đi tới giảng viên, phải đúng định dạng
> trường yêu cầu. AI **không bao giờ** được "sửa cho sạch" hay bỏ dấu tên file này.

### 13.4. Đánh số
- Buổi học: `L01`, `L02`… · Bài tập: `a1`, `a2`… · Đồ án: `prj1`, `prj2`…
- Ngày: `YYYY-MM-DD`, **luôn tuyệt đối**
- Học kỳ: `2025-2026-S3` (S = Semester)
- Tiền tố file nộp (`BT`, `LAB`, `PRJ`) bám theo cách **giảng viên đánh số** trong từng môn,
  nên thư mục `a1` có thể chứa file `LAB01-...pdf`. Đây là chủ ý, không phải lỗi.

---

## § 14. Bản đồ repo — bỏ file vào đâu

Bốn tầng thời gian. Phân vân thì hỏi: *"cái này còn đúng sau bao lâu?"*

| Tầng | Thư mục | Tầm nhìn | Trả lời câu hỏi |
|---|---|---|---|
| Chiến lược | `program/` | 4 năm | *Tôi đang đi đâu? Ra trường thế nào?* |
| Chiến thuật | `semesters/` | 1 học kỳ | *Học kỳ này học gì, làm gì?* |
| Vận hành | `admin/` | 1 tuần | *Tuần này nộp gì, mấy giờ vào Teams?* |
| Tích luỹ | `knowledge-base/` | vĩnh viễn | *Khái niệm này là gì?* |

Trong một môn học:

| Thư mục | Dùng khi | Có nộp không |
|---|---|---|
| `lectures/` | Note theo từng buổi học | Không |
| `notes/` | Note theo khái niệm, gom từ nhiều buổi | Không |
| `code/` | Thử nhanh, chạy lại ví dụ bài giảng | Không |
| `assignments/aN/` | Bài tập giảng viên giao, có hạn nộp | **Có** |
| `projects/prjN/` | Đồ án môn học, nhiều buổi, nhiều file | **Có** |
| `research/` | Tự tò mò, đào sâu ngoài syllabus | Không |
| `exam-prep/` | Flashcard, cheatsheet, ôn thi | Không |
