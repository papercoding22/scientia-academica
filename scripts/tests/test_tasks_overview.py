"""Chạy: python3 -m unittest discover -s scripts/tests -p 'test_tasks_overview.py'."""

import datetime as dt
import importlib.util
from pathlib import Path
import unittest

SCRIPTS = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("tasks_overview", SCRIPTS / "tasks-overview.py")
ov = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ov)

SAMPLE = """# Task & deadline — test

## Mục lục

- [Mốc học kỳ](#mốc-học-kỳ)
- [AB123 — Môn thử](#ab123--môn-thử)

---

## Mốc học kỳ

| Mốc | Ngày |
|---|---|
| Bắt đầu học kỳ | ❓ |

---

## AB123 — Môn thử

### Việc và hạn nộp

| Khoá | Việc | Hạn | Trạng thái | Ngày nộp | Điểm | Nguồn |
|---|---|---|---|---|---|---|
| `AB123/a1` | [Bài tập 1](x/) — Một | 2026-09-20 21:30 | ✅ đã nộp | | | |
| `AB123/a2` | [Bài tập 2](x/) — Hai | 2026-09-30 | ⬜ chưa làm | | | |
| `AB123/a3` | Bài tập 3 | ❓ | ⬜ chưa làm | | | |

### Lịch thi

| Khoá | Loại | Ngày | Giờ | Hình thức | Được mang gì |
|---|---|---|---|---|---|
| — | ~~Giữa kỳ~~ | — | — | KHÔNG CÓ | — |
| `AB123/exam-final` | Cuối kỳ | **T7 2026-10-03** | **ca 4 — 15:00** | ❓ | ❓ |

### Kế hoạch ôn thi

| Khoá | Buổi ôn | Hạn | Trạng thái |
|---|---|---|---|
| `AB123/exam-final/r01` | Ôn chương 1 | 2026-09-26 11:30 | ⬜ chưa làm |
| `AB123/exam-final/r02` | Ôn chương 2 | 2026-09-26 16:30 | ✅ xong |
"""

NOW = dt.datetime(2026, 9, 27, 12, 0)


class TasksOverviewTest(unittest.TestCase):
    def setUp(self):
        self.section = ov.build(SAMPLE, NOW)

    def test_course_row(self):
        self.assertIn("| [AB123](#ab123--môn-thử) | 2 | T4 2026-09-30 (còn 3 ngày) |", self.section)
        self.assertIn("~~Giữa kỳ~~ không thi", self.section)
        self.assertIn("**Cuối kỳ T7 2026-10-03 15:00** (còn 6 ngày)", self.section)
        self.assertIn("1/2 xong · ⚠️ 1 quá hạn", self.section)

    def test_upcoming_and_overdue(self):
        upcoming = self.section.split("**Sắp tới")[1].split("**Quá hạn")[0]
        overdue = self.section.split("**Quá hạn")[1]
        self.assertIn("Bài tập 2 — Hai", upcoming)
        self.assertIn("| T7 2026-10-03 15:00 | AB123 | Thi | Thi cuối kỳ |", upcoming)
        self.assertNotIn("Bài tập 1", upcoming + overdue)  # đã nộp
        self.assertIn("Ôn chương 1", overdue)
        self.assertNotIn("Ôn chương 2", overdue)

    def test_apply_inserts_then_is_idempotent(self):
        once = ov.apply(SAMPLE, self.section)
        self.assertIn("## Tổng quan", once)
        self.assertIn("- [Tổng quan](#tổng-quan)", once)
        self.assertLess(once.index("## Mốc học kỳ"), once.index("## Tổng quan"))
        self.assertLess(once.index("## Tổng quan"), once.index("## AB123"))
        self.assertEqual(once, ov.apply(once, ov.build(once, NOW)))


if __name__ == "__main__":
    unittest.main()
