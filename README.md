# scientia-academica

Không gian học tập cá nhân cho chương trình đại học ngành Công nghệ Thông tin,
hệ đào tạo từ xa.

Repo này là nơi mọi thứ liên quan tới việc học đi qua: bài giảng Teams, note, bài tập,
đồ án, kế hoạch tốt nghiệp. AI làm việc trong repo theo luật ghi ở [`AGENTS.md`](AGENTS.md).

> 📖 **Muốn biết thao tác thế nào → [`HOW-TO.md`](HOW-TO.md).**
> Hướng dẫn từng việc kèm câu lệnh copy dùng thẳng, và ví dụ một thư mục môn học
> sau 6 tuần trông ra sao.

---

## Mục lục

- [Bắt đầu từ đâu](#bắt-đầu-từ-đâu)
- [Bốn tầng thời gian](#bốn-tầng-thời-gian)
- [Cấu trúc](#cấu-trúc)
- [Dùng hàng ngày](#dùng-hàng-ngày)
- [Quy ước đặt tên](#quy-ước-đặt-tên)

---

## Bắt đầu từ đâu

| Muốn gì | Mở file |
|---|---|
| **Thao tác thế nào** | [`HOW-TO.md`](HOW-TO.md) |
| Có skill nào, gọi thế nào | [`SKILLS.md`](SKILLS.md) |
| Tuần này phải nộp gì | [`admin/deadlines.md`](admin/deadlines.md) |
| Học kỳ này có môn gì | [`semesters/2025-2026-S3/README.md`](semesters/2025-2026-S3/README.md) |
| Môn này thi phần nào | `semesters/<kỳ>/<môn>/IMPORTANT_NOTES.md` |
| Còn bao nhiêu tín chỉ nữa ra trường | [`program/README.md`](program/README.md) |
| Chọn chuyên ngành nào | [`program/specialization/README.md`](program/specialization/README.md) |
| Ý tưởng đồ án tốt nghiệp | [`program/thesis/ideas/`](program/thesis/ideas/) |

---

## Bốn tầng thời gian

Mỗi thư mục cấp cao ứng với một tầm thời gian. Phân vân bỏ file vào đâu →
hỏi *"cái này còn đúng sau bao lâu?"*

| Tầng | Thư mục | Tầm nhìn | Thay đổi |
|---|---|---|---|
| **Chiến lược** | `program/` | 4 năm | vài lần mỗi học kỳ |
| **Chiến thuật** | `semesters/` | 1 học kỳ | hàng tuần |
| **Vận hành** | `admin/` | 1 tuần | hàng ngày |
| **Tích luỹ** | `knowledge-base/` | vĩnh viễn | khi có khái niệm mới |

---

## Cấu trúc

```
scientia-academica/
├── HOW-TO.md                  # Hướng dẫn thao tác — đọc cái này
├── AGENTS.md                  # Luật cho AI — đọc trước khi làm gì
├── SKILLS.md                  # Danh mục skill — tra nhanh skill nào làm gì
├── program/                   # Chương trình đào tạo · chuyên ngành · đồ án tốt nghiệp
├── admin/                     # Lịch học, deadline, hồ sơ
├── semesters/2025-2026-S3/    # Học kỳ hiện tại — 4 môn
├── knowledge-base/            # Khái niệm dùng chung, sống lâu hơn học kỳ
├── templates/                 # Khuôn mẫu AI dùng khi tạo file mới
├── scripts/                   # Script tự động hoá
├── .claude/skills/            # Nguồn skill riêng của repo (Claude)
└── .agents/skills/            # Symlink để Codex discover cùng các skill đó
```

**Thêm môn học mới:** gõ `/new-course` rồi đưa mã môn, tên, giảng viên.
Skill sẽ chạy `scripts/new-course.sh` tạo khung, rồi nối môn mới vào 6 file khác
đang giữ danh sách môn. Muốn tự chạy script thì `scripts/new-course.sh --help`.

Bên trong mỗi môn:

```
IT007-operating-systems/
├── README.md              # Syllabus, giảng viên, giáo trình
├── IMPORTANT_NOTES.md     # Cách tính điểm, phần sẽ thi, lời dặn của giảng viên
├── materials/             # Tài liệu giảng viên gửi — slide, đề cương, ebook (chỉ đọc)
├── lectures/_raw/         # Transcript Teams gốc — không bao giờ sửa
├── lectures/              # Note đã cấu trúc hoá theo buổi
├── notes/                 # Note theo khái niệm
├── assignments/a1/        # Bài tập: brief/ resources/ images/ + file nộp
├── projects/prj1/         # Đồ án: brief/ docs/ src/ images/ + bản nộp
├── research/              # Tự đào sâu ngoài syllabus
├── code/                  # Lab, thử nghiệm nhanh
└── exam-prep/             # flashcards.md · flashcards.csv · cheatsheet.md
```

---

## Dùng hàng ngày

Vòng lặp cơ bản — chi tiết từng bước ở [`HOW-TO.md`](HOW-TO.md):

```
Slide giảng viên gửi  →  materials/slides/
Transcript sau buổi   →  lectures/_raw/
"xử lý buổi 3 IT007"  →  note + flashcard + deadline + commit
```

Bạn chỉ làm hai việc thủ công: bỏ slide vào `materials/`, dán transcript vào `_raw/`.

---

## Quy ước đặt tên

- **Tên đường dẫn: tiếng Anh.** `exam-prep/`, `process-scheduling.md`
- **Nội dung file: tiếng Việt có dấu.** Thuật ngữ kỹ thuật giữ tiếng Anh.
- **Ngoại lệ duy nhất — file nộp cho giảng viên giữ dấu tiếng Việt:**
  `BT01-<HọVàTên>-<MSSV>.pdf`

Chi tiết đầy đủ ở [`AGENTS.md` § 13](AGENTS.md).
