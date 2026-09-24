---
name: new-project
description: Tạo đầy đủ một đồ án môn học mới — chạy script dựng projects/prjN/ (brief, docs, src, images), trích đề bài, tiêu chí chấm và các mốc từ transcript/materials, ghi hạn nộp vào admin/deadlines.md, cập nhật bảng bài tập của môn, rồi đề xuất task Notion cho từng mốc. Dùng khi người dùng nói "tạo đồ án N", "có đồ án mới", "thầy giao đồ án", "new project", "init project", "đồ án nhóm môn X", hoặc đưa đề đồ án chưa có thư mục trong repo.
---

# Tạo đồ án môn học mới

Đồ án khác bài tập ở ba chỗ: **kéo dài nhiều tuần**, **có nhiều mốc**, và **hay làm nhóm**.
Script dựng khung; skill lo phần đọc hiểu — đề bài, tiêu chí chấm, mốc thời gian —
và nối đồ án vào những nơi đang theo dõi nó.

---

## Mục lục

- [Bước 1 — Thu thập](#bước-1--thu-thập)
- [Bước 2 — Chạy script](#bước-2--chạy-script)
- [Bước 3 — Trích đề bài, tiêu chí chấm, mốc](#bước-3--trích-đề-bài-tiêu-chí-chấm-mốc)
- [Bước 4 — Nối vào repo](#bước-4--nối-vào-repo)
- [Bước 5 — Task Notion](#bước-5--task-notion)
- [Bước 6 — Commit và báo lại](#bước-6--commit-và-báo-lại)
- [Không làm](#không-làm)

---

## Bước 1 — Thu thập

| Cần | Nếu thiếu |
|---|---|
| Mã môn | **Hỏi.** |
| Số đồ án giảng viên đặt | Môn chỉ có một đồ án → `1`. Nhiều hơn → **hỏi**, không suy từ thư mục đang có |
| Tên đề tài | Tìm trong transcript/brief (bước 3); đề tài nhóm tự chọn thì hỏi |
| Hạn nộp cuối | Tìm trong transcript, `IMPORTANT_NOTES.md`, đề cương trước khi hỏi |
| Nhóm hay cá nhân | Tìm trong transcript; không có thì hỏi |
| Mẫu tên file nộp | Tra `IMPORTANT_NOTES.md` mục 4 và `AGENTS.md` § 13.3. **Không có → để `❓`** |

Kiểm tra trước: `projects/prjN/` đã tồn tại chưa, và **Notion đã có task đồ án của môn này chưa**
(người dùng hay tạo tay trước, ví dụ *"CSHT: Đọc Tài Liệu Đồ Án…"*) — có thì bước 5 phải
liên kết, không tạo trùng.

---

## Bước 2 — Chạy script

```bash
scripts/new-project.sh --course IE101 --num 1 --team \
    --title "Thiết kế hạ tầng mạng cho doanh nghiệp vừa" --due 2026-11-15 --lecture L03

# Đã biết mẫu tên file nộp .docx → copy sẵn template Word vào docs/
scripts/new-project.sh --course IE101 --num 1 --team --submission "<tên giảng viên quy định>.docx"
```

Tạo `projects/prjN/` với `README.md`, `brief/`, `docs/`, `src/`, `images/`.
**Script không suy mẫu tên file nộp** — đồ án nộp ít, mẫu hay khác bài tập (zip, báo cáo + slide,
link repo). Chưa có nguồn thì để `❓ chưa xác nhận`.

Chạy `--dry-run` trước nếu không chắc.

---

## Bước 3 — Trích đề bài, tiêu chí chấm, mốc

Giảng viên thường giao đồ án bằng lời trong một buổi, rồi nhắc rải rác các buổi sau.
**Quét mọi transcript của môn**, không chỉ buổi giao:

```bash
grep -niE 'đồ án|project|đề tài|nhóm|thuyết trình|demo|báo cáo cuối|nộp|deadline|hạn|chấm|tiêu chí|thang điểm' \
  semesters/<kỳ>/<môn>/lectures/_raw/*.md
```

Đọc thêm: `materials/syllabus/` (đồ án chiếm bao nhiêu %), `brief/` nếu người dùng đã thả đề vào,
`IMPORTANT_NOTES.md` mục 1/4. File `.docx`/`.pdf` → `scripts/peek.py`.

Điền vào `prjN/README.md`, **mỗi ý kèm nguồn** (`> *Nguồn: buổi 3, 2026-08-05*`):

| Mục README | Lấy gì |
|---|---|
| **Đề bài** | Yêu cầu, phạm vi, sản phẩm phải nộp (báo cáo, slide, code, demo) |
| **Tiêu chí chấm** | Giảng viên chấm dựa vào đâu, điểm từng phần, điều bị trừ điểm |
| **Tỷ trọng điểm** | Từ đề cương / lời giảng viên |
| **Mốc thời gian** | Mọi ngày giảng viên nêu — chốt đề tài, báo cáo giữa kỳ, thuyết trình, nộp. Cột *Do ai đặt* = `giảng viên` |

Ngày tương đối → quy đổi theo ngày buổi học (`AGENTS.md` § 10). Không đủ để quy đổi → hỏi.
**Không tìm thấy → để `❓` và nói rõ, không bịa đề bài hay tiêu chí.**

Người dùng muốn thêm mốc nội bộ (nhóm tự chia) → thêm dòng với *Do ai đặt* = `nhóm`/`tự đặt`.

---

## Bước 4 — Nối vào repo

| File | Thêm gì |
|---|---|
| `admin/deadlines.md` | Bảng **Sắp tới**: hạn nộp cuối **và mọi mốc giảng viên đặt** (mỗi mốc một dòng: `Đồ án 1 — thuyết trình`) · link `projects/prjN/` · nguồn |
| `<môn>/README.md` | Bảng **Bài tập và đồ án**: link `projects/prjN/` · tên · buổi giao · hạn · trạng thái |
| `<môn>/IMPORTANT_NOTES.md` | Tỷ trọng, tiêu chí chấm, hình thức nộp — **chỉ khi có nguồn**, append theo luật § 8 |

Mốc do nhóm tự đặt **không** vào `deadlines.md` — file đó chỉ giữ hạn của giảng viên.

Buổi học gợi ra hướng hay cho khoá luận → đề xuất tạo `program/thesis/ideas/<slug>.md` (`AGENTS.md` § 5 bước 8).

---

## Bước 5 — Task Notion

Chạy skill **`notion-tasks`** cho đồ án vừa tạo. Tên task: `<TT>: Đồ án N — <mốc>`,
`Topic` = `Project Task`, không gắn 📺 Projects.

| Mốc | Vào Notion bằng |
|---|---|
| Mốc giảng viên đặt (có trong `deadlines.md`) | chế độ **sync** — có khoá `<MÃ>/prjN` hoặc `<MÃ>/prjN/<mốc>` trong map |
| Mốc nhóm / tự đặt | chế độ **add** — task lẻ, không vào map |

Task đồ án người dùng đã tạo tay trên Notion (bước 1) → đề xuất **đưa vào map** thay vì tạo mới.
Như mọi lần: in bảng xem trước, chờ duyệt.

---

## Bước 6 — Commit và báo lại

```
<MÃ MÔN>: tạo đồ án <N> — <tên đề tài>
```

Báo lại: đã tạo gì · **đề bài và tiêu chí lấy được từ đâu** (buổi nào) hay còn `❓` ·
các mốc đã ghi · file nộp · task Notion đã tạo · deadline trong 7 ngày tới.

Nhắc người dùng: bỏ đề gốc vào `brief/`, viết mục **Kiến trúc / cách làm** trước khi nhờ AI
review — ranh giới hỗ trợ ở `AGENTS.md` § 6 áp dụng cho đồ án y như bài tập.

---

## Không làm

- ❌ **Không đoán mẫu tên file nộp.** Mẫu do giảng viên quy định (`AGENTS.md` § 13.3).
- ❌ **Không bịa đề bài, tiêu chí chấm, tỷ trọng.** Không có nguồn → `❓`.
- ❌ **Không ghi MSSV, email, số điện thoại của đồng đội** — repo public. Chỉ tên, và chỉ khi người dùng đưa.
- ❌ Không điền sẵn tên và MSSV vào trang bìa `.docx`.
- ❌ Không để mốc nhóm tự đặt lọt vào `admin/deadlines.md`.
- ❌ Không viết hộ đồ án. Review, chỉ lỗi, so sánh cách làm — được; viết thay — không (`AGENTS.md` § 6).
- ❌ Không tạo task Notion trùng với task người dùng đã tạo tay.
