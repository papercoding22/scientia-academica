---
name: new-assignment
description: Tạo đầy đủ một mục nộp mới — chạy script dựng aN/, labN/ hoặc <prefix>N/, chỉ copy file Word khi suy ra đúng mẫu tên cùng loại, rồi trích đề bài từ transcript buổi học, ghi hạn nộp vào admin/deadlines.md và cập nhật bảng bài tập của môn. Dùng khi người dùng nói "tạo bài tập N", "tạo lab N", "có bài tập mới", "thầy giao bài", "init assignment", hoặc đưa đề bài chưa có thư mục trong repo.
---

# Tạo bài tập hoặc lab mới

Script dựng khung và copy sẵn file nộp. Bạn lo phần cần đọc hiểu: **đề bài nằm ở đâu**,
và **nối bài tập vào hai bảng** đang theo dõi nó.

---

## Mục lục

- [Bước 1 — Thu thập](#bước-1--thu-thập)
- [Bước 2 — Chạy script](#bước-2--chạy-script)
- [Bước 3 — Trích đề bài từ transcript](#bước-3--trích-đề-bài-từ-transcript)
- [Bước 4 — Nối vào hai bảng](#bước-4--nối-vào-hai-bảng)
- [Bước 5 — Commit và báo lại](#bước-5--commit-và-báo-lại)
- [Không làm](#không-làm)

---

## Bước 1 — Thu thập

| Cần | Nếu thiếu |
|---|---|
| Mã môn | **Hỏi.** |
| Loại + số giảng viên đặt (`Bài tập 8`, `Lab 3`, `Quiz 2A`) | **Hỏi.** Không suy từ số thư mục đang có — số bài hay nhảy cóc |
| Tên bài | Bỏ trống được, điền sau ở bước 3 |
| Hạn nộp | Tìm trong transcript trước khi hỏi (xem bước 3) |
| Buổi học liên quan | Suy từ ngày giao bài |

> ⚠️ **Tên thư mục bám theo loại và số giảng viên đặt, không phải thứ tự thư mục.**
> IE105 đánh theo số **chương** (Bài 3 có phần A và B → `a3a`, `a3b`), và đang thiếu
> bài 1, 2, 5. Bài tiếp theo chưa chắc là số lớn nhất + 1.

---

## Bước 2 — Chạy script

```bash
scripts/new-assignment.sh --course IE105 --num 8 \
    --title "Bảo mật ứng dụng web" --due 2026-09-25 --lecture L08

# Lab dùng tiền tố lab, không ép thành a3.
scripts/new-assignment.sh --course IE105 --prefix lab --num 3 \
    --title "Dò tìm mật khẩu bằng tấn công chủ động" \
    --due 2026-09-02 --lecture L07 --no-doc
```

Script tạo `<prefix>N/` với `README.md`, `brief/`, `resources/`, `images/`. Tiền tố mặc định
là `a`; lab dùng `--prefix lab`. Các tiền tố khác phải có nguồn từ giảng viên và chỉ dùng chữ
thường, số, gạch nối.

**Mẫu tên file nộp được SUY RA từ bài đã nộp cùng loại trong cùng môn** — script không hardcode,
nó bắt chước đúng file có cùng tiền tố trước đó. Chưa có bài cùng loại thì script cảnh báo và bỏ qua
bước copy; lúc đó tra mẫu ở `IMPORTANT_NOTES.md` mục 4 của môn rồi chạy lại
với `--submission "<tên đầy đủ>"`.

Chạy `--dry-run` trước nếu không chắc — nó in cả tên file nộp suy ra được để kiểm tra.

---

## Bước 3 — Trích đề bài từ transcript

**Đây là phần có giá trị nhất, và hay bị bỏ qua.**

Giảng viên đọc đề bài trong buổi học, nên đề thường **đã nằm sẵn** trong
`lectures/_raw/`. Tìm nó thay vì bắt người dùng gõ lại:

```bash
grep -niE 'bài tập|câu 1|câu số 1|câu 2|đặt tên file|nộp|deadline|hạn' \
  semesters/<kỳ>/<môn>/lectures/_raw/L<nn>-*.md
```

File `.docx` thì dùng `scripts/peek.py <file>` trước để lấy text.

Tìm được thì điền vào mục **Yêu cầu đề bài** của `<prefix>N/README.md`, **kèm nguồn**:

```markdown
1. **Câu 1:** Lập bảng trình bày các kỹ thuật thăm dò — khoảng 6–7 kỹ thuật.
2. **Câu 2:** Nêu 7–8 biện pháp phòng chống, **xếp theo thứ tự ưu tiên** và giải thích lý do.

> *Nguồn: buổi 5, 2026-08-12*
```

**Bắt luôn hạn nộp và yêu cầu về định dạng** trong cùng đoạn đó — giảng viên thường
nói liền một mạch: đề bài → cách đặt tên file → hạn nộp.

Không tìm thấy trong transcript → để `❓ chưa điền` và nói cho người dùng biết,
**đừng bịa đề bài**.

---

## Bước 4 — Nối vào hai bảng

Tạo thư mục xong mà không làm bước này thì bài tập vô hình với phần còn lại của repo.

| File | Thêm gì |
|---|---|
| `admin/deadlines.md` | Dòng vào bảng **Sắp tới**: môn · việc · hạn (**ngày tuyệt đối**) · trạng thái ⬜ |
| `<môn>/README.md` | Dòng vào bảng **Bài tập và đồ án**: link đúng (`aN/`, `labN/`…) · tên · buổi · hạn · trạng thái |

Hạn nộp chỉ biết dạng tương đối (*"tuần sau"*) → quy đổi bằng ngày buổi học rồi ghi
ngày tuyệt đối. Không đủ thông tin quy đổi thì hỏi, **không đoán** (`AGENTS.md` § 10).

Môn có quy tắc nộp lặp lại (IE105: **21:30 cùng ngày học**, dự phòng hết hôm sau) →
áp dụng luôn, đã ghi ở `admin/deadlines.md` mục *Quy tắc lặp lại*.

---

## Bước 5 — Commit và báo lại

```
<MÃ MÔN>: tạo <loại> <N> — <tên bài>
```

Báo lại: đã tạo gì · **đề bài lấy được từ đâu** (transcript buổi nào, hay chưa có) ·
hạn nộp · **file nộp đã copy sẵn tên gì** · chỗ nào còn `❓`.

Khi đã có file `.docx`, nhắc người dùng mở file trong `<prefix>N/` để viết và điền
trang bìa (`MÃ MÔN` · `MÔN HỌC` · `GVHD` · `Sinh viên thực hiện` · `MSSV` · `Lớp`)
— lấy từ `README.md` của môn.

---

## Không làm

- ❌ **Không tự đổi mẫu tên file nộp.** Mẫu do giảng viên quy định (`AGENTS.md` § 13.3).
  Script chỉ suy ra từ mục cùng loại — nếu chưa có mẫu lab, không lấy mẫu của bài tập; hỏi hoặc để `❓`.
- ❌ **Không điền sẵn tên và MSSV vào trang bìa file `.docx`** — repo đang public.
- ❌ **Không bịa đề bài.** Không có trong transcript thì để `❓`.
- ❌ **Không đoán số bài tiếp theo** là số lớn nhất + 1. Số bài nhảy cóc, có phần A/B.
- ❌ Không viết hộ lời giải. Ranh giới ở `AGENTS.md` § 6: người dùng phải có bản nháp
  ở mục *Hướng tiếp cận* trước.
- ❌ Không quên bước 4 — đây là chỗ hay hỏng nhất.
