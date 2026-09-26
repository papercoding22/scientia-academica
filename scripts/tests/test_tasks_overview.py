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
| `AB123/a4` | Bài tập 4 | 2026-10-20 | 🔄 đang làm | | | |

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


def group(section, title):
    """Nội dung một nhóm, từ tiêu đề tới tiêu đề nhóm kế tiếp."""
    part = section.split(f"**{title}")[1]
    return part.split("\n**")[0]


class TasksOverviewTest(unittest.TestCase):
    def setUp(self):
        self.section = ov.build(SAMPLE, NOW)

    def test_todo(self):
        todo = group(self.section, "1. Sẽ làm")
        self.assertIn("| T4 2026-09-30 | còn 3 ngày | AB123 | Hạn nộp | Bài tập 2 — Hai |", todo)
        self.assertIn("| ❓ | — | AB123 | Hạn nộp | Bài tập 3 |", todo)
        self.assertLess(todo.index("Bài tập 2"), todo.index("Bài tập 3"))  # chưa rõ hạn xếp cuối
        self.assertNotIn("Bài tập 1", self.section)  # đã nộp
        self.assertNotIn("Thi cuối kỳ", todo)  # thi không phải task

    def test_doing_and_late(self):
        self.assertIn("Bài tập 4", group(self.section, "2. Đang làm"))
        late = group(self.section, "3. Trễ tiến độ")
        self.assertIn("| T7 2026-09-26 11:30 | quá 1 ngày | AB123 | Ôn thi | Ôn chương 1 |", late)
        self.assertNotIn("Ôn chương 2", late)  # đã xong

    def test_each_task_in_one_group(self):
        groups = [group(self.section, t) for t in ("1. Sẽ làm", "2. Đang làm", "3. Trễ tiến độ")]
        for name in ("Bài tập 2", "Bài tập 3", "Bài tập 4", "Ôn chương 1"):
            self.assertEqual(sum(name in g for g in groups), 1, name)

    def test_notable(self):
        notable = group(self.section, "4. Quan trọng")
        self.assertIn("| AB123 | Thi | Thi cuối kỳ | kỳ thi |", notable)
        self.assertIn("| Bài tập 2 — Hai | hạn giảng viên |", notable)
        self.assertNotIn("Bài tập 4", notable)  # còn 23 ngày

    def test_apply_inserts_then_is_idempotent(self):
        once = ov.apply(SAMPLE, self.section)
        self.assertIn("## Tổng quan", once)
        self.assertIn("- [Tổng quan](#tổng-quan)", once)
        self.assertLess(once.index("## Mốc học kỳ"), once.index("## Tổng quan"))
        self.assertLess(once.index("## Tổng quan"), once.index("## AB123"))
        self.assertEqual(once, ov.apply(once, ov.build(once, NOW)))


if __name__ == "__main__":
    unittest.main()
