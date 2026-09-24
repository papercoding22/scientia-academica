# HOW-TO — Hướng dẫn sử dụng repo

Sổ tay thao tác hàng ngày. Đọc một lần, sau đó chỉ cần tra mục nào cần.

---

## Ba file gốc, đừng nhầm

| File | Dành cho ai | Trả lời câu hỏi |
|---|---|---|
| [`README.md`](README.md) | Người đọc lần đầu | *Repo này là gì? Có gì trong đây?* |
| **`HOW-TO.md`** (file này) | **Bạn, hàng ngày** | ***Muốn làm X thì thao tác thế nào?*** |
| [`AGENTS.md`](AGENTS.md) | AI | *Luật phải tuân theo khi làm việc trong repo* |
| [`SKILLS.md`](SKILLS.md) | Bạn, khi quên tên skill | *Có skill nào, gọi thế nào?* |

Bạn hầu như chỉ cần file này. `AGENTS.md` là để AI đọc — nhưng nếu thấy AI làm gì đó
không vừa ý, sửa `AGENTS.md` là cách thay đổi hành vi của nó vĩnh viễn.

---

## Mục lục

1. [Vòng đời một buổi học](#1-vòng-đời-một-buổi-học)
2. [Nhận tài liệu từ giảng viên](#2-nhận-tài-liệu-từ-giảng-viên)
3. [Lấy transcript từ Teams](#3-lấy-transcript-từ-teams)
4. [Xử lý buổi học thành note](#4-xử-lý-buổi-học-thành-note)
5. [Làm bài tập](#5-làm-bài-tập)
6. [Làm đồ án](#6-làm-đồ-án)
7. [Tự đào sâu một chủ đề](#7-tự-đào-sâu-một-chủ-đề)
8. [Ôn thi](#8-ôn-thi)
9. [Import flashcard vào Anki](#9-import-flashcard-vào-anki)
10. [Cuối học kỳ](#10-cuối-học-kỳ)
11. [Thêm môn học mới](#11-thêm-môn-học-mới)
12. [**Ví dụ: một thư mục môn học sau 6 tuần**](#12-ví-dụ-một-thư-mục-môn-học-sau-6-tuần)
13. [Câu lệnh hay dùng](#13-câu-lệnh-hay-dùng)
14. [Bỏ file vào đâu — tra nhanh](#14-bỏ-file-vào-đâu--tra-nhanh)
15. [Hay gặp](#15-hay-gặp)

---

## 1. Vòng đời một buổi học

```
Giảng viên gửi slide          →  materials/slides/L03-*.pdf
        ↓
Học trên Teams                →  materials/, đã có sẵn slide để mở kèm
        ↓
Copy transcript sau buổi       →  lectures/_raw/L03-2026-10-06-transcript.md
        ↓
Bảo AI "xử lý buổi 3 IT007"   →  lectures/L03-cpu-scheduling.md
        ↓                          + IMPORTANT_NOTES.md  (gợi ý thi)
        ↓                          + admin/deadlines.md  (deadline mới)
        ↓                          + exam-prep/flashcards.*
        ↓
AI tự commit
```

Bạn chỉ làm **2 việc thủ công**: bỏ slide vào `materials/`, dán transcript vào `_raw/`.
Phần còn lại nói một câu là xong.

---

## 2. Nhận tài liệu từ giảng viên

Bỏ file vào `materials/` của môn đó, chọn đúng thư mục con:

| Nhận được gì | Bỏ vào |
|---|---|
| Đề cương môn học | `materials/syllabus/` |
| Slide bài giảng | `materials/slides/` — đặt tên `L03-ten-chu-de.pdf` |
| Giáo trình, ebook | `materials/books/` |
| Bài báo, chuẩn, tài liệu lẻ | `materials/references/` |

> ⚠️ **Đề cương là việc ưu tiên số một khi bắt đầu môn mới.**
> Nó thường in sẵn cách tính điểm, nội dung từng buổi, quy định nộp trễ.
> Bỏ vào rồi nói ngay:
>
> ```
> đọc đề cương IT007 và điền IMPORTANT_NOTES
> ```
>
> Làm việc này trước buổi học đầu tiên là bạn đã biết cả học kỳ sẽ bị chấm điểm thế nào.

**Không đổi tên file gốc** nếu tên đó mang thông tin (mã tài liệu, số hiệu chuẩn).
AI cũng bị cấm sửa file trong `materials/` — đó là bản gốc.

---

## 3. Lấy transcript từ Teams

Teams tự sinh transcript cho buổi học có bật ghi hình. Cách lấy nói chung:

1. Mở bản ghi của buổi học (trong chat của lớp, hoặc Stream / OneDrive).
2. Tìm mục **Transcript** trong bản ghi.
3. Tải về — thường có `.vtt` hoặc `.docx`.
4. Tạo file `_raw` bằng script — nó tự tìm số buổi tiếp theo và đặt tên đúng quy ước:

```bash
# Có file .vtt: script tự chuyển sang markdown, gộp câu theo người nói
scripts/new-lecture.sh --course IE105 --from ~/Downloads/meeting.vtt --date 2026-10-06

# Chưa có gì: tạo chỗ trống để dán tay
scripts/new-lecture.sh --course IE105
```

Không muốn dùng script thì tự tạo `lectures/_raw/L<nn>-<YYYY-MM-DD>-transcript.md`
rồi dán nội dung vào — kết quả như nhau.

> Giao diện Teams thay đổi theo bản cập nhật, nên các bước trên là mô tả chung.
> Nếu lớp **không bật ghi hình**, dùng chính note bạn gõ trong lúc học —
> lưu vào cùng chỗ, đặt tên `L<nn>-<ngày>-notes.md`. AI vẫn xử lý được.

**Nên lấy bản `.vtt`** nếu có: nó kèm timestamp, nên khi AI đánh dấu gợi ý thi
thì có thể trỏ về đúng phút giảng viên nói câu đó.

**Không cần dọn dẹp transcript trước.** Transcript Teams tiếng Việt lẫn thuật ngữ
tiếng Anh thường sai chính tả nhiều — đó là lý do AI được yêu cầu đọc slide song song
để bù lại. Cứ dán thô vào.

---

## 4. Xử lý buổi học thành note

```
xử lý buổi 3 môn IT007
```

AI sẽ:
1. Đọc `lectures/_raw/L03-*.md` **và** `materials/slides/L03-*.pdf` cùng lúc
2. Sinh `lectures/L03-<chu-de>.md` — giải thích theo 5 bước: trực giác → analogy →
   ví dụ nhỏ → định nghĩa hình thức → code
3. Thêm mục **Tự kiểm tra** với 5 câu hỏi, đáp án gập lại
4. Quét câu kiểu *"cái này sẽ thi"* → ghi vào `IMPORTANT_NOTES.md` kèm nguồn
5. Quét deadline → ghi vào `admin/deadlines.md` với ngày tuyệt đối
6. Sinh flashcard vào `exam-prep/flashcards.md` + `.csv`
7. Commit

**Muốn kỹ hơn** thì nói rõ: `xử lý buổi 3 IT007, phần deadlock giải thích kỹ giúp tôi`

---

## 5. Làm bài tập

**Khi nhận đề:**
```
/new-assignment IE105 8
```
AI tạo `assignments/a8/` với `README.md`, `brief/`, `resources/`, `images/`,
**copy sẵn file nộp `.docx` đúng mẫu tên giảng viên yêu cầu**, tìm đề bài trong
transcript buổi học, và ghi hạn nộp vào `admin/deadlines.md`.

Bỏ file đề bài của giảng viên vào `assignments/a8/brief/`.

**Khi bắt đầu viết báo cáo:** file `.docx` đã nằm sẵn trong `aN/`, mở bằng Word là viết được.
Tự tạo bài tập không qua skill thì copy tay:

```bash
scripts/new-assignment.sh --course IE105 --num 8 --due 2026-09-25 --dry-run
```

Điền trang bìa: `MÃ MÔN` · `MÔN HỌC` · `GVHD` · `Sinh viên thực hiện` · `MSSV` · `Lớp`
— lấy từ `README.md` của môn. **Nộp file gốc `.docx`, không phải PDF.**

**Chưa biết bắt đầu từ đâu:** `/assignment-guide IE105 5` sinh `aN/GUIDE.md` — từng câu có:
đề hỏi gì · đầu ra phải nộp · công cụ · các bước · thế nào là đủ · bẫy hay mắc.
**Guide dạy cách làm, không chứa lời giải** — phần phải tự quyết liệt kê thẳng ở cuối file.

**Khi làm:**
- Viết hướng tiếp cận của mình vào mục *"Hướng tiếp cận"* trong `a1/README.md` **trước khi hỏi AI**.
  Đây không phải thủ tục — AI được cấu hình để **không viết hộ lời giải khi bạn chưa có bản nháp**.
- Ảnh chụp màn hình → `a1/images/`, đặt tên tiếng Anh mô tả: `step3-ping-result.png`

**Khi nộp:** đặt tên file đúng quy ước, **giữ nguyên dấu tiếng Việt**:
```
BT01-NguyễnQuốcTrung-25730081.pdf
```
Tiền tố (`BT`, `LAB`, `PRJ`) theo cách giảng viên môn đó đánh số.

**Sau khi có điểm:** điền vào mục *"Sau khi có điểm"* — sai ở đâu, vì sao.
Đây là thứ dùng lại được lúc ôn thi.

---

## 6. Làm đồ án

```
/new-project IE101 1
thầy giao đồ án nhóm môn IE101, hạn 2026-11-15
```

Tạo `projects/prj1/` với `src/`, `docs/`, `brief/`, `images/`. AI quét transcript để điền
**đề bài, tiêu chí chấm, các mốc** (kèm nguồn), ghi hạn nộp và mốc của giảng viên vào
`admin/deadlines.md`, rồi đề xuất task Notion cho từng mốc.
Code vào `src/`, báo cáo và slide thuyết trình vào `docs/`.

Bản nộp: theo mẫu giảng viên dặn — chưa dặn thì README để `❓`, **AI không đoán tên file**.
Repo public: chỉ ghi tên đồng đội, không ghi MSSV của họ.

---

## 7. Tự đào sâu một chủ đề

Tò mò thứ gì ngoài bài giảng:
```
nghiên cứu giúp tôi vì sao Linux bỏ O(1) scheduler chuyển sang CFS, lưu vào research của IT007
```

File sẽ có: **Câu hỏi nghiên cứu** → **Kết luận ngắn** → phân tích → **Nguồn**.
Kết luận đặt lên đầu để sáu tháng sau đọc lại không phải đọc hết.

**Nếu kết quả dùng được cho nhiều môn** → bảo AI tách phần lõi ra `knowledge-base/`.

---

## 8. Ôn thi

```
sinh cheatsheet môn IT007
```

Cheatsheet được dựng từ **mục 2 và 3 của `IMPORTANT_NOTES.md`** — tức là từ chính
những gì giảng viên nói sẽ thi, **không phải** tóm tắt cả giáo trình. Nên nó chỉ hữu ích
khi `IMPORTANT_NOTES.md` đã có dữ liệu suốt học kỳ.

Đây là lý do đáng bỏ công điền `IMPORTANT_NOTES.md` mỗi buổi.

**Ôn bằng hỏi đáp:**
```
hỏi tôi 10 câu về chương 3 IT007, đừng đưa đáp án ngay
```

**Lên kế hoạch ôn thi** (khi đã biết ngày thi):
```
/exam-plan
lên kế hoạch ôn thi IT007 và IE105, bắt đầu từ ngày mai
```
AI đọc lịch Google Calendar (lớp học `UIT Class`, lịch `Work`) để tìm khung giờ trống, xếp buổi ôn lùi từ ngày thi
theo trọng số đề, **in bảng xem trước** rồi mới tạo task Notion và sự kiện trên lịch `Work` khi bạn gõ OK.
Trước đó nên có `exam-map` (nếu có đề mẫu) để kế hoạch bám đúng chỗ có điểm.

---

## 9. Import flashcard vào Anki

File `exam-prep/flashcards.csv` đã sẵn sàng import — có UTF-8 BOM và directive
`#separator:semicolon` nên **không vỡ dấu tiếng Việt**.

1. Anki → **File → Import**
2. Chọn file `.csv`
3. Anki tự đọc directive, không cần chỉnh separator
4. Ánh xạ cột: `Mặt trước` → Front · `Mặt sau` → Back · `Tag` → Tags

Import lại lần sau, Anki tự nhận thẻ trùng — chọn *Update existing notes*.

---

## 10. Cuối học kỳ

Chạy đủ chuỗi, nói một câu là được:
```
kết thúc học kỳ, cập nhật program
```

AI sẽ: điền điểm vào `program/transcript.md` → tick `program/curriculum.md` →
đối chiếu `program/study-plan.md` → tính lại tiến độ ở `program/README.md`.

**Đừng quên phần cảm nhận.** Cuối mỗi môn, điền mục *"Cảm nhận cá nhân"* trong
`README.md` của môn: thấy thú vị không, làm có tốt không. Nghe vặt vãnh, nhưng đây là
dữ liệu đầu vào cho việc **chọn chuyên ngành** — và sau một năm sẽ không ai nhớ nổi.

---

## 11. Thêm môn học mới

```
/new-course
```
rồi đưa: `IT008.F31.CN1.CNTT - Mạng máy tính - Trần Văn A`

Skill sẽ tạo khung thư mục **và** nối môn mới vào 6 file khác đang giữ danh sách môn
(`README` học kỳ, `schedule`, `deadlines`, `curriculum`, `transcript`, `specialization`).

Muốn tự chạy script:
```bash
scripts/new-course.sh --help
scripts/new-course.sh --code IT008 --slug computer-networks \
                      --name "Mạng máy tính" --lecturer "Trần Văn A" --dry-run
```
Chạy tay thì **nhớ nối 6 file kia** — script in danh sách ra ở cuối.

---

## 12. Ví dụ: một thư mục môn học sau 6 tuần

Đây là `IT007-operating-systems` khi đã học được 6 buổi, làm xong 1 bài tập,
đang làm đồ án. Trông sẽ như thế này:

```
semesters/2025-2026-S3/IT007-operating-systems/
│
├── README.md                       # syllabus, giảng viên, tiến độ 6 buổi, cảm nhận
├── IMPORTANT_NOTES.md              # ← file đáng giá nhất, lớn dần mỗi buổi
│
├── materials/                      # ⚠️ CHỈ ĐỌC — bản gốc của giảng viên
│   ├── README.md
│   ├── syllabus/
│   │   └── de-cuong-IT007-HK3.pdf
│   ├── slides/
│   │   ├── L01-tong-quan-he-dieu-hanh.pdf
│   │   ├── L02-process-thread.pdf
│   │   ├── L03-cpu-scheduling.pdf
│   │   ├── L04-synchronization.pdf
│   │   ├── L05-deadlock.pdf
│   │   └── L06-memory-management.pdf
│   ├── books/
│   │   └── operating-system-concepts-10e.pdf
│   └── references/
│       └── linux-cfs-design-doc.pdf
│
├── lectures/
│   ├── _raw/                       # ⚠️ CHỈ ĐỌC — bằng chứng gốc
│   │   ├── L01-2026-09-22-transcript.md
│   │   ├── L02-2026-09-29-transcript.md
│   │   ├── L03-2026-10-06-transcript.md
│   │   ├── L04-2026-10-13-transcript.md
│   │   ├── L05-2026-10-20-notes.md        # buổi này không ghi hình, note tay
│   │   └── L06-2026-10-27-transcript.md
│   │
│   ├── L01-os-overview.md          # ← đầu ra: note đã cấu trúc hoá
│   ├── L02-process-and-threads.md
│   ├── L03-cpu-scheduling.md
│   ├── L04-synchronization.md
│   ├── L05-deadlock.md
│   └── L06-memory-management.md
│
├── notes/                          # gom theo KHÁI NIỆM, không theo buổi
│   ├── scheduling-algorithms-compared.md   # gom từ L03 + đọc thêm sách
│   └── race-condition-vs-deadlock.md       # hai thứ hay bị lẫn, gom L04 + L05
│
├── assignments/
│   ├── a1/                         # ✅ đã nộp, đã có điểm
│   │   ├── README.md               # yêu cầu · checklist · hướng tiếp cận · điểm 9.0
│   │   ├── brief/
│   │   │   └── de-bai-bt01.pdf
│   │   ├── resources/
│   │   │   └── scheduling-examples.pdf
│   │   ├── images/
│   │   │   ├── step1-gantt-chart-fcfs.png
│   │   │   └── step2-gantt-chart-sjf.png
│   │   └── BT01-NguyễnQuốcTrung-25730081.pdf      # ← FILE NỘP, giữ dấu
│   │
│   └── a2/                         # 🔄 đang làm, hạn 2026-11-10
│       ├── README.md
│       ├── brief/
│       │   └── de-bai-bt02.pdf
│       ├── resources/
│       └── images/
│
├── projects/
│   └── prj1/                       # 🔄 đồ án mô phỏng scheduler, nhóm 3 người
│       ├── README.md               # mô tả · phân công · mốc thời gian
│       ├── brief/
│       │   └── de-bai-do-an.pdf
│       ├── docs/
│       │   ├── bao-cao.md
│       │   └── slide-thuyet-trinh.pptx
│       ├── src/
│       │   ├── scheduler.py
│       │   ├── process.py
│       │   └── test_scheduler.py
│       └── images/
│           └── demo-output.png
│
├── research/                       # tự tò mò, ngoài syllabus
│   └── why-linux-replaced-o1-with-cfs.md
│
├── code/                           # nghịch nhanh, không nộp
│   ├── fork-exec-demo.c
│   └── producer-consumer.py
│
└── exam-prep/
    ├── flashcards.md               # 87 thẻ, bản đọc
    ├── flashcards.csv              # 87 thẻ, import Anki
    └── cheatsheet.md               # sinh trước kỳ thi, 1 trang A4
```

### Các file nối với nhau thế nào

```
materials/slides/L03-cpu-scheduling.pdf ─┐
                                         ├──→ lectures/L03-cpu-scheduling.md
lectures/_raw/L03-2026-10-06-transcript.md ─┘         │
                                                      │ khi giảng viên nói "chương 3 sẽ thi"
                                                      ↓
                                            IMPORTANT_NOTES.md  mục 2
                                                      │
                                                      │ trước kỳ thi
                                                      ↓
                                            exam-prep/cheatsheet.md

lectures/L03 + L04 + sách  ──→  notes/scheduling-algorithms-compared.md
                                          │ nếu dùng được cho môn khác
                                          ↓
                                knowledge-base/cpu-scheduling.md

lectures/L03 (deadline mới) ──→ admin/deadlines.md ──→ assignments/a2/README.md
```

### Ba thư mục chỉ đọc

`materials/` · `lectures/_raw/` · `assignments/*/brief/` — AI bị cấm sửa, đổi tên, xoá.
Đó là bản gốc: của giảng viên, hoặc bằng chứng những gì thật sự được nói.
Muốn ghi chú thì viết file mới ở `notes/`.

---

## 13. Câu lệnh hay dùng

Copy dùng thẳng, đổi mã môn và số buổi:

**Đầu môn học**
```
đọc đề cương IT007 và điền IMPORTANT_NOTES
```

**Sau buổi học**
```
xử lý buổi 3 môn IT007
/new-lecture IT007 3
```
Có file `.vtt` trong tay thì đưa thẳng đường dẫn, AI tự nạp:
```
/new-lecture IT007, transcript ở ~/Downloads/meeting.vtt
```

**Chưa hiểu bài**
```
giải thích lại deadlock cho tôi, tôi chưa hiểu điều kiện circular wait
```

**Bài tập**
```
tạo bài tập 2 cho IT007, hạn nộp 10/11
/assignment-guide IE105 5          # hướng dẫn cách làm, KHÔNG phải lời giải
review giúp tôi code trong assignments/a2, đừng sửa hộ
```

**Ôn thi**
```
sinh cheatsheet môn IT007
hỏi tôi 10 câu về chương 3 IT007, đừng đưa đáp án ngay
tạo thêm 20 flashcard cho phần memory management
```

**Kiểm tra tình hình**
```
tuần này tôi phải nộp gì
môn nào đang bị bỏ bê nhất
```

**Notion (☕ Tasks)** — repo giữ *hạn*, Notion giữ *đã xong chưa*. AI luôn in bảng xem trước rồi mới ghi.
```
đồng bộ Notion
lập kế hoạch ôn thi ANTT trên Notion
tạo task HDH xem lại video buổi 6, hạn thứ 7
```
Kéo thẻ sang **Done** trên Notion → lần đồng bộ sau repo tự đánh dấu ✅.
Ánh xạ nằm ở `admin/notion-map.json` (gitignore — không commit).

**Cuối kỳ**
```
kết thúc học kỳ, cập nhật program
```

**Thêm môn**
```
/new-course
```

**Vừa thả file vào repo bằng tay**
```
/tidy-files
```
AI đọc nội dung từng file để biết nó là gì rồi xếp vào đúng chỗ.
**Tên file nộp cho giảng viên được giữ nguyên**, không bị chuẩn hoá.

**Tự chạy script**
```bash
scripts/new-course.sh --help
scripts/new-lecture.sh --help
scripts/new-assignment.sh --help
scripts/check-layout.sh --course IE105   # tìm file sai chỗ hoặc sai tên
scripts/peek.py <file>                   # xem nhanh nội dung .docx/.vtt
scripts/toc.py check <file>              # kiểm tra link mục lục còn đúng không
scripts/toc.py gen <file>                # sinh lại mục lục sau khi thêm mục mới
```

---

## 14. Bỏ file vào đâu — tra nhanh

| Có gì trong tay | Bỏ vào |
|---|---|
| Slide, ebook, đề cương giảng viên gửi | `materials/` |
| Transcript Teams, note gõ trong lúc học | `lectures/_raw/` |
| Đề bài của một bài tập | `assignments/aN/brief/` |
| Tài liệu chỉ phục vụ một bài tập | `assignments/aN/resources/` |
| Ảnh chụp lúc làm bài tập | `assignments/aN/images/` |
| Code thử nghiệm, chạy lại ví dụ | `code/` |
| Code của đồ án | `projects/prjN/src/` |
| Tôi tự tìm hiểu ngoài bài giảng | `research/` |
| Khái niệm nhiều môn đều dùng | `knowledge-base/` |
| Ý tưởng đồ án tốt nghiệp | `program/thesis/ideas/` |

Phân vân → hỏi *"cái này còn đúng sau bao lâu?"*
Một tuần → `admin/` · Một học kỳ → `semesters/` · Bốn năm → `program/` · Mãi mãi → `knowledge-base/`

---

## 15. Hay gặp

**AI giải thích quá hàn lâm / quá cơ bản**
→ Sửa `AGENTS.md` § 1 và § 3. Đó là chỗ định nghĩa cách nó giải thích, sửa một lần dùng mãi.

**AI viết hộ lời giải bài tập dù tôi không muốn**
→ `AGENTS.md` § 6 đã cấm. Nếu vẫn xảy ra, nhắc: *"đừng viết hộ, tôi muốn tự làm"*.
Ngược lại, cần lời giải thẳng thì nói rõ — nó sẽ đưa kèm mục *"bạn cần tự làm lại phần nào"*.

**`IMPORTANT_NOTES.md` vẫn rỗng sau nhiều buổi**
→ Bình thường nếu giảng viên chưa nói gì về thi. AI bị cấm **suy diễn** —
không nguồn thì không ghi. Đừng để nó đoán, vì cheatsheet sẽ dựng từ file này.

**Transcript Teams sai chính tả thuật ngữ nhiều quá**
→ Cứ dán thô. AI đọc slide song song để bù. Có slide thì note chính xác hơn hẳn.

**Repo nặng dần vì ebook PDF**
→ Git giữ mọi phiên bản vĩnh viễn, kể cả sau khi xoá. Slide vài MB thì không sao,
ebook 80MB thì cân nhắc Git LFS hoặc để ngoài repo. File video đã bị `.gitignore` chặn sẵn.

**Muốn đổi quy ước đặt tên file nộp**
→ `AGENTS.md` § 13.3. Hiện tại: `BT01-NguyễnQuốcTrung-25730081.pdf`, giữ dấu tiếng Việt.

**Lỡ xoá nhầm file**
→ `git log --oneline` tìm commit, `git checkout <commit> -- <đường/dẫn/file>`.
Mọi phiên học đều được commit nên gần như luôn lấy lại được.
