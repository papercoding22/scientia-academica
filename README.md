# scientia-academica

Không gian học tập của **Nguyễn Quốc Trung** — MSSV `25730081`
Ngành Công nghệ Thông tin, hệ đào tạo từ xa, Trường ĐH Công nghệ Thông tin (UIT).

Repo này là nơi mọi thứ liên quan tới việc học đi qua: bài giảng Teams, note, bài tập,
đồ án, kế hoạch tốt nghiệp. AI làm việc trong repo theo luật ghi ở [`AGENTS.md`](AGENTS.md).

---

## Bắt đầu từ đâu

| Muốn gì | Mở file |
|---|---|
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
├── AGENTS.md                  # Luật cho AI — đọc trước khi làm gì
├── program/                   # Chương trình đào tạo · chuyên ngành · đồ án tốt nghiệp
├── admin/                     # Lịch học, deadline, hồ sơ
├── semesters/2025-2026-S3/    # Học kỳ hiện tại — 4 môn
├── knowledge-base/            # Khái niệm dùng chung, sống lâu hơn học kỳ
└── templates/                 # Khuôn mẫu AI dùng khi tạo file mới
```

Bên trong mỗi môn:

```
IT007-operating-systems/
├── README.md              # Syllabus, giảng viên, giáo trình
├── IMPORTANT_NOTES.md     # Cách tính điểm, phần sẽ thi, lời dặn của giảng viên
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

**Sau mỗi buổi học Teams:**
1. Copy transcript từ Teams → lưu vào `lectures/_raw/L<nn>-<ngày>-transcript.md`
2. Bảo AI: *"xử lý buổi 3 môn IT007"*
3. AI sinh note có phần **Tự kiểm tra**, cập nhật `IMPORTANT_NOTES.md` nếu có gợi ý thi,
   đẩy deadline mới vào `admin/deadlines.md`, và commit.

**Khi có bài tập mới:** bảo AI tạo `assignments/aN/`, bỏ đề bài vào `brief/`.
AI tự ghi hạn nộp vào `admin/deadlines.md`.

**Trước kỳ thi:** bảo AI sinh `exam-prep/cheatsheet.md` — nó dựng từ mục 2 và 3 của
`IMPORTANT_NOTES.md`, tức là từ chính lời giảng viên đã nói.

---

## Quy ước đặt tên

- **Tên đường dẫn: tiếng Anh.** `exam-prep/`, `process-scheduling.md`
- **Nội dung file: tiếng Việt có dấu.** Thuật ngữ kỹ thuật giữ tiếng Anh.
- **Ngoại lệ duy nhất — file nộp cho giảng viên giữ dấu tiếng Việt:**
  `BT01-NguyễnQuốcTrung-25730081.pdf`

Chi tiết đầy đủ ở [`AGENTS.md` § 13](AGENTS.md).
