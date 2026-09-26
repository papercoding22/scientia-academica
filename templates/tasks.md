# Task & deadline — HK<n> <yyyy>–<yyyy>

| | |
|---|---|
| Học kỳ | **HK<n> <yyyy>–<yyyy>** → [`semesters/<kỳ>/`](../semesters/<kỳ>/README.md) |
| Trạng thái | ⬜ sắp học · 🔄 đang học · ✅ đã xong |
| Vai trò | **Nguồn sự thật duy nhất** cho việc có hạn và ngày tháng của học kỳ này |
| Đồng bộ ra | Notion ☕ Tasks · Google Calendar lịch `Work` — skill [`notion-tasks`](../.claude/skills/notion-tasks/SKILL.md) |

> Mọi ngày tháng phát hiện ở bất kỳ đâu (bài giảng, email, Teams, đề bài) **phải chảy về đây** trước,
> rồi mới lên Notion/Calendar. Ngày **luôn tuyệt đối** — không bao giờ ghi "tuần sau".

---

## Mục lục

<!-- scripts/toc.py gen admin/tasks-<kỳ>.md -->

---

## Quy ước

- **Khoá** = `<MÃ MÔN>/<thư mục mục nộp>` (`a3a`, `lab4`, `prj1`) · `<MÃ MÔN>/prjN/<mốc>` ·
  `<MÃ MÔN>/exam-<mid|final>`. Khoá là cầu nối với Notion và Calendar trong `admin/notion-map.json`
  (gitignore) — **không đổi khoá** của dòng đã đồng bộ.
- **Trạng thái:** `⬜ chưa làm` · `🔄 đang làm` · `✅ đã nộp` · `⚠️ trễ hạn`. Việc xong vẫn giữ dòng,
  chỉ đổi trạng thái và điền *Ngày nộp*.
- File này chỉ giữ **hạn do giảng viên đặt** và **lịch thi**. Mốc nhóm tự đặt nằm trong README đồ án;
  kế hoạch ôn thi nằm trên Notion/Calendar (skill `exam-plan`).
- Lịch học hằng tuần xem trên Google Calendar lịch `UIT Class`; mã lớp và giảng viên ở
  [README học kỳ](../semesters/<kỳ>/README.md).

---

## Mốc học kỳ

| Mốc | Ngày |
|---|---|
| Bắt đầu học kỳ | ❓ |
| Tuần thi giữa kỳ | ❓ |
| Kết thúc giảng dạy | ❓ |
| Tuần thi cuối kỳ | ❓ |
| Công bố điểm | ❓ |

---

<!-- Mỗi môn một mục như dưới đây, theo thứ tự bảng môn trong README học kỳ.
     "Quy tắc lặp lại" chỉ thêm khi giảng viên có quy tắc nộp lặp lại (có nguồn). -->

## <MÃ MÔN> — <Tên tiếng Việt>

[Thư mục môn](../semesters/<kỳ>/<MÃ MÔN>-<slug>/) · Notion `<TT>:`

### Việc và hạn nộp

| Khoá | Việc | Hạn | Trạng thái | Ngày nộp | Điểm | Nguồn |
|---|---|---|---|---|---|---|
| `<MÃ>/a1` | [Bài tập 1](../semesters/<kỳ>/<MÃ MÔN>-<slug>/assignments/a1/) — <tên> | YYYY-MM-DD HH:MM | ⬜ chưa làm | | | buổi N, YYYY-MM-DD |

### Lịch thi

| Khoá | Loại | Ngày | Giờ | Hình thức | Được mang gì |
|---|---|---|---|---|---|
| `<MÃ>/exam-mid` | Giữa kỳ | ❓ | ❓ | ❓ | ❓ |
| `<MÃ>/exam-final` | Cuối kỳ | ❓ | ❓ | ❓ | ❓ |
