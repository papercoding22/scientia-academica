---
name: notion-tasks
description: Đồng bộ task University từ repo lên Notion (database ☕ Tasks) và Google Calendar (lịch Work) — nguồn là admin/tasks-<học kỳ>.md, đẩy bài nộp và lịch thi của từng môn lên, kéo trạng thái Done về repo, và tạo task lẻ theo yêu cầu (lập kế hoạch ôn thi do skill `exam-plan` lo). Luôn in bảng thay đổi và chờ duyệt trước khi ghi. Dùng khi người dùng nói "đồng bộ Notion", "sync Notion", "đồng bộ lịch", "đẩy deadline lên Notion/Calendar", "tạo task Notion", "thêm task ANTT/HDH/CSHT/QLTT…", "lập kế hoạch ôn thi trên Notion", hoặc ngay sau khi new-assignment tạo mục nộp mới.
---

# Task University — repo → Notion + Google Calendar

Repo quyết định **có việc gì, hạn khi nào**. Notion quyết định **đã xong chưa**.
Google Calendar chỉ **hiển thị và nhắc** — không quyết định gì.
Skill này là cầu nối — không bao giờ để hai bên cùng quyết một thứ.

Chỉ đổi trạng thái một vài task người dùng vừa nhắc (*"đã nộp bài 8"*) → dùng skill **`task-status`**, không cần quét toàn bộ.

```
        repo (git)                              Notion ☕ Tasks
 ┌─────────────────────────┐   đẩy lên   ┌──────────────────────┐
 │ admin/tasks-<kỳ>.md     │ ──────────▶ │ tên · Deadline ·     │
 │  mỗi môn một mục:       │             │ Notes · Priority     │
 │  khoá · việc · hạn ·    │ ◀────────── │                      │
 │  trạng thái · lịch thi  │   kéo về    │ Status=Done ·        │
 └───────────┬─────────────┘             │ Completion Date      │
             │ đẩy lên                   └──────────────────────┘
             ▼
   Google Calendar — lịch Work
   sự kiện hạn nộp · sự kiện thi
   (chỉ nhắc, không kéo gì về)
```

---

## Mục lục

