---
name: task-status
description: Cập nhật trạng thái một hoặc vài task (bài tập, lab, đồ án, mốc giảng viên, buổi ôn thi) theo lời người dùng — ghi vào admin/tasks-<học kỳ>.md và README liên quan, rồi đẩy Status/Completion Date lên Notion ☕ Tasks. Dùng khi người dùng nói "đã nộp bài tập 8 IE105", "xong buổi ôn chương 7", "đang làm lab 4", "đánh dấu … là done", "cập nhật trạng thái task", "bài 3A được 9 điểm". Đồng bộ toàn bộ hai chiều hoặc tạo task mới thì dùng notion-tasks.
---

# Cập nhật trạng thái task → repo + Notion

Người dùng vừa làm xong (hoặc bắt đầu) một việc và **nói ra**. Skill này ghi đúng một thay đổi đó
vào mọi chỗ đang giữ trạng thái, theo thứ tự **repo trước, Notion sau** — giống mọi đồng bộ khác
trong repo (`AGENTS.md` § 10).

```
 "đã nộp bài tập 8 IE105"
          │
          ▼
 tìm dòng trong admin/tasks-<kỳ>.md ──▶ khoá IE105/a8 ──▶ notion-map.json ──▶ trang Notion
          │                                                                     │
          ▼                                                                     ▼
 xem trước: repo cũ → mới · Notion cũ → mới ── OK ──▶ ghi repo ──▶ ghi Notion ──▶ commit
```

Khác `notion-tasks`: skill đó **quét toàn bộ** hai bên để tìm lệch. Skill này chỉ đụng vào
**task người dùng vừa nhắc tới**, nhanh, không quét.

---

## Mục lục

