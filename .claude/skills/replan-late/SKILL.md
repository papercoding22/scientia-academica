---
name: replan-late
description: Xếp lại nhanh các task đang trễ tiến độ (nhóm "3. Trễ tiến độ" trong admin/tasks-<học kỳ>.md) vào khung giờ còn trống trước hạn cuối hoặc ngày thi — đọc lịch Google Calendar, đề xuất lịch mới trong một bảng, sau khi duyệt thì dời cùng lúc hạn trong repo, Deadline trên Notion và sự kiện trên lịch Work. Dùng khi người dùng nói "planning lại việc trễ", "xếp lại các buổi bị lỡ", "dời task trễ hạn", "replan", "lỡ buổi ôn hôm qua", "các việc quá hạn xếp lại giúp". Lập kế hoạch ôn thi từ đầu thì dùng exam-plan.
---

# Xếp lại task trễ tiến độ → repo + Notion + Calendar

Người dùng lỡ vài buổi và muốn **một lịch mới dùng được ngay**, không phải một buổi lập kế hoạch dài.
Skill này là đường tắt của mục *Khi kế hoạch lệch* trong `exam-plan`: chỉ đụng vào task đang trễ,
**dời** task và sự kiện có sẵn — không tạo task mới, không lập lại cả kế hoạch.

```
 tasks-<kỳ>.md nhóm 3 ─┐
 notion-map.json       ├─▶ tìm khung trống ─▶ 1 bảng xem trước ─ OK ─▶ repo ─▶ Notion ─▶ Calendar ─▶ commit
 Google Calendar       ┘   (lùi từ hạn cuối)
```

**Nhanh nghĩa là:** đọc song song mọi nguồn trong một lượt, không hỏi trước khi có đề xuất, chỉ hỏi
đúng một câu duyệt ở bảng xem trước. Những thứ đã biết (id lịch, ca thi, khoá, event id) đọc từ file,
không hỏi lại.

---

## Mục lục