- [Cấu hình](#cấu-hình)
  - [File ánh xạ `admin/notion-map.json`](#file-ánh-xạ-adminnotion-mapjson)
  - [Viết tắt môn](#viết-tắt-môn)
  - [Map property](#map-property)
  - [Nội dung trang task (template)](#nội-dung-trang-task-template)
- [Luật chung cho mọi chế độ](#luật-chung-cho-mọi-chế-độ)
- [Chế độ sync](#chế-độ-sync)
- [Chế độ exam-plan](#chế-độ-exam-plan)
- [Chế độ add](#chế-độ-add)
- [Đồng bộ Google Calendar](#đồng-bộ-google-calendar)
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
    "IE105/a5":             { "page": "https://app.notion.com/p/<id>", "title": "ANTT: Bài tập 5 — Hàm băm, chữ ký số", "deadline": "2026-08-05T21:30", "event": "<id sự kiện Calendar>" },
    "IE105/exam-final":     { "page": "…", "title": "ANTT: Thi cuối kỳ", "deadline": "…" },
    "IE105/exam-final/r03": { "page": "…", "title": "ANTT: Ôn chương 3 — …", "deadline": "…" }
  }
}
```

**Khoá** = cột *Khoá* trong `admin/tasks-<kỳ>.md` = `<MÃ MÔN>/<thư mục mục nộp>` (`a5`, `lab3`, `prj1`) · `<MÃ MÔN>/exam-<mid|final>`
· `<MÃ MÔN>/exam-<…>/r<nn>` cho task ôn · `<MÃ MÔN>/prjN/<mốc>` cho mốc đồ án giảng viên đặt. Task lẻ của chế độ add **không** vào map.
`event` = id sự kiện Google Calendar của khoá đó (không có thì bỏ trống) — nhờ nó mà dời/xoá được sự kiện khi hạn đổi.

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
| **Icon** (trang) | emoji ngẫu nhiên — xem dưới | như bên trái | như bên trái | như bên trái |

**Icon** — mỗi task **mới tạo** có một emoji ngẫu nhiên, truyền qua tham số `icon` của từng trang trong
`notion-create-pages`. Bốc bằng lệnh (đừng tự "chọn ngẫu nhiên" trong đầu — sẽ lặp lại mấy icon quen),
`n` = số task trong lô; các icon trong cùng lô **không trùng nhau**:

```bash
python3 -c "import random,sys;print(' '.join(random.sample('📘 📗 📙 📕 📓 📒 📝 ✏️ 🖊️ 📌 📎 🧠 💡 🔍 🧩 🎯 🚀 ⚡ 🔥 🌱 🌟 🍀 🧪 🔬 🛠️ ⚙️ 💻 🖥️ 🗂️ 📊 🧭 🏁 ⏳ 🎓 🦉 🐢 🐙 🦊 🍵 ☕'.split(),int(sys.argv[1]))))" <n>
```

Chỉ đặt icon lúc **tạo** — không đổi icon của task đã có (người dùng có thể đã tự chọn). Icon ghi trong
bảng xem trước, cột *Task* (vd `🧩 ANTT: Bài tập 8`).

Tên loại việc trong tiêu đề giữ đúng cách giảng viên gọi: `Bài tập 5`, `Bài thực hành 3`, `Đồ án 1`.

**Status** — repo → Notion khi tạo; sau đó Notion là chủ:

| `tasks-<kỳ>.md` | Notion |
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

### Nội dung trang task (template)

**Mọi task tạo ra đều dùng cấu trúc này** — khớp template `☕ Task` của database
(template chung mọi Category). Skill tự viết nội dung (`content` của `notion-create-pages`),
**điền sẵn** thay vì để trống, nên không phụ thuộc việc API áp template.

```
## 📝 Mô tả
- **Bối cảnh:** môn, bài/đồ án, vai trò người dùng (vd nhóm trưởng)
- **Vấn đề cần giải quyết:** vì sao task tồn tại, xong thì mở khoá được gì
- **Liên kết:** repo path · OneDrive/SharePoint · tài liệu · task liên quan
## 🎯 Kết quả đầu ra
<table header-row="true">  Câu hỏi | Trả lời   — mỗi dòng một câu hỏi, cột Trả lời để trống
<callout icon="✅" color="green_bg"> Chỉ chuyển **Done** khi mọi câu hỏi ở trên đã có câu trả lời.
## 🪜 Các bước thực hiện       — checklist `- [ ]`
## ⛓️ Phụ thuộc & phối hợp     — Bị chặn bởi · Chặn · Cần phối hợp với
## 🗒️ Nhật ký & vướng mắc      — bảng Ngày | Đã làm | Vướng; dòng đầu = ngày tạo task
```

Bản đầy đủ (Notion-flavored markdown, bảng dùng `<table>`) — fetch trang template
`☕ Task` trong database để copy đúng; **đừng tự nghĩ lại cấu trúc**.

**Viết câu hỏi Kết quả đầu ra thế nào** — đây là phần quan trọng nhất:

| Tốt | Không tốt |
|---|---|
| Câu hỏi **trả lời được bằng dữ kiện**: *Có bao nhiêu người đã nộp / tổng số?* | Mệnh lệnh chung chung: *Kiểm tra file* |
| Mỗi câu một ý; 3–5 câu | Gộp nhiều ý, hoặc > 7 câu |
| Có câu về **hành động tiếp theo**: *Đã thông báo cho người chưa nộp chưa?* | Chỉ hỏi trạng thái, không hỏi đã xử lý chưa |
| Bài nộp: *File nộp tên gì, đúng mẫu giảng viên chưa? Đã nộp lên đâu, lúc nào?* | |
| Task ôn thi: *Tự trả lời được 5 câu Tự kiểm tra của chương N chưa? Câu nào sai?* | |

Bảng xem trước **phải liệt kê các câu hỏi Kết quả đầu ra** của từng task để người dùng duyệt/sửa.
Người dùng thường không muốn đọc cả trang — chỉ cần câu hỏi + bước chính.

Sửa task cũ sang cấu trúc này dùng `replace_content`, **giữ lại mọi nội dung người dùng đã viết**
(đưa vào đúng mục, thường là Nhật ký) — không bao giờ xoá chữ của người dùng.

---

## Luật chung cho mọi chế độ

1. **Đọc trước, in bảng, chờ duyệt, rồi mới ghi.** Không ngoại lệ, kể cả khi chỉ có 1 thay đổi.
   Bảng xem trước có cột: `#` · hành động (`＋ tạo` / `✎ sửa` / `✓ kéo về` / `? hỏi`) ·
   task · thay đổi cụ thể (cũ → mới). Người dùng có thể duyệt một phần: *"OK trừ 3"*.
2. **Ngày luôn tuyệt đối** (`AGENTS.md` § 10). *"thứ 7"*, *"tuần sau"* → quy đổi từ hôm nay,
   **nói lại ngày đã quy đổi** trong bảng xem trước. Mơ hồ thì hỏi.
3. **Deadline của giảng viên đi vào `admin/tasks-<kỳ>.md` trước** (dòng mới ở nhóm 1), rồi mới lên Notion/Calendar.
   Không bao giờ có deadline chỉ tồn tại trên Notion hay Calendar mà repo không biết.
4. Ghi Notion theo lô (`notion-create-pages` nhận nhiều trang một lần), ghi xong cập nhật
   `admin/notion-map.json` ngay — đứt giữa chừng thì lần sau vẫn biết task nào đã có.
5. Task **không có trong map** trên Notion là của người dùng — chỉ được đụng vào khi
   người dùng duyệt rõ từng task.

---

## Chế độ sync

**Kích hoạt:** *"đồng bộ Notion"*, *"sync Notion với admin/tasks"*, *"đồng bộ lịch"*, *"sync"*, hoặc sau `new-assignment` /
`new-project` (chỉ sync mục vừa tạo). Đây là đồng bộ **hai chiều** repo ↔ Notion trong một lượt: đẩy việc/hạn
lên, kéo trạng thái về.

**Phạm vi:** mặc định cả Notion lẫn Calendar. Người dùng nói *"chỉ Notion"* → bỏ phần Calendar (không đọc,
không tạo/dời sự kiện); *"chỉ lịch"* → bỏ phần Notion.

### 1. Đọc ba bên

- **Repo** — `admin/tasks-<kỳ>.md` của **học kỳ đang học** (xem `AGENTS.md` § 1); thêm file học kỳ
  sắp học nếu nó đã có dòng có ngày. Đọc mọi dòng ở nhóm 1, 2, 3, 5 (nhóm 4 là bảng xem, bỏ qua);
  cột **Khoá** là khoá trong map, cột **Loại** (`Hạn nộp` · `Thi` · `Ôn thi`) quyết định map property. Đọc thêm `aN/README.md` để lấy 1 câu tóm tắt đề cho Notes.
  Dòng thiếu khoá → đề xuất khoá theo quy ước, ghi vào file cùng lượt duyệt.
- **Notion** — query mọi task `Category` chứa `University`:

  ```sql
  SELECT url, Tasks, Status, "date:Deadline:start", Priority, Notes, "date:Completion Date:start"
  FROM "<data_source>" WHERE Category LIKE '%University%'
  ```

- **Google Calendar** — `list_calendars` tra id lịch **`Work`** theo tên; với mỗi khoá có `event`
  trong map, `get_event` để biết giờ hiện tại (sự kiện bị xoá tay → coi như chưa có).

### 2. Phân loại

| Tình huống trong `tasks-<kỳ>.md` | Notion | Calendar |
|---|---|---|
| Dòng chưa ✅, khoá chưa có trong map | `＋ tạo` task | `＋ tạo` sự kiện nếu có ngày (xem [Đồng bộ Google Calendar](#đồng-bộ-google-calendar)) |
| Dòng ✅ mà khoá chưa có trong map | bỏ qua — lịch sử | bỏ qua |
| Hạn/giờ thi khác `deadline` đã lưu trong map | `✎ sửa` Deadline (repo là chủ ngày tháng) | `✎ dời` sự kiện |
| Hạn đổi từ `❓` sang ngày cụ thể | `✎ sửa` Deadline, `Backlog` → `To Do` | `＋ tạo` sự kiện |
| Task trong map có Notion `Done`, repo chưa ✅ | `✓ kéo về`: đổi **Trạng thái** dòng đó thành `✅ đã nộp` (`✅ xong` với `Ôn thi`), *Ghi chú* thêm `nộp <Completion Date>` (trống thì hỏi ngày) · cập nhật trạng thái trong `README.md` của môn và của `aN/` | giữ nguyên sự kiện — lịch sử |
| Task trong map có Notion `In progress`, repo còn `⬜` | `✓ kéo về`: Trạng thái → `🔄 đang làm` | — |
| Repo ✅ mà Notion chưa `Done` | `? hỏi` — có thể người dùng đánh dấu nhầm một bên | — |
| Dòng `Thi` có ngày cụ thể, chưa có khoá `exam-*` trong map | `＋ tạo` task thi · gợi ý chạy `exam-plan` | `＋ tạo` sự kiện thi |
| Khoá có trong map nhưng **dòng đã bị xoá** khỏi file (bỏ theo dõi) | `? hỏi`: chuyển `Archived` hay để nguyên | `? hỏi`: xoá sự kiện hay để nguyên |
| Task University trên Notion **ngoài map**, chưa Done, Deadline đã qua | `? hỏi`: chuyển `Done`, `Archived`, hay để nguyên | — |
| Task trong map không còn trên Notion (bị xoá) | `? hỏi`: tạo lại hay bỏ khỏi map | — |
| Task ôn (`…/r<nn>`) có trong map mà file chưa có dòng | `✓ kéo về`: thêm dòng `Ôn thi` vào nhóm 1 (hạn · môn · buổi ôn · trạng thái theo Notion · khoá) | — |
| Priority lệch luật (task sắp tới hạn mà vẫn `Low`) | `✎ sửa` — **chỉ đề xuất nâng**, không bao giờ hạ Priority người dùng đã đặt | — |

Dòng quá hạn trong repo mà chưa có file nộp → vẫn tạo task `High`, ghi vào Notes
*"quá hạn — kiểm tra đã nộp chưa"*; **không** tạo sự kiện Calendar cho hạn đã qua.

Bảng xem trước có thêm cột **Calendar** để người dùng thấy sự kiện nào sẽ tạo/dời, và **dòng cuối luôn là**
`↻ xếp lại nhóm` của `admin/tasks-<kỳ>.md` — kể cả khi không có thay đổi nào khác.

### 3. Duyệt → ghi → cập nhật map

Thứ tự **Notion trước, Calendar sau** — mô tả sự kiện cần link trang Notion. Ghi xong mỗi lô
thì lưu `page`, `deadline`, `event` vào `admin/notion-map.json` ngay. Sửa file `tasks-<kỳ>.md`
(kéo trạng thái về, thêm khoá) trong cùng lượt.

**Luôn** chạy `scripts/tasks-overview.py admin/tasks-<kỳ>.md` ở cuối mỗi lượt sync — **kể cả khi file không có
thay đổi nào khác**. *Còn lại* và nhóm *Trễ tiến độ* tính theo ngày chạy, nên chỉ cần qua một ngày là file
cũ đi. Commit nếu file đổi (`admin: xếp lại task` khi chỉ có thứ tự/nhóm đổi).

---

## Chế độ exam-plan

Đã tách thành skill riêng: **`exam-plan`** (`.claude/skills/exam-plan/SKILL.md`). Skill đó đọc lịch,
xếp buổi ôn, in bảng xem trước, rồi **gọi lại** các quy ước ở file này (template trang task, map property,
`notion-map.json`, sự kiện trên `Work`) để ghi.

Khi sync phát hiện lịch thi có ngày cụ thể mà chưa có khoá `<MÃ>/exam-<…>/r<nn>` trong map → **đề xuất
chạy `exam-plan`**, không tự xếp lịch ôn ở đây.

Task ôn là kế hoạch cá nhân: dòng *Loại* `Ôn thi` trong `tasks-<kỳ>.md`, phân biệt với hạn giảng viên (`Hạn nộp`)
bằng cột *Loại*. Sync đối xử như mọi dòng khác: hạn lệch → repo thắng; Notion `Done`/`In progress`
→ kéo trạng thái về cột *Trạng thái* (`✅ xong` / `🔄 đang làm`).

---

## Chế độ add

**Kích hoạt:** người dùng nói thẳng việc cần tạo — *"tạo task HDH xem lại video buổi 6, hạn thứ 7"*.

1. Xác định môn → tiền tố. Không rõ môn → hỏi.
2. Quy đổi hạn sang ngày tuyệt đối, **nói lại**: *"thứ 7 = 2026-09-26"*.
3. **Đây có phải deadline của giảng viên không?** (nộp bài, điểm danh, nộp nhóm…)
   → có: thêm dòng `Hạn nộp` vào nhóm 1 của `tasks-<kỳ>.md` trước (có khoá), xử lý như sync — vào map, có sự kiện Calendar.
   → không (việc tự đặt cho mình): chỉ tạo trên Notion, không vào map; sự kiện Calendar chỉ khi người dùng xin nhắc.
4. In 1 dòng xem trước → duyệt → tạo.

---

## Đồng bộ Google Calendar

Mọi dòng **có ngày tuyệt đối và chưa ✅** trong `tasks-<kỳ>.md` có một sự kiện trên Calendar, tạo
cùng lượt với task Notion, **cùng bảng xem trước**. Dòng hạn `❓` chưa có sự kiện.

| | Hạn nộp / mốc giảng viên | Thi |
|---|---|---|
| **Lịch** | **`Work`** — tra `calendarId` bằng `list_calendars` theo tên, **không dùng lịch chính** | như bên trái |
| Thời gian | Có giờ: sự kiện 30 phút **kết thúc đúng giờ hạn** (21:30 → 21:00–21:30). Chỉ có ngày: sự kiện cả ngày | giờ thi → + thời lượng thi (chưa biết thì 2 giờ) |
| Nhắc | popup trước **1 ngày** + trước **2 giờ** | popup trước **1 ngày** + trước **2 giờ** |
| Tiêu đề | `<TT> Hạn <việc>` — vd `ANTT Hạn Bài tập 8` | `<TT> Thi <mã môn> — ca <n>` |
| Mô tả | việc cần làm · hạn dự phòng nếu có · link task Notion · đường dẫn repo | hình thức, được mang gì, phòng thi `❓` nếu chưa biết · link task Notion |
| `location` | — | nơi thi nếu biết |

Múi giờ `Asia/Ho_Chi_Minh`. Sau lần ghi đầu tiên trong phiên, `get_event` lại để kiểm tra giờ.

- Hạn đổi → `update_event`, không tạo sự kiện mới. Dòng ✅ → giữ sự kiện, không xoá.
- Không có thao tác chuyển sự kiện giữa hai lịch — tạo nhầm lịch thì tạo lại trên `Work` rồi xoá bản cũ
  (`notificationLevel = NONE`).
- Người dùng xin **nhắc thêm** cho việc tự đặt (*"tạo lịch nhắc tôi"*) → mặc định 20:00 (người dùng đi làm
  ban ngày), `list_events` tránh trùng; không vào map.
- Link cá nhân (OneDrive, SharePoint…) chỉ ghi trên Notion/Calendar, **không ghi vào repo**.

---

## Commit và báo lại

Chỉ commit khi file tracked thay đổi (`admin/tasks-<kỳ>.md` — kể cả khi chỉ thứ tự/nhóm đổi —, README môn/bài). `notion-map.json` không bao giờ vào git.

```
<MÃ MÔN>: đồng bộ Notion + Calendar — <n> task mới, <m> đã nộp
admin: đồng bộ Notion + Calendar — …        ← khi nhiều môn
```

Báo lại: bao nhiêu task tạo/sửa/kéo về · bao nhiêu sự kiện tạo/dời · link database Notion ·
những mục `? hỏi` còn treo · deadline trong 7 ngày tới.

---

## Không làm

- ❌ **Không ghi gì lên Notion, Calendar hay repo trước khi người dùng duyệt bảng xem trước.**
- ❌ **Không xoá task Notion** — tối đa chuyển `Archived`, và chỉ khi được duyệt.
- ❌ Không để Notion hay Calendar ghi đè ngày tháng trong repo. Ngày lệch → repo thắng, bên kia được sửa theo.
- ❌ Không tạo sự kiện trên lịch chính hay lịch nào khác ngoài `Work`.
- ❌ Không commit `admin/notion-map.json`, không chép URL Notion hay id sự kiện vào file tracked — repo public.
- ❌ Không gắn 📺 Projects cho task University.
- ❌ Không tự bịa viết tắt môn, không đoán ngày thi, không "làm tròn" deadline.
- ❌ Không hạ Priority mà người dùng đã tự đặt.
- ❌ Không sửa task Notion ngoài map khi chưa được duyệt từng task.