- [Bước 1 — Xác định task](#bước-1--xác-định-task)
- [Bước 2 — Xác định trạng thái mới](#bước-2--xác-định-trạng-thái-mới)
- [Bước 3 — Đọc trạng thái hiện tại](#bước-3--đọc-trạng-thái-hiện-tại)
- [Bước 4 — Xem trước và duyệt](#bước-4--xem-trước-và-duyệt)
- [Bước 5 — Ghi](#bước-5--ghi)
- [Bước 6 — Commit và báo lại](#bước-6--commit-và-báo-lại)
- [Không làm](#không-làm)

---

## Bước 1 — Xác định task

1. **Học kỳ:** mặc định học kỳ đang học (`AGENTS.md` § 1) → `admin/tasks-<kỳ>.md`.
2. **Môn:** mã môn hoặc viết tắt Notion (`ANTT` = IE105, `HDH` = IT007, `CSHT` = IE101, `QLTT` = IE103 —
   bảng đầy đủ ở skill `notion-tasks`). Không rõ môn → hỏi.
3. **Dòng:** tìm trong mục `## <MÃ MÔN> — …` của file, ở cả ba bảng:

   | Người dùng nói | Bảng | Khoá |
   |---|---|---|
   | *bài tập 8*, *bài 3A* | *Việc và hạn nộp* | `<MÃ>/a8`, `<MÃ>/a3a` |
   | *lab 4*, *bài thực hành 4* | *Việc và hạn nộp* | `<MÃ>/lab4` |
   | *đồ án 1*, *nộp đồ án*, *mốc thuyết trình* | *Việc và hạn nộp* | `<MÃ>/prj1`, `<MÃ>/prj1/<mốc>` |
   | *buổi ôn chương 7*, *làm đề mẫu*, *ôn tổng* | *Kế hoạch ôn thi* | `<MÃ>/exam-<…>/r<nn>` — khớp theo tên buổi ôn |

   - Khớp đúng một dòng → dùng. Khớp nhiều dòng hoặc không chắc → **hỏi**, liệt kê các dòng ứng viên.
   - **Không có dòng nào** → việc này repo chưa theo dõi. Dừng và đề xuất: hạn giảng viên → `new-assignment`
     / `new-project`; việc tự đặt chỉ có trên Notion → cập nhật được trên Notion, nhưng chỉ khi người dùng
     chỉ rõ đúng task đó (luật 5 của `notion-tasks`).
4. **Trang Notion:** tra khoá trong `admin/notion-map.json`. Không có khoá → task chưa lên Notion:
   chỉ cập nhật repo và nói rõ; gợi ý chạy `notion-tasks` nếu muốn đưa lên.

Nhiều task trong một câu (*"xong ôn chương 7 và chương 8 HDH"*) → xử lý chung một lượt, một bảng xem trước.

---

## Bước 2 — Xác định trạng thái mới

| Người dùng nói | Repo — cột *Trạng thái* | Notion `Status` | Ghi thêm |
|---|---|---|---|
| *bắt đầu làm*, *đang làm* | `🔄 đang làm` | `In progress` | — |
| *đã nộp*, *xong*, *done* — bài nộp | `✅ đã nộp` | `Done` | *Ngày nộp* + `Completion Date` |
| *xong* — buổi ôn | `✅ xong` | `Done` | `Completion Date` |
| *chưa làm*, *làm lại*, *đánh dấu nhầm* | `⬜ chưa làm` | `To Do` | xoá *Ngày nộp* đã ghi |
| *nộp trễ* | `⚠️ trễ hạn` → khi đã nộp thì `✅ đã nộp` kèm *(trễ)* ở *Ngày nộp* | `Done` | — |
| *được 9 điểm* | giữ nguyên | giữ nguyên | cột *Điểm* + `Điểm` trong `aN/README.md`, ghi *(người dùng, <ngày>)* |

**Ngày nộp** — tuyệt đối. Không nói ngày → hôm nay (`Asia/Ho_Chi_Minh`), và **nói lại ngày đó** trong
bảng xem trước. *"hôm qua"*, *"tối thứ 6"* → quy đổi, nói lại. Nói *"đã nộp"* mà không chắc ngày nào → hỏi,
không đoán (`AGENTS.md` § 12: không làm tròn deadline).

**Ngày nộp muộn hơn hạn** → báo cho người dùng; hỏi có ghi *(trễ)* không. Không tự kết luận trễ khi hạn
có dự phòng (IE105: hết ngày hôm sau).

*"bỏ"*, *"không làm nữa"*, *"xoá task"* **không phải** đổi trạng thái — đó là bỏ theo dõi, dùng `notion-tasks`
(chuyển `Archived` cần duyệt riêng).

---

## Bước 3 — Đọc trạng thái hiện tại

- **Repo:** dòng trong `tasks-<kỳ>.md`; với bài nộp đọc thêm dòng *Trạng thái* của `aN/README.md` (hoặc
  `labN/`, `projects/prjN/`) và dòng tương ứng ở bảng **Bài tập và đồ án** của `<môn>/README.md`.
- **Notion:** `notion-fetch` trang trong map — lấy `Status`, `Completion Date`, tên task. Lần đầu trong phiên,
  `notion-fetch` data source để lấy tên option `Status` thật (có thể đã đổi).

| Tình huống | Xử lý |
|---|---|
| Repo và Notion **đã** đúng trạng thái mới | Báo *"đã là ✅ rồi"*, không ghi gì |
| Notion `Done` sẵn, repo chưa ✅ | Bình thường — chỉ kéo về repo, lấy `Completion Date` làm *Ngày nộp* nếu người dùng không nói ngày |
| Repo ✅ mà người dùng nói *đang làm* | `? hỏi` — có thể đánh dấu nhầm trước đó, hoặc đang làm lại |
| Trang Notion trong map đã bị xoá / không mở được | Cập nhật repo, báo lại; gợi ý `notion-tasks` để xử lý map |

---

## Bước 4 — Xem trước và duyệt

**Bắt buộc**, kể cả khi chỉ có một task:

| # | Task | Khoá | Repo | Notion | File khác |
|---|---|---|---|---|---|
| 1 | ANTT: Bài tập 8 | `IE105/a8` | `⬜` → `✅ đã nộp`, nộp **2026-09-27** | `To Do` → `Done`, Completion 2026-09-27 | `a8/README.md` · `IE105/README.md` |

Kèm câu hỏi duyệt ngắn: *OK?* Người dùng có thể sửa ngày hoặc bỏ một dòng (*"OK trừ 2"*).
Chưa có *OK* thì **chưa ghi gì** — cả repo lẫn Notion.

---

## Bước 5 — Ghi

Thứ tự **repo trước, Notion sau** — đứt giữa chừng thì repo vẫn đúng, lần sync sau tự sửa Notion.

**1. Repo**

| File | Sửa |
|---|---|
| `admin/tasks-<kỳ>.md` | Cột *Trạng thái* (+ *Ngày nộp*, *Điểm*) của đúng dòng. **Không xoá dòng**, không chuyển bảng |
| `assignments/<aN\|labN>/README.md` · `projects/prjN/README.md` | Dòng *Trạng thái* (+ *Điểm*) ở bảng đầu file |
| `<môn>/README.md` | Cột trạng thái ở bảng **Bài tập và đồ án** |

Buổi ôn chỉ sửa `tasks-<kỳ>.md` — không có README riêng.

**2. Notion** — `notion-update-page` trên trang trong map:

- `Status` theo bảng ở bước 2.
- `Done` → `date:Completion Date:start` = ngày nộp (date, không giờ). `To Do` do đánh dấu nhầm → xoá `Completion Date`.
- Không đụng `Deadline`, `Priority`, nội dung trang. Muốn ghi chú (*"nộp trễ vì…"*) → thêm dòng vào bảng
  **Nhật ký** của trang, **không** xoá chữ cũ của người dùng.
- Ghi xong `notion-fetch` lại một trang để chắc `Status` đã đổi.

**3. Google Calendar** — không làm gì. Sự kiện của task đã xong được **giữ lại** làm lịch sử (`notion-tasks`).

`admin/notion-map.json` không đổi — trạng thái không lưu trong map.

---

## Bước 6 — Commit và báo lại

Commit ngay, không hỏi (`AGENTS.md` § 11):

```
<MÃ MÔN>: <việc> → ✅ đã nộp
<MÃ MÔN>: ôn chương 7, 8 → ✅ xong
admin: cập nhật trạng thái <n> task      ← khi nhiều môn
```

Báo lại một đoạn ngắn: task nào đổi gì · Notion đã cập nhật chưa (hoặc vì sao không) ·
việc tiếp theo gần nhất của môn đó trong `tasks-<kỳ>.md` · deadline trong 7 ngày tới.

---

## Không làm

- ❌ **Không ghi repo hay Notion trước khi người dùng duyệt bảng xem trước.**
- ❌ Không đánh dấu `✅ đã nộp` chỉ vì thấy file làm bài trong repo — **phải có lời người dùng**.
- ❌ Không đoán ngày nộp, không đoán điểm. Không rõ → hỏi.
- ❌ Không sửa hạn nộp, ngày thi, Priority hay Deadline ở skill này — đổi ngày là việc của file tasks + `notion-tasks`.
- ❌ Không xoá dòng khỏi `tasks-<kỳ>.md`, không xoá task Notion, không xoá sự kiện Calendar.
- ❌ Không để Notion quyết ngày tháng: *Ngày nộp* lấy từ lời người dùng trước, `Completion Date` chỉ là phương án khi người dùng không nói.
- ❌ Không chép URL Notion vào file tracked — repo public.