- [Bước 1 — Đọc song song](#bước-1--đọc-song-song)
- [Bước 2 — Phân loại task trễ](#bước-2--phân-loại-task-trễ)
- [Bước 3 — Tìm khung trống và xếp](#bước-3--tìm-khung-trống-và-xếp)
- [Bước 4 — Bảng xem trước](#bước-4--bảng-xem-trước)
- [Bước 5 — Ghi](#bước-5--ghi)
- [Bước 6 — Commit và báo lại](#bước-6--commit-và-báo-lại)
- [Không làm](#không-làm)

---

## Bước 1 — Đọc song song

Gọi **cùng một lượt** (các lệnh độc lập, không chờ nhau):

| Nguồn | Lấy gì |
|---|---|
| `TZ=Asia/Ho_Chi_Minh python3 scripts/tasks-overview.py admin/tasks-<kỳ>.md` rồi đọc nhóm **3. Trễ tiến độ** | Danh sách task trễ — chạy script trước để nhóm tính theo **giờ hiện tại** |
| Các dòng `Thi` trong file | Mốc chặn cuối cho buổi `Ôn thi` (buổi ôn phải xong trước giờ thi của môn đó) |
| `admin/notion-map.json` | `page`, `event` của từng khoá trễ |
| `list_calendars` → `list_events` của **mọi** lịch (`Work`, `UIT Class`, lịch chính, `Gym`, `Life`…) từ **bây giờ** tới mốc chặn xa nhất, `timeZone = Asia/Ho_Chi_Minh` | Giờ đã bận |
| `date` theo `Asia/Ho_Chi_Minh` | Giờ hiện tại — không xếp vào khung đã qua |

Chỉ khi task ôn có chỗ đáng ngờ về tài liệu (vd Ghi chú / mô tả sự kiện cũ nói "chưa có note") mới
`ls` thư mục `lectures/`, `exam-prep/` của môn để cập nhật — không quét thêm.

---

## Bước 2 — Phân loại task trễ

| *Loại* | Được làm gì | Không được |
|---|---|---|
| `Ôn thi` | **Dời** sang khung mới trước giờ thi; có thể **rút ngắn** hoặc đề xuất **bỏ** | Xếp sau giờ thi của môn |
| `Hạn nộp` (hạn giảng viên) | Hỏi *"đã nộp chưa?"* → đã nộp thì chuyển sang `task-status`. Chưa nộp → đề xuất **một buổi làm bù** trên Calendar, ghi `⚠️ trễ hạn` | **Dời *Hạn*** — đó là ngày của giảng viên. Không sửa `Deadline` Notion |
| `Thi` | Không bao giờ trễ (script tự chuyển sang *Đã xong*) | — |

Task `🔄 đang làm` mà trễ → vẫn dời như thường; giữ trạng thái `🔄`.

---

## Bước 3 — Tìm khung trống và xếp

Khung trống = khoảng không trùng sự kiện nào ở mọi lịch, sau **bây giờ**, trước mốc chặn. Khung mặc định
(người dùng đi làm ban ngày) giống `exam-plan`:

| Loại ngày | Khung | Tối đa một buổi |
|---|---|---|
| Ngày thường | Tối, sau lớp (`UIT Class`) + 15 phút, tới 23:00 | 2 giờ |
| Cuối tuần | 09:00–11:30 · 14:00–16:30 · tối 19:30–21:30 (tối chỉ khi thiếu khung — nói rõ) | 2,5 giờ |

Xếp theo thứ tự ưu tiên:

1. **Mốc chặn gần nhất trước** — môn thi sớm hơn được chọn khung trước.
2. **Trọng số cao trước** — lấy từ Notes/Ghi chú hoặc `exam-prep/exam-map.md` (*"Ch7 = 41% đề mẫu"*);
   `⚠️ GỢI Ý THI` có nguồn cũng được ưu tiên.
3. Buổi ôn phải nằm **trước** các buổi phụ thuộc nó (ôn chương → làm đề mẫu → ôn tổng).
4. **Giữ thời lượng cũ** nếu đủ khung; thiếu thì rút ngắn buổi trọng số thấp trước, rồi mới đề xuất bỏ
   buổi mà mô tả ghi *"bỏ được nếu bận"*.
5. Không xếp vào 2 giờ trước giờ thi của bất kỳ môn nào; không học phần mới tối trước ngày thi.
6. Ngày nào tổng giờ ôn > 6 giờ, hoặc một chuỗi liên tục > 3 giờ → **cảnh báo** trong bảng, không tự né bằng cách bỏ buổi.

Không đủ khung → nói thẳng **thiếu bao nhiêu giờ**, đưa phương án bỏ/rút cụ thể. Không nhồi.

---

## Bước 4 — Bảng xem trước

Một bảng duy nhất, rồi **một** câu hỏi duyệt:

| # | Task | Lịch cũ (đã lỡ) | **Lịch mới** | Thời lượng | Lý do xếp |
|---|---|---|---|---|---|
| 1 | HDH: Ôn chương 7 (🔄) | T7 26/9 09:00–11:30 | **CN 27/9 09:00–11:30** | 2,5 giờ | 41% đề mẫu, xếp sớm nhất |

Dưới bảng, chỉ những gì người dùng cần để quyết:

- Ngày quá tải / chuỗi dài (quy tắc 6), khung ngoài mặc định đã dùng.
- Số giờ bị thiếu và buổi đề xuất rút/bỏ.
- Task `Hạn nộp` trễ: câu hỏi *đã nộp chưa* + buổi làm bù đề xuất.
- *OK?* — người dùng có thể đổi giờ, bỏ một buổi, tráo hai buổi.

Chưa có *OK* thì **chưa ghi gì**.

---

## Bước 5 — Ghi

Sau *OK*, theo thứ tự **repo → Notion → Calendar** (đứt giữa chừng thì repo vẫn đúng, `notion-tasks`
sync lần sau sửa nốt). Các lệnh Notion chạy song song với nhau; các lệnh Calendar cũng vậy.

1. **Repo** — sửa ô *Hạn* của từng dòng `Ôn thi` = **giờ kết thúc** buổi mới (không đụng cột khác;
   `Hạn nộp` trễ thì chỉ đổi *Trạng thái* sang `⚠️ trễ hạn`). Chạy
   `TZ=Asia/Ho_Chi_Minh python3 scripts/tasks-overview.py admin/tasks-<kỳ>.md` — nhóm 3 phải trống
   (trừ `Hạn nộp` chưa nộp).
2. **Notion** — `notion-update-page` (`update_properties`) mỗi trang trong map:
   `date:Deadline:start` = giờ kết thúc dạng `…+07:00`, `is_datetime` = 1. Không đụng Status, Priority,
   nội dung. Rút ngắn/dời → thêm một dòng vào bảng **Nhật ký** của trang nếu người dùng muốn giữ vết.
3. **Calendar** — `update_event` trên lịch `Work` theo `event` trong map: `startTime`, `endTime`,
   `notificationLevel = NONE`, giữ nhắc cũ. Mô tả: thêm đầu dòng *"Dời từ <ngày cũ>"* (+ *"rút còn N giờ"*),
   cập nhật tài liệu nếu bước 1 phát hiện mới. Sự kiện không có trong map → `list_events` tìm theo tiêu đề;
   không thấy thì tạo mới theo quy ước của `notion-tasks` và lưu id vào map.
   Buổi làm bù cho `Hạn nộp` → sự kiện mới trên `Work`, không vào map.
4. **`admin/notion-map.json`** — cập nhật `deadline` (và `event` nếu mới) cho mỗi khoá đã dời.
5. **Kiểm tra** — một `notion-query-data-sources` lấy lại Deadline các trang vừa sửa (UTC phải khớp giờ
   Việt Nam − 7); kết quả `update_event` phải trả đúng `start`/`end`.

Buổi bị **bỏ** (người dùng đồng ý): Notion `Archived`, xoá sự kiện Calendar, dòng trong repo đổi
*Trạng thái* thành `✅ bỏ` và *Ghi chú* `bỏ <ngày> — không đủ khung`, để script chuyển sang *Đã xong*.

---

## Bước 6 — Commit và báo lại

Commit ngay, không hỏi (`AGENTS.md` § 11):

```
<MÃ MÔN>: dời <n> buổi ôn trễ tiến độ
<MÃ>, <MÃ>: dời <n> buổi ôn trễ tiến độ      ← nhiều môn
```

`notion-map.json` không bao giờ vào git.

Báo lại ngắn: bảng lịch mới · đã kiểm tra khớp ba nơi · ngày nặng nhất và buổi dễ bỏ nhất nếu lại quá tải ·
kỳ thi / deadline trong 7 ngày tới.

---

## Không làm

- ❌ **Không ghi repo, Notion hay Calendar trước khi người dùng OK bảng xem trước.**
- ❌ **Không dời *Hạn* của dòng `Hạn nộp`** — hạn giảng viên là cố định; chỉ xếp buổi làm bù.
- ❌ Không xếp buổi ôn sau giờ thi của môn, vào giờ học `UIT Class`, hay chồng lên sự kiện có sẵn.
- ❌ Không tạo task Notion mới cho buổi dời — dời task cũ. Không xoá task Notion (tối đa `Archived`, khi được duyệt).
- ❌ Không ghi sự kiện lên lịch nào khác ngoài `Work`.
- ❌ Không đổi Status/Priority khi dời — dời là đổi giờ, không phải đổi tiến độ.
- ❌ Không lập lại cả kế hoạch ôn thi — việc đó là của `exam-plan`.
