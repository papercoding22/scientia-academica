---
name: notion-tasks
description: Quản lý task University trên Notion (database ☕ Tasks) từ repo — đồng bộ bài nộp và lịch thi trong admin/deadlines.md lên Notion, kéo trạng thái Done về repo, sinh task ôn thi lùi ngược từ ngày thi, và tạo task lẻ theo yêu cầu. Luôn in bảng thay đổi và chờ duyệt trước khi ghi. Dùng khi người dùng nói "đồng bộ Notion", "sync Notion", "đẩy deadline lên Notion", "tạo task Notion", "thêm task ANTT/HDH/CSHT/QLTT…", "lập kế hoạch ôn thi trên Notion", hoặc ngay sau khi new-assignment tạo mục nộp mới.
---

# Task University trên Notion

Repo quyết định **có việc gì, hạn khi nào**. Notion quyết định **đã xong chưa**.
Skill này là cầu nối — không bao giờ để hai bên cùng quyết một thứ.

```
        repo (git)                              Notion ☕ Tasks
 ┌─────────────────────────┐   đẩy lên   ┌──────────────────────┐
 │ admin/deadlines.md      │ ──────────▶ │ tên · Deadline ·     │
 │  việc gì, hạn nào,      │             │ Notes · Priority     │
 │  nguồn (buổi học)       │ ◀────────── │                      │
 │  ✅ + ngày nộp          │   kéo về    │ Status=Done ·        │
 └─────────────────────────┘             │ Completion Date      │
                                         └──────────────────────┘
```

---

## Mục lục

