"""Chạy: python3 -m unittest discover -s scripts/tests -p 'test_tasks_overview.py'."""

import datetime as dt
import importlib.util
from pathlib import Path
import unittest

SCRIPTS = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("tasks_overview", SCRIPTS / "tasks-overview.py")
ov = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ov)

HEAD = "| Hạn | Còn lại | Môn | Loại | Việc | Trạng thái | Khoá | Ghi chú |\n|---|---|---|---|---|---|---|---|\n"
SAMPLE = f"""# Task — test

Phần đầu file giữ nguyên.

{ov.START}

## 1. Sẽ làm

{HEAD}| 2026-09-20 21:30 | | AB123 | Hạn nộp | [Bài tập 1](x/) — Một | ✅ đã nộp | `AB123/a1` | nộp 2026-09-20 |
| 2026-09-30 | | AB123 | Hạn nộp | [Bài tập 2](x/) — Hai | ⬜ chưa làm | `AB123/a2` | buổi 3 |
| ❓ | | AB123 | Hạn nộp | Bài tập 3 | ⬜ chưa làm | `AB123/a3` | |
| 2026-10-20 | | AB123 | Hạn nộp | Bài tập 4 | 🔄 đang làm | `AB123/a4` | |
| 2026-10-03 15:00 | | AB123 | Thi | Thi cuối kỳ | — | `AB123/exam-final` | ca 4 |
| 2026-09-01 08:00 | | AB123 | Thi | Thi giữa kỳ | — | `AB123/exam-mid` | |
| 2026-09-26 11:30 | | AB123 | Ôn thi | Ôn chương 1 | 🔄 đang làm | `AB123/exam-final/r01` | |
| 2026-09-26 16:30 | | AB123 | Ôn thi | Ôn chương 2 | ✅ xong | `AB123/exam-final/r02` | |
| 2026-09-28 | | AB123 | Ôn thi | Ôn chương 3 | ⬜ chưa làm | `AB123/exam-final/r03` | |

{ov.END}

Phần cuối file giữ nguyên.
"""

NOW = dt.datetime(2026, 9, 27, 12, 0)


def group(md, title):
    """Nội dung một nhóm, từ tiêu đề tới nhóm kế tiếp."""
    return md.split(f"## {title}")[1].split("\n## ")[0]


class TasksOverviewTest(unittest.TestCase):
    def setUp(self):
        self.md = ov.apply(SAMPLE, NOW)

    def test_todo(self):
        todo = group(self.md, "1. Sẽ làm")
        self.assertIn("| T4 2026-09-30 | còn 3 ngày | AB123 | Hạn nộp | [Bài tập 2](x/) — Hai | ⬜ chưa làm | `AB123/a2` | buổi 3 |", todo)
        self.assertIn("| ❓ | — | AB123 | Hạn nộp | Bài tập 3 |", todo)
        self.assertIn("Thi cuối kỳ", todo)  # kỳ thi chưa diễn ra
        self.assertLess(todo.index("Bài tập 2"), todo.index("Bài tập 3"))  # hạn ❓ xếp cuối

    def test_doing_late_done(self):
        self.assertIn("Bài tập 4", group(self.md, "2. Đang làm"))
        late = group(self.md, "3. Trễ tiến độ")
        self.assertIn("| T7 2026-09-26 11:30 | quá 1 ngày | AB123 | Ôn thi | Ôn chương 1 | 🔄 đang làm |", late)
        done = group(self.md, "5. Đã xong")
        self.assertIn("Bài tập 1", done)
        self.assertIn("| đã thi |", done)  # thi giữa kỳ đã qua
        self.assertLess(done.index("Ôn chương 2"), done.index("Bài tập 1"))  # mới nhất lên đầu

    def test_each_task_once_in_managed_groups(self):
        managed = [group(self.md, t) for t in ("1. Sẽ làm", "2. Đang làm", "3. Trễ tiến độ", "5. Đã xong")]
        for key in ("AB123/a1`", "AB123/a2`", "AB123/a3`", "AB123/a4`", "exam-final`", "exam-mid`", "r01`", "r02`", "r03`"):
            self.assertEqual(sum(key in g for g in managed), 1, key)

    def test_notable_is_view_only(self):
        notable = group(self.md, "4. Quan trọng")
        self.assertIn("| Thi cuối kỳ | kỳ thi |", notable)
        self.assertIn("| [Bài tập 2](x/) — Hai | hạn giảng viên |", notable)
        self.assertIn("| Ôn chương 3 | hạn hôm nay/ngày mai |", notable)
        self.assertNotIn("Bài tập 4", notable)  # còn 23 ngày
        # Dòng ở nhóm 4 không bị đọc lại thành task
        self.assertEqual(len(ov.parse_rows(self.md)), 9)

    def test_user_edits_move_rows_and_are_idempotent(self):
        edited = self.md.replace("| Bài tập 4 | 🔄 đang làm |", "| Bài tập 4 | ✅ đã nộp |")
        again = ov.apply(edited, NOW)
        self.assertIn("Bài tập 4", group(again, "5. Đã xong"))
        self.assertNotIn("Bài tập 4", group(again, "2. Đang làm"))
        self.assertEqual(again, ov.apply(again, NOW))
        self.assertTrue(again.startswith("# Task — test\n\nPhần đầu file giữ nguyên."))
        self.assertTrue(again.endswith("Phần cuối file giữ nguyên.\n"))


if __name__ == "__main__":
    unittest.main()
