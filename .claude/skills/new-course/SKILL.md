---
name: new-course
description: Tạo đầy đủ một môn học mới trong repo — chạy script scaffold rồi nối môn đó vào 6 file khác đang giữ danh sách môn (README học kỳ, schedule, deadlines, curriculum, transcript, specialization). Dùng khi người dùng nói "thêm môn", "tạo môn mới", "init môn", "đăng ký thêm môn", hoặc đưa mã môn + tên môn + giảng viên của một môn chưa có trong repo. Cũng dùng khi bắt đầu học kỳ mới và cần tạo nhiều môn một lượt.
---

# Tạo môn học mới

Việc này có hai nửa. **Script làm nửa cơ học, bạn làm nửa cần phán đoán.**
Nửa thứ hai mới là chỗ dễ quên, vì một môn học không chỉ là cái thư mục —
nó được nhắc tới ở **6 file khác** trong repo.

---

## Bước 1 — Thu thập thông tin

Cần đủ 4 thứ trước khi chạy script:

| Cần | Ví dụ | Nếu thiếu |
|---|---|---|
| Mã môn | `IT007` | **Hỏi.** Không đoán. |
| Tên tiếng Việt | Hệ điều hành | **Hỏi.** Không đoán. |
| Giảng viên | Nguyễn Thanh Thiện | **Hỏi.** Không đoán. |
| Mã lớp đầy đủ | `IT007.F31.CN1.CNTT` | Bỏ qua — script tự ghép `<CODE>.F31.CN1.CNTT` |

Người dùng thường đưa cả cụm sẵn, dạng:
`IT007.F31.CN1.CNTT - Hệ điều hành - Nguyễn Thanh Thiện` → tách ra là đủ.

Nếu người dùng đưa **nhiều môn một lúc**, làm tuần tự từng môn cho hết bước 2,
rồi gộp bước 3–4 lại làm một lần cho cả nhóm, và commit một lần.

---

## Bước 2 — Dịch tên môn sang slug tiếng Anh

Đây là phần script **không làm được** và cũng là lỗi dễ mắc nhất.

Slug phải là **tiếng Anh thật**, không phải tiếng Việt bỏ dấu:

| Tên tiếng Việt | ✅ Đúng | ❌ Sai |
|---|---|---|
| Hệ điều hành | `operating-systems` | `he-dieu-hanh` |
| Cơ sở hạ tầng Công nghệ thông tin | `it-infrastructure` | `co-so-ha-tang-cntt` |
| Quản lý thông tin | `information-management` | `quan-ly-thong-tin` |
| Nhập môn bảo đảm và an ninh thông tin | `information-assurance-security` | `nhap-mon-an-ninh` |
| Cấu trúc dữ liệu và giải thuật | `data-structures-algorithms` | `cau-truc-du-lieu` |
| Xác suất thống kê | `probability-statistics` | `xac-suat-thong-ke` |

Nguyên tắc:
- Dùng **tên tiếng Anh chuẩn học thuật** của môn đó, không dịch từng chữ.
- Bỏ được chữ "Nhập môn" / "Introduction to" thì bỏ, cho ngắn.
- Giữ dưới ~30 ký tự. Dài quá thì cắt phần phụ, giữ phần lõi.
- Script có cảnh báo heuristic nhưng **không bắt được hết** — trách nhiệm là ở bạn.

---

## Bước 3 — Chạy script

```bash
scripts/new-course.sh \
  --code IT008 \
  --slug computer-networks \
  --name "Mạng máy tính" \
  --lecturer "Trần Văn A" \
  --class-code "IT008.F31.CN1.CNTT"
```

Thêm `--semester 2025-2026-S3` nếu không phải học kỳ mới nhất.
Chạy `--dry-run` trước nếu không chắc.

Script sẽ tạo 11 thư mục + 6 file, và **từ chối ghi đè** nếu môn đã tồn tại.

---

## Bước 4 — Viết "Môn này nói về cái gì"

Trong `<môn>/README.md`, mục này script để trống. Viết 2–3 câu:

1. **Môn dạy gì** — nội dung lõi, dựa trên tên môn và mã môn.
2. **Chạm vào môn nào khác trong học kỳ** — đây là phần có giá trị nhất.
   Đọc `semesters/<kỳ>/README.md` xem các môn còn lại, tìm chỗ chúng gặp nhau.
3. Với người dùng — **một dev đang đi làm** — nếu môn này giải thích thứ họ dùng
   hàng ngày mà chưa hiểu gốc, nói ra. Đó là lý do môn đó đáng học.

Luôn kèm câu: *"Viết lúc khởi tạo, dựa trên tên môn. Sửa lại sau buổi học đầu tiên."*
Đây là phán đoán, không phải sự thật — phải nói rõ.

---

## Bước 5 — Nối vào 6 file đang giữ danh sách môn

**Đây là lý do skill này tồn tại.** Quên bước này thì repo mất đồng bộ,
và người dùng chỉ phát hiện ra lúc cần tra cứu gấp.

| File | Sửa gì |
|---|---|
| `semesters/<kỳ>/README.md` | Thêm dòng vào **bảng môn** + **bảng tiến độ**; cập nhật số môn ở đầu file; viết thêm vào mục **"học kỳ này gắn với nhau thế nào"** |
| `admin/schedule.md` | Thêm dòng vào bảng **"các môn học kỳ này"**; thêm dòng trống vào **lịch tuần** với `❓` |
| `admin/deadlines.md` | Thêm 2 dòng vào **lịch thi** (giữa kỳ + cuối kỳ) với `❓` |
| `program/curriculum.md` | Thêm dòng vào khối phù hợp, trạng thái `🔄 đang học`, kỳ dự kiến = học kỳ này |
| `program/transcript.md` | Thêm dòng vào mục học kỳ hiện tại, điểm `🔄` |
| `program/specialization/README.md` | Thêm dòng vào bảng **"cảm nhận từng môn"**, trạng thái `🔄 đang học` |

Số tín chỉ để `❓` — **không đoán**. Đó là dữ liệu từ nhà trường (`AGENTS.md` § 9).

Nếu học kỳ đang tạo **chưa tồn tại**, tạo `semesters/<kỳ>/README.md` trước,
theo mẫu của học kỳ hiện có.

---

## Bước 6 — Commit

```
<MÃ MÔN>: thêm môn <tên tiếng Việt>
```

Nhiều môn một lúc thì gộp: `feat: thêm N môn cho học kỳ <kỳ>`

Theo `AGENTS.md` § 11 — commit tự động, không hỏi. Không `push`.

---

## Bước 7 — Báo lại

Nói ngắn gọn:
- Đã tạo thư mục nào
- Đã cập nhật 6 file nào
- **Những gì còn `❓`**: số tín chỉ, lịch học Teams, cách tính điểm
- Việc tiếp theo đáng làm nhất: bỏ **đề cương** vào `materials/syllabus/` rồi bảo AI đọc —
  nó thường chứa sẵn cách tính điểm và quy định môn học, tức mục 1 và 4 của `IMPORTANT_NOTES.md`

---

## Không làm

- ❌ Không đoán **số tín chỉ**, **môn tiên quyết**, **lịch học** — để `❓`, hỏi người dùng.
- ❌ Không đặt slug bằng tiếng Việt bỏ dấu.
- ❌ Không tự sửa file trong `materials/` hay `lectures/_raw/` của môn khác.
- ❌ Không xoá môn cũ khi thêm môn mới, kể cả khi trông như bị thay thế — hỏi trước.