- [Cấu hình](#cấu-hình)
  - [File ánh xạ `admin/notion-map.json`](#file-ánh-xạ-adminnotion-mapjson)
  - [Viết tắt môn](#viết-tắt-môn)
  - [Map property](#map-property)
- [Luật chung cho mọi chế độ](#luật-chung-cho-mọi-chế-độ)
- [Chế độ sync](#chế-độ-sync)
- [Chế độ exam-plan](#chế-độ-exam-plan)
- [Chế độ add](#chế-độ-add)
- [Commit và báo lại](#commit-và-báo-lại)
- [Không làm](#không-làm)

---

## Cấu hình

### File ánh xạ `admin/notion-map.json`

**File này bị `.gitignore`** — nó chứa URL workspace Notion riêng, repo thì public.
Đừng bao giờ chép URL Notion vào file được commit.

```json
{
  "database_url": "https://app.notion.com/p/<id>",
  "data_source": "collection://<id>",
  "tasks": {
    "IE105/a5":             { "page": "https://app.notion.com/p/<id>", "title": "ANTT: Bài tập 5 — Hàm băm, chữ ký số", "deadline": "2026-08-05T21:30" },
    "IE105/exam-final":     { "page": "…", "title": "ANTT: Thi cuối kỳ", "deadline": "…" },
    "IE105/exam-final/r03": { "page": "…", "title": "ANTT: Ôn chương 3 — …", "deadline": "…" }
  }
}
```

**Khoá** = `<MÃ MÔN>/<thư mục mục nộp>` (`a5`, `lab3`, `prj1`) · `<MÃ MÔN>/exam-<mid|final>`
· `<MÃ MÔN>/exam-<…>/r<nn>` cho task ôn · `<MÃ MÔN>/prjN/<mốc>` cho mốc đồ án giảng viên đặt. Task lẻ của chế độ add **không** vào map.

**File mất** (clone máy khác) → đọc `data_source` bằng cách hỏi người dùng link database,
rồi dựng lại `tasks` bằng cách khớp **tiền tố + tên bài + ngày hạn** với task Notion có sẵn.
In bảng khớp ra cho người dùng xác nhận trước khi ghi file — khớp sai thì sẽ đè nhầm task.

Luôn `notion-fetch` data source ở đầu phiên để lấy schema thật — tên option có thể đã đổi.

### Viết tắt môn

Tên task mở đầu bằng **viết tắt tiếng Việt** — đó là thói quen người dùng trên Notion.

| Mã môn | Tiền tố | Môn |
|---|---|---|
| IE105 | `ANTT:` | An toàn thông tin |
| IT007 | `HDH:` | Hệ điều hành |
| IE101 | `CSHT:` | Cơ sở hạ tầng CNTT |
| IE103 | `QLTT:` | Quản lý thông tin |

Môn mới chưa có trong bảng → **hỏi** người dùng viết tắt, rồi thêm dòng vào bảng này
(sửa skill, commit). Không tự bịa viết tắt.

### Map property

| Property | Bài nộp | Lịch thi | Task ôn thi | Task lẻ |
|---|---|---|---|---|
| **Tasks** | `ANTT: Bài tập 5 — Hàm băm, chữ ký số` | `ANTT: Thi cuối kỳ` | `ANTT: Ôn chương 3 — <tên chương>` | theo lời người dùng, có tiền tố |
| **Category** | `University` | `University` | `University` | `University` |
| **Topic** | `Homework` (đồ án: `Project Task`) | trống | trống | tuỳ, mặc định trống |
| **Deadline** | hạn nộp, có giờ nếu biết | ngày giờ thi | ngày ôn xong | theo lời người dùng |
| **Status** | xem bảng dưới | `To Do` | `To Do` | `To Do` |
| **Priority** | theo luật dưới | `High` | theo luật dưới | hỏi, mặc định `Medium` |
| **Notes** | 1 câu tóm tắt đề + đường dẫn repo | hình thức thi, được mang gì | phạm vi ôn + file blueprint | lời người dùng |
| **Completion Date** | **chỉ đọc** — kéo về repo | | | |
| **📺 Projects** | **không gắn** | | | |

Tên loại việc trong tiêu đề giữ đúng cách giảng viên gọi: `Bài tập 5`, `Bài thực hành 3`, `Đồ án 1`.

**Status** — repo → Notion khi tạo; sau đó Notion là chủ:

| `deadlines.md` | Notion |
|---|---|
| `⬜ chưa làm` | `To Do` |
| `🔄 đang làm` | `In progress` |
| `✅ đã nộp` | `Done` |
| Hạn `❓ chưa biết` | `Backlog`, Deadline trống |

**Priority** — tính lúc tạo, theo ngày hôm nay:

| Còn lại | Priority |
|---|---|
| Quá hạn hoặc ≤ 3 ngày | `High` |
| ≤ 7 ngày | `Medium` |
| Xa hơn / chưa biết | `Low` |

**Deadline** — ngày giờ Việt Nam. Có giờ (IE105: 21:30) thì ghi datetime
(`date:Deadline:start` = `2026-08-05T21:30:00+07:00`, `is_datetime` = 1);
chỉ có ngày thì ghi date. Sau lần ghi đầu tiên trong phiên, **fetch lại trang để
kiểm tra giờ hiển thị đúng 21:30** — lệch múi giờ là lỗi âm thầm.

Hạn có **dự phòng** (IE105: hết ngày hôm sau) → Deadline là hạn chính, ghi hạn dự phòng vào Notes.

---

## Luật chung cho mọi chế độ

1. **Đọc trước, in bảng, chờ duyệt, rồi mới ghi.** Không ngoại lệ, kể cả khi chỉ có 1 thay đổi.
   Bảng xem trước có cột: `#` · hành động (`＋ tạo` / `✎ sửa` / `✓ kéo về` / `? hỏi`) ·
   task · thay đổi cụ thể (cũ → mới). Người dùng có thể duyệt một phần: *"OK trừ 3"*.
2. **Ngày luôn tuyệt đối** (`AGENTS.md` § 10). *"thứ 7"*, *"tuần sau"* → quy đổi từ hôm nay,
   **nói lại ngày đã quy đổi** trong bảng xem trước. Mơ hồ thì hỏi.
3. **Deadline của giảng viên đi vào `admin/deadlines.md` trước**, rồi mới lên Notion.
   Không bao giờ có deadline chỉ tồn tại trên Notion mà repo không biết.
4. Ghi Notion theo lô (`notion-create-pages` nhận nhiều trang một lần), ghi xong cập nhật
   `admin/notion-map.json` ngay — đứt giữa chừng thì lần sau vẫn biết task nào đã có.
5. Task **không có trong map** trên Notion là của người dùng — chỉ được đụng vào khi
   người dùng duyệt rõ từng task.

---

## Chế độ sync

**Kích hoạt:** *"đồng bộ Notion"*, *"sync"*, hoặc sau `new-assignment` (chỉ sync mục vừa tạo).

### 1. Đọc hai bên

- Repo: `admin/deadlines.md` — bảng **Sắp tới**, **Đã xong**, **Lịch thi**. Mỗi dòng bài nộp
  có link tới thư mục `aN/`/`labN/` → suy ra khoá. Đọc thêm `aN/README.md` để lấy 1 câu tóm tắt đề cho Notes.
- Notion: query mọi task `Category` chứa `University`:

  ```sql
  SELECT url, Tasks, Status, "date:Deadline:start", Priority, Notes, "date:Completion Date:start"
  FROM "<data_source>" WHERE Category LIKE '%University%'
  ```

### 2. Phân loại

| Tình huống | Hành động |
|---|---|
| Dòng **Sắp tới** chưa có khoá trong map | `＋ tạo` task |
| Dòng **Đã xong** chưa có khoá trong map | bỏ qua — lịch sử, không đưa lên Notion |
| Hạn trong repo khác `deadline` đã lưu trong map | `✎ sửa` Deadline trên Notion (repo là chủ ngày tháng) |
| Task trong map có Notion `Done`, repo chưa ✅ | `✓ kéo về`: chuyển dòng sang bảng **Đã xong**, cột *Ngày nộp* = Completion Date (trống thì ghi `✅` và hỏi ngày) · cập nhật trạng thái trong `README.md` của môn và của `aN/` |
| Repo ✅ mà Notion chưa `Done` | `? hỏi` — có thể người dùng đánh dấu nhầm một bên |
| Lịch thi có ngày cụ thể, chưa có khoá `exam-*` | `＋ tạo` task thi · gợi ý chạy exam-plan |
| Task University trên Notion **ngoài map**, chưa Done, Deadline đã qua | `? hỏi`: chuyển `Done`, `Archived`, hay để nguyên |
| Task trong map không còn trên Notion (bị xoá) | `? hỏi`: tạo lại hay bỏ khỏi map |
| Priority lệch luật (task sắp tới hạn mà vẫn `Low`) | `✎ sửa` — **chỉ đề xuất nâng**, không bao giờ hạ Priority người dùng đã đặt |

Dòng quá hạn trong repo mà chưa có file nộp (ví dụ *"Bài 5 quá hạn… kiểm tra xem đã nộp chưa"*)
→ vẫn tạo task `High`, ghi vào Notes *"quá hạn — kiểm tra đã nộp chưa"*.

### 3. Duyệt → ghi → cập nhật map

---

## Chế độ exam-plan

**Kích hoạt:** *"lập kế hoạch ôn thi <môn>"*, hoặc sync phát hiện lịch thi có ngày mà chưa có task ôn.

**Cần có ngày thi tuyệt đối** trong `deadlines.md`. Chưa có → dừng, nói rõ, không đoán.

1. **Lấy danh sách phần cần ôn**, ưu tiên theo thứ tự:
   1. Exam blueprint của skill `exam-map` trong `<môn>/exam-prep/` — chia theo **trọng số điểm**
   2. `IMPORTANT_NOTES.md` mục 2/3 (phạm vi thi, gợi ý thi) — **có nguồn thì mới dùng**
   3. Knowledge map (`slide-knowledge-map`) hoặc danh sách `lectures/` — chia đều theo chương
2. **Hỏi người dùng 2 câu** trước khi xếp lịch: *bắt đầu ôn từ ngày nào* · *mỗi tuần ôn được mấy buổi*.
   Người dùng đi làm — đừng tự giả định ôn mỗi ngày.
3. **Xếp lùi từ ngày thi:**
   - 1–2 ngày cuối: `<TT>: Ôn tổng + làm đề mẫu` (Priority `High`)
   - Các buổi trước: mỗi task một chương/cụm chương; chương trọng số cao hoặc có `⚠️ GỢI Ý THI` xếp **sớm hơn** và Priority cao hơn
   - Kiểm tra trùng hạn nộp bài khác trong `deadlines.md` — tránh xếp buổi ôn vào ngày có deadline
4. Notes mỗi task: phạm vi (mục/slide) + đường dẫn file blueprint hoặc note trong repo.
5. In bảng lịch ôn → duyệt → tạo → ghi khoá `<MÃ>/exam-<…>/r<nn>` vào map.

Task ôn là kế hoạch cá nhân, **không ghi vào `deadlines.md`** — file đó chỉ giữ hạn của giảng viên.

---

## Chế độ add

**Kích hoạt:** người dùng nói thẳng việc cần tạo — *"tạo task HDH xem lại video buổi 6, hạn thứ 7"*.

1. Xác định môn → tiền tố. Không rõ môn → hỏi.
2. Quy đổi hạn sang ngày tuyệt đối, **nói lại**: *"thứ 7 = 2026-09-26"*.
3. **Đây có phải deadline của giảng viên không?** (nộp bài, điểm danh, nộp nhóm…)
   → có: ghi vào `deadlines.md` trước, xử lý như sync (có khoá, vào map).
   → không (việc tự đặt cho mình): chỉ tạo trên Notion, không vào map.
4. In 1 dòng xem trước → duyệt → tạo.

---

## Commit và báo lại

Chỉ commit khi file tracked thay đổi (`deadlines.md`, README môn/bài). `notion-map.json` không bao giờ vào git.

```
<MÃ MÔN>: đồng bộ Notion — <n> task mới, <m> đã nộp
repo: đồng bộ Notion — …        ← khi nhiều môn
```

Báo lại: bao nhiêu task tạo/sửa/kéo về · link database Notion · những mục `? hỏi` còn treo ·
deadline trong 7 ngày tới.

---

## Không làm

- ❌ **Không ghi gì lên Notion hay repo trước khi người dùng duyệt bảng xem trước.**
- ❌ **Không xoá task Notion** — tối đa chuyển `Archived`, và chỉ khi được duyệt.
- ❌ Không để Notion ghi đè ngày tháng trong repo. Ngày lệch → repo thắng, Notion được sửa theo.
- ❌ Không commit `admin/notion-map.json`, không chép URL Notion vào file tracked — repo public.
- ❌ Không gắn 📺 Projects cho task University.
- ❌ Không tự bịa viết tắt môn, không đoán ngày thi, không "làm tròn" deadline.
- ❌ Không hạ Priority mà người dùng đã tự đặt.
- ❌ Không sửa task Notion ngoài map khi chưa được duyệt từng task.
