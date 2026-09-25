# AGENTS.md — Sổ tay vận hành cho AI

> File này là **luật** cho AI. Đọc trước khi làm bất cứ việc gì trong repo này.
> Hướng dẫn thao tác cho người dùng nằm ở [`HOW-TO.md`](HOW-TO.md) — khi người dùng
> hỏi *"làm thế nào để…"*, trả lời rồi trỏ họ tới mục tương ứng ở đó.
> Cập nhật lần cuối: 2026-09-25

---

## Mục lục

- [§ 1. Người dùng là ai](#-1-người-dùng-là-ai)
- [§ 2. Luật ngôn ngữ](#-2-luật-ngôn-ngữ)
- [§ 2b. Mục lục trong file markdown](#-2b-mục-lục-trong-file-markdown)
- [§ 3. Cách giải thích — thứ tự 5 bước bắt buộc](#-3-cách-giải-thích--thứ-tự-5-bước-bắt-buộc)
- [§ 4. Học chủ động (active recall)](#-4-học-chủ-động-active-recall)
- [§ 5. Quy trình xử lý bài giảng (transcript Teams → note)](#-5-quy-trình-xử-lý-bài-giảng-transcript-teams--note)
- [§ 6. Assignment & project](#-6-assignment--project)
- [§ 7. Thư mục `research/`](#-7-thư-mục-research)
- [§ 8. `IMPORTANT_NOTES.md` — một file mỗi môn](#-8-important_notesmd--một-file-mỗi-môn)
- [§ 8b. `materials/` — tài liệu giảng viên cung cấp](#-8b-materials--tài-liệu-giảng-viên-cung-cấp)
- [§ 8c. Script và skill của repo](#-8c-script-và-skill-của-repo)
- [§ 9. `program/` — bảo trì tầng chiến lược](#-9-program--bảo-trì-tầng-chiến-lược)
- [§ 10. Deadline & lịch](#-10-deadline--lịch)
- [§ 11. Git](#-11-git)
- [§ 12. Không bao giờ làm](#-12-không-bao-giờ-làm)
- [§ 13. Quy ước đặt tên](#-13-quy-ước-đặt-tên)
- [§ 14. Bản đồ repo — bỏ file vào đâu](#-14-bản-đồ-repo--bỏ-file-vào-đâu)

---

## § 1. Người dùng là ai

| | |
|---|---|
| Họ tên | **Nguyễn Quốc Trung** |
| MSSV | **25730081** |
| Trường | Đại học Công nghệ Thông tin (UIT) |
| Ngành | Công nghệ Thông tin — hệ **đào tạo từ xa** |
| Học kỳ hiện tại | **HK3 2025–2026** → `semesters/2025-2026-S3/` |
| Học kỳ tiếp theo | **HK1 2026–2027** → `semesters/2026-2027-S1/` · 4 môn, 14 TC · SS008 đã đăng ký chuyển điểm, kết quả ❓ |
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

## § 2b. Mục lục trong file markdown

**File markdown từ 5 mục `##` trở lên, hoặc dài hơn 100 dòng, BẮT BUỘC có mục lục.**
Người dùng cần nhìn lướt là thấy ngay file có những gì.

### Khi nào cần

| Trường hợp | Có mục lục? |
|---|---|
| ≥ 5 mục `##`, hoặc > 100 dòng | ✅ **Bắt buộc** |
| 3–4 mục, file ngắn | Tuỳ, nghiêng về có nếu file sẽ dài thêm |
| < 3 mục, hoặc file dưới 40 dòng | ❌ Không — mục lục dài hơn nội dung là phản tác dụng |
| `flashcards.md`, `cheatsheet.md`, `.gitkeep` | ❌ Không |

`IMPORTANT_NOTES.md` **luôn có** dù ban đầu ngắn — nó lớn dần suốt học kỳ.

### Đặt ở đâu

Ngay sau tiêu đề `#` và bảng thông tin đầu file, **trước** mục nội dung đầu tiên.
Ngăn cách trên dưới bằng `---`.

### Viết thế nào

```markdown
## Mục lục

- [Tên mục](#anchor)
  - [Mục con](#anchor-con)
```

Dùng danh sách gạch đầu dòng, thụt lề hai khoảng cho `###`. Chỉ lấy `##` và `###`,
không lấy `####` trở xuống — sâu quá thì mục lục thành rừng.

### Anchor sinh thế nào

GitHub tạo anchor theo đúng luật này:

1. Chuyển hết sang chữ thường
2. Bỏ mọi ký tự **không phải** chữ, số, gạch nối, gạch dưới, khoảng trắng
3. Khoảng trắng → gạch nối

**Dấu tiếng Việt được giữ nguyên.** Trùng anchor thì thêm `-1`, `-2`.

| Tiêu đề | Anchor |
|---|---|
| `## 1. Cách tính điểm` | `#1-cách-tính-điểm` |
| `## Gợi ý thi` | `#gợi-ý-thi` |
| `## § 5. Quy trình xử lý` | `#-5-quy-trình-xử-lý` ← `§` bị bỏ, còn lại gạch nối đầu |

> ⚠️ **Đừng tự viết anchor bằng tay rồi đoán.** Ký tự như `§`, `→`, `⚠️`, dấu ngoặc
> đều bị bỏ và dễ tính nhầm. Dùng công cụ:
>
> ```bash
> scripts/toc.py gen <file>      # in ra mục lục để dán vào
> scripts/toc.py check <file>    # kiểm tra link có trỏ đúng heading không
> ```

### Giữ cho khớp

**Thêm, xoá, hay đổi tên một mục `##` thì phải cập nhật mục lục ngay trong cùng lần sửa.**
Mục lục lệch với nội dung còn tệ hơn không có mục lục — nó khiến người đọc tin vào
thứ không tồn tại. Sửa xong chạy `scripts/toc.py check <file>` để chắc.

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

> **Ngoại lệ — note bài giảng** (`lectures/L<nn>-*.md`): dùng thứ tự **Lý thuyết học thuật (có gốc rễ first
> principles) → Giải thích dễ hiểu → Code → Bài tập**, xem skill `new-lecture` Bước 5. Thứ tự 5 bước ở trên
> vẫn áp dụng khi giải thích trong chat và trong phiên `study-tutor`.

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

0. **Trước tiên, xem `materials/` có gì.** Nếu buổi này có slide (`materials/slides/L<nn>-*.pdf`),
   đọc slide **song song** với transcript — slide cho cấu trúc và thuật ngữ chính xác,
   transcript cho phần giảng viên nói thêm ngoài slide. Hai nguồn bù cho nhau:
   transcript Teams hay sai chính tả thuật ngữ, slide thì thiếu phần giải thích miệng.
1. Lưu đầu vào thô vào `lectures/_raw/L<nn>-<YYYY-MM-DD>-<nguồn>.md`.
   **Không bao giờ sửa bản thô.** Đây là bằng chứng gốc.
2. Dùng skill **`lecture-analyzer`** khi có transcript.
3. Sinh `lectures/L<nn>-<topic-tiếng-anh>.md` theo `templates/lecture-note.md`.
   Trong note, **link tới slide tương ứng** ở `materials/slides/` nếu có.
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
- **Hỏi "bài này làm thế nào"** → dùng skill `assignment-guide`, sinh `aN/GUIDE.md` dạy
  **phương pháp và tiêu chí chấm**, không đưa kết quả. Phép thử: *đọc xong guide,
  người dùng còn phải tự làm gì không?* Không còn → đã làm hộ bài.

**Khi tạo mục nộp mới** trong `assignments/`:
- Chọn tiền tố theo **loại việc giảng viên giao**: bài tập là `aN/`; bài thực hành
  (lab) là `labN/`. Loại khác chỉ dùng tiền tố riêng khi giảng viên thực sự gọi như vậy
  (§ 13.4); không ép lab thành `aN/` chỉ để đồng nhất hình thức.
- Tạo đủ: `README.md`, `brief/`, `resources/`, `images/`
- `README.md` phải có: tóm tắt yêu cầu · checklist việc cần làm · hạn nộp (ngày tuyệt đối) · trạng thái
- **Ghi hạn nộp vào `admin/deadlines.md` ngay lúc tạo thư mục**, không để sau.
- **Dùng skill `new-assignment`**, đừng tự `mkdir`. Với bài tập dùng tiền tố mặc định
  `a`; với lab chạy `--prefix lab`. Script chỉ copy sẵn
  `templates/ASSIGNMENT_TEMPLATE.docx` thành file nộp với **mẫu tên suy ra từ bài đã nộp
  trước đó cùng loại của chính môn đó** — không hardcode, vì mẫu tên do giảng viên quy định (§ 13.3).
  Chưa có mẫu cùng loại thì không copy file và để `❓ chưa xác nhận`.
  **Không điền sẵn tên và MSSV vào trang bìa** — repo đang public.

**Khi người dùng hỏi soạn báo cáo bài tập** → chỉ họ tới `templates/ASSIGNMENT_TEMPLATE.docx`,
đừng dựng lại trang bìa từ đầu.

**Khi tạo đồ án mới** `projects/prjN/`:
- Tạo đủ: `README.md`, `brief/`, `docs/`, `src/`, `images/`
- **Dùng skill `new-project`**, đừng tự `mkdir`. Hạn nộp cuối và mọi mốc giảng viên đặt
  vào `admin/deadlines.md`; mốc nhóm tự đặt chỉ nằm trong README đồ án và Notion.
- Repo public → chỉ ghi **tên** đồng đội, không ghi MSSV/email/SĐT của người khác.

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

## § 8b. `materials/` — tài liệu giảng viên cung cấp

**Đây là thư mục ĐẦU VÀO, chỉ đọc.** Cùng tính chất với `lectures/_raw/` và `brief/`.

- ❌ **Không sửa, đổi tên, hay xoá** file trong `materials/`. Đó là bản gốc của giảng viên.
- Muốn ghi chú về một tài liệu → viết file mới ở `notes/`, trích dẫn tên file gốc.
- Cấu trúc: `syllabus/` · `slides/` · `books/` · `references/`
- Slide gắn với buổi học → tiền tố `L<nn>` cho khớp note:
  `slides/L03-cpu-scheduling.pdf` ↔ `lectures/L03-cpu-scheduling.md`

**Khi có file mới trong `syllabus/` — xử lý ngay, không đợi hỏi:**

Đề cương môn học thường chứa sẵn **cách tính điểm**, **nội dung từng buổi**, **quy định môn học**
— tức là phần lớn mục 1, 4, 5 của `IMPORTANT_NOTES.md`. Đọc và điền vào,
**ghi nguồn là tên file đề cương** chứ không phải buổi học.

**Khi có ebook trong `books/`:** dùng làm nguồn cho định nghĩa hình thức (bước 4 của § 3)
và ghi rõ số trang khi trích. Giáo trình chuẩn hơn transcript Teams.

---

## § 8c. Script và skill của repo

| Việc | Dùng cái này |
|---|---|
| Thêm môn học mới | skill **`new-course`** → `.claude/skills/new-course/SKILL.md` |
| Xử lý một buổi học | skill **`new-lecture`** → `.claude/skills/new-lecture/SKILL.md` |
| Khám phá toàn bộ slide và lập knowledge map | skill **`slide-knowledge-map`** → `.claude/skills/slide-knowledge-map/SKILL.md` |
| Map đề thi mẫu → chương/mục + exam blueprint | skill **`exam-map`** → `.claude/skills/exam-map/SKILL.md` |
| Chắt lọc kiến thức một chương từ đề mẫu và hướng dẫn từng câu | skill **`exam-study-guide`** → `.claude/skills/exam-study-guide/SKILL.md` |
| Học cùng gia sư về một lecture/chủ đề | skill **`study-tutor`** → `.claude/skills/study-tutor/SKILL.md` |
| Thêm ảnh có sẵn vào đúng mục của ghi chú | skill **`add-note-image`** → `.claude/skills/add-note-image/SKILL.md` |
| Tạo bài tập hoặc lab mới | skill **`new-assignment`** → `.claude/skills/new-assignment/SKILL.md` |
| Tạo đồ án môn học mới | skill **`new-project`** → `.claude/skills/new-project/SKILL.md` |
| Hướng dẫn cách làm bài tập | skill **`assignment-guide`** → `.claude/skills/assignment-guide/SKILL.md` |
| Dọn file thả tay vào repo | skill **`tidy-files`** → `.claude/skills/tidy-files/SKILL.md` |
| Đồng bộ task University lên Notion | skill **`notion-tasks`** → `.claude/skills/notion-tasks/SKILL.md` |
| Lập kế hoạch ôn thi → task Notion + Google Calendar | skill **`exam-plan`** → `.claude/skills/exam-plan/SKILL.md` |
| Sinh / kiểm tra mục lục | `scripts/toc.py gen\|check <file>` (xem § 2b) |
| Tìm file sai chỗ / sai tên | `scripts/check-layout.sh [--course <mã>]` |
| Xem nhanh nội dung .docx/.vtt | `scripts/peek.py <file>` |

**Cầu nối Claude ↔ Codex:** `.claude/skills/` là nguồn sự thật; `.agents/skills/`
là symlink Git-tracked để Codex tự discover đúng các skill ấy. Khi tạo skill mới,
**chỉ** tạo tại `.claude/skills/<skill-name>/SKILL.md`, rồi xác nhận
`test -f .agents/skills/<skill-name>/SKILL.md`, rồi thêm một dòng vào bảng
*Tra nhanh* của [`SKILLS.md`](SKILLS.md) — danh mục skill cho người dùng. Không copy hai bản. Codex đang mở
phiên cũ cần bắt đầu phiên mới từ root repo để thấy skill vừa thêm.

Hàm dùng chung của các script nằm ở `scripts/lib/common.sh`.

Khi có nhiều học kỳ, **truyền rõ `--semester <kỳ>`** cho các script tạo môn/buổi học/bài tập/đồ án.
Script mặc định chọn thư mục học kỳ mới nhất; HK1 2026–2027 đã có khung nhưng vẫn là kỳ sắp học.
Xử lý môn đang học ở HK3 thì dùng `--semester 2025-2026-S3`.

**Người dùng thả file thủ công vào repo** (transcript, slide, bài tập đã làm) →
dùng skill **`tidy-files`**, đừng tự `mv` theo cảm tính. Luật quan trọng nhất của nó:
**tên file mang thông tin thì không được chuẩn hoá mất đi** — file nộp giữ mẫu giảng viên
yêu cầu, slide giữ số chương của giảng viên.

**Không tự tay `mkdir` để tạo môn học.** Dùng skill — nó chạy
`scripts/new-course.sh` tạo khung, rồi nối môn mới vào **6 file** khác đang giữ
danh sách môn (`semesters/<kỳ>/README.md`, `admin/schedule.md`, `admin/deadlines.md`,
`program/curriculum.md`, `program/transcript.md`, `program/specialization/README.md`).
Tạo tay thì sẽ quên bước nối, và repo mất đồng bộ.

Script render file từ `templates/` bằng token `{{CODE}}`, `{{NAME_VI}}`, `{{LECTURER}}`…
**Sửa template thì môn tạo sau sẽ đổi theo** — đó là chủ ý, một nguồn sự thật duy nhất.
Chín template có token: `course-readme` · `important-notes` · `materials-readme` ·
`flashcards` · `cheatsheet` · `lecture-note` · `lecture-raw` · `assignment` · `project`.
Năm template còn lại là để AI điền tay, không có token.

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
- **Notion (☕ Tasks) là tầng thực thi, không phải nguồn sự thật.** Repo quyết định *có việc gì,
  hạn khi nào*; Notion quyết định *đã xong chưa*. Đồng bộ bằng skill **`notion-tasks`** —
  luôn xem trước rồi mới ghi. Ánh xạ repo ↔ Notion nằm ở `admin/notion-map.json`
  (**gitignore** — chứa URL workspace riêng, không chép sang file tracked).
- **Nhắc lịch Google Calendar → luôn dùng lịch `Work`**, không dùng lịch chính.
- **Mọi task Notion theo template `☕ Task`**: Mô tả · Kết quả đầu ra (bảng câu hỏi → trả lời,
  Done khi đủ trả lời) · Các bước · Phụ thuộc · Nhật ký. Chi tiết ở skill `notion-tasks`.

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
- ❌ Không xoá hoặc sửa file trong `lectures/_raw/`, `brief/`, và `materials/` — đó là bản gốc.
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
| File quy ước đặc biệt | chữ HOA | `README.md`, `IMPORTANT_NOTES.md`, `AGENTS.md`, `HOW-TO.md`, `SKILLS.md`, `ASSIGNMENT_TEMPLATE.docx` |
| Thư mục môn | `<MÃ MÔN>-<tên tiếng Anh>` | `IT007-operating-systems` |

Tên tiếng Việt đầy đủ của môn ghi trong `README.md` của môn, **không nằm ở đường dẫn**.

### 13.2. Nội dung bên trong file — **tiếng Việt có dấu**
Thuật ngữ kỹ thuật giữ nguyên tiếng Anh (§ 2).

### 13.3. File nộp cho giảng viên — **ngoại lệ duy nhất**

> ⚠️ **Luật số một: mẫu tên do GIẢNG VIÊN quy định, không phải repo.**
> Mỗi môn mỗi khác. Thầy dặn sao thì đặt vậy — **không "chuẩn hoá" cho khớp repo**.
> Nộp sai mẫu tên là chuyện có thật bị trừ điểm.

**Mẫu đã xác nhận theo từng môn:**

| Môn | Mẫu tên file | Định dạng | Nguồn |
|---|---|---|---|
| **IE105** | `Bài tập <N>_Họ tên_MSSV` | **Word (.docx)**, PDF chỉ đính kèm thêm | buổi 1/2/5 |
| IE101 · IE103 · IT007 | ❓ chưa biết | ❓ | — |

Ví dụ thật của IE105: `Bài tập 3A_Nguyễn Quốc Trung_25730081.docx`

> *IE105, buổi 1, 2026-07-08 — "mấy em đặt tên file á là Bài tập 1 gạch cái họ tên mã số sinh viên"*
> *IE105, buổi 5, 2026-08-12 — "Đặt tên file là bài tập 3A, họ tên mã số sinh viên"*
> *IE105, buổi 1 — nộp **file gốc** (Word) vì thầy xem được quá trình làm bài;
> nộp PDF thì "giống như nộp cái ảnh"*

**Mẫu mặc định** khi môn chưa có chỉ dẫn nào của giảng viên:
```
[tên assignment]-NguyễnQuốcTrung-25730081.<đuôi>
```

> ⚠️ File nộp **giữ nguyên dấu tiếng Việt** vì nó đi tới giảng viên. AI **không bao giờ**
> được "sửa cho sạch", bỏ dấu, hay đổi mẫu tên file này.
> Nghe thấy giảng viên dặn cách đặt tên → ghi ngay vào bảng trên **và** vào
> `IMPORTANT_NOTES.md` mục 4 của môn đó.

### 13.4. Đánh số
- Buổi học: `L01`, `L02`… · Đồ án: `prj1`, `prj2`…
- **Tên thư mục mục nộp = tiền tố loại việc + số giảng viên đặt**, không đánh lại tuần tự:

  | Loại | Quy ước | Ví dụ |
  |---|---|---|
  | Bài tập | `a<number><part?>/` | Bài tập 3A → `a3a/` · Bài tập 4 → `a4/` |
  | Bài thực hành / lab | `lab<number><part?>/` | Bài thực hành 3 → `lab3/` · Lab 2B → `lab2b/` |
  | Đồ án | `prj<number>/` | Đồ án 1 → `prj1/` |
  | Loại có tiền tố riêng do giảng viên đặt | `<prefix><number><part?>/` | Quiz 2 → `quiz2/` |

  Tiền tố luôn là tiếng Anh, chữ thường, `kebab-case` nếu có nhiều từ; chỉ thêm tiền tố
  mới khi có nguồn từ giảng viên. Lý do: số bài có thể nhảy cóc, có phần A/B, hoặc xen lab;
  đánh tuần tự sẽ xáo lại toàn bộ khi bổ sung mục còn thiếu.
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
| `materials/` | **Tài liệu giảng viên cung cấp** — slide, đề cương, ebook. Chỉ đọc | Không |
| `lectures/` | Note theo từng buổi học | Không |
| `notes/` | Note theo khái niệm, gom từ nhiều buổi | Không |
| `code/` | Thử nhanh, chạy lại ví dụ bài giảng | Không |
| `assignments/aN/` · `assignments/labN/` | Bài tập hoặc lab giảng viên giao, có hạn nộp | **Có** |
| `projects/prjN/` | Đồ án môn học, nhiều buổi, nhiều file | **Có** |
| `research/` | Tự tò mò, đào sâu ngoài syllabus | Không |
| `exam-prep/` | Flashcard, cheatsheet, ôn thi | Không |

**Tài liệu thì bỏ vào đâu** — phân biệt theo *phạm vi*, không theo loại file:

| Phạm vi | Thư mục |
|---|---|
| Cả môn, giảng viên cung cấp | `materials/` |
| Chỉ một bài tập — đề bài | `assignments/aN/brief/` |
| Chỉ một bài tập — tài liệu phụ | `assignments/aN/resources/` |
| Chỉ một đồ án — đề bài | `projects/prjN/brief/` |
| Tôi tự tìm được khi đào sâu | `research/` (ghi link ở mục `## Nguồn`) |
