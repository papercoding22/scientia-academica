---
name: assignment-guide
description: Sinh file GUIDE.md hướng dẫn chi tiết từng bước cách thực hiện một bài tập, dựa trên đề bài đã có trong aN/README.md cộng lời giảng viên trong transcript. Dạy phương pháp và tiêu chí chấm, KHÔNG đưa lời giải. Dùng khi người dùng nói "hướng dẫn làm bài tập N", "bài này làm thế nào", "chỉ tôi cách làm", "tạo hướng dẫn cho bài tập", "không biết bắt đầu từ đâu".
---

# Hướng dẫn cách làm bài tập

Sinh `assignments/aN/GUIDE.md` — dạy **phương pháp**, không đưa **kết quả**.

---

## Mục lục

- [Ranh giới — đọc trước khi viết một chữ nào](#ranh-giới--đọc-trước-khi-viết-một-chữ-nào)
- [Bước 1 — Kiểm tra đã có đề bài chưa](#bước-1--kiểm-tra-đã-có-đề-bài-chưa)
- [Bước 2 — Gom bối cảnh](#bước-2--gom-bối-cảnh)
- [Bước 3 — Viết GUIDE.md](#bước-3--viết-guidemd)
- [Bước 4 — Commit và báo lại](#bước-4--commit-và-báo-lại)
- [Không làm](#không-làm)

---

## Ranh giới — đọc trước khi viết một chữ nào

`AGENTS.md` § 6: **không viết hộ lời giải khi người dùng chưa có bản nháp.**
Skill này đi sát ranh giới đó, nên phải tự soi từng câu mình viết.

**Phép thử một câu:** *sau khi đọc guide này, người dùng còn phải TỰ LÀM gì không?*
Câu trả lời là "không" → bạn vừa làm hộ bài.

Ví dụ thật, bài tập 5 của IE105:

| Đề hỏi | ✅ Được viết | ❌ Không được viết |
|---|---|---|
| Tìm 3 phần mềm có kèm mã băm | Trang tải chính thức thường công bố SHA-256 ở đâu · cách tính hash bằng `shasum`/CertUtil · cách so sánh | **Tên 3 phần mềm cụ thể** · giá trị hash |
| Tìm 3 chứng chỉ số, cho biết hàm băm | Cách mở chứng chỉ trong trình duyệt · trường nào ghi thuật toán chữ ký · cách đọc `SHA-256 with RSA` | **Tên 3 website** · hàm băm của chúng |
| Dựa trên 6 công dụng hàm băm, xây 1 mô hình | 6 công dụng đó là gì (đã học) · cách ghép các khối · tiêu chí một mô hình chặt · cách phân tích luồng | **Chính cái mô hình** · sơ đồ hoàn chỉnh |

**Nguyên tắc rút gọn:** viết được *cách tìm*, không viết *thứ tìm được*.
Viết được *tiêu chí đánh giá*, không viết *thứ đã được đánh giá*.

**Vẫn được phép và nên làm:**
- Giải thích lại khái niệm nền nếu người dùng chưa nắm — đó là dạy, không phải làm hộ
- Nói rõ **đầu ra phải nộp là gì** (bảng mấy cột, cần ảnh chụp không)
- Trích **tiêu chí chấm từ lời giảng viên**
- Cảnh báo bẫy hay mắc
- Ước lượng thời gian

**Người dùng đòi thẳng lời giải** → đưa, nhưng kèm mục `## Bạn cần tự làm lại phần nào`
(`AGENTS.md` § 6). Đừng lén đưa qua đường guide.

---

## Bước 1 — Kiểm tra đã có đề bài chưa

Đọc `assignments/aN/README.md` mục **Yêu cầu đề bài**.

Còn `❓ CHƯA CÓ ĐỀ BÀI` → **dừng lại**. Không có đề thì không hướng dẫn được,
và **tuyệt đối không bịa đề**. Báo người dùng cách lấy đề (transcript buổi học,
slide, hoặc chụp đề bỏ vào `brief/`).

---

## Bước 2 — Gom bối cảnh

Guide tốt hơn hẳn khi có bốn thứ này. Tìm đủ trước khi viết:

| Cần | Tìm ở đâu |
|---|---|
| **Lời giảng viên quanh chỗ đọc đề** | `lectures/_raw/L<nn>-*` — thầy thường nói thêm tiêu chí, gợi ý công cụ, mức độ cần đạt |
| **Kiến thức nền** | `lectures/L<nn>-*.md` · `notes/` · `materials/slides/` |
| **Quy định nộp bài** | `IMPORTANT_NOTES.md` mục 1 và 4 — tỷ trọng điểm, mẫu tên file, định dạng |
| **Bài tập cũ cùng môn** | `assignments/a*/` — bài đã nộp cho thấy giảng viên chấp nhận mức chi tiết nào |

File `.docx` → `scripts/peek.py <file>`.

> 💡 Bài đã nộp trước đó là nguồn tốt nhất để biết **độ dài và độ sâu kỳ vọng**.
> Bài 3A của IE105 ~1.400 từ, bài 3B ~3.700 từ — chênh lệch đó nói lên nhiều điều.

Lời giảng viên quý nhất là mấy câu định mức: *"mô hình có thể phức tạp, có thể đơn giản"* ·
*"không phải chỉ liệt kê cái tên là xong"* · *"không yêu cầu nắm quá sâu"*.
Trích nguyên văn vào guide, kèm nguồn.

---

## Bước 3 — Viết GUIDE.md

Dùng `templates/assignment-guide.md`, lưu thành `assignments/aN/GUIDE.md`.

**Mỗi câu hỏi viết đủ 5 phần:**

| Phần | Nội dung |
|---|---|
| **Đề hỏi** | Diễn lại bằng lời khác — đề gốc hay mơ hồ, diễn lại là đã giúp được nửa |
| **Đầu ra** | Bảng mấy cột? Đoạn văn mấy ý? Có cần ảnh chụp không? |
| **Công cụ** | Loại công cụ và cách dùng. Công cụ là việc tự tìm thì chỉ nói *loại* |
| **Các bước** | Thao tác, đánh số. **Mô tả hành động, không đưa kết quả hành động** |
| **Thế nào là đủ** | Tiêu chí, trích lời giảng viên nếu có |

Thêm **Bẫy thường gặp** khi biết chỗ dễ sai.

**Nhớ người dùng là dev đang đi làm** (`AGENTS.md` § 1): bỏ qua bước hiển nhiên,
nói thẳng vào chỗ khó. Ước lượng thời gian thật để họ xếp lịch.

**Mục cuối `## Phần bạn phải tự quyết` là bắt buộc** — liệt kê thẳng những gì guide
cố ý không đưa. Nó biến ranh giới thành thứ nhìn thấy được, thay vì người dùng đọc xong
tưởng thiếu sót.

---

## Bước 4 — Commit và báo lại

```
<MÃ MÔN>: hướng dẫn cách làm bài tập <N>
```

Báo lại: đã sinh guide cho bài nào · **lấy được tiêu chí gì từ lời giảng viên** ·
ước lượng thời gian · và nói rõ một câu rằng guide **không chứa lời giải**,
viết xong bản nháp thì quay lại nhờ review.

---

## Không làm

- ❌ **Không đưa đáp án**, kể cả dưới dạng "ví dụ minh hoạ" — ví dụ minh hoạ cho câu hỏi
  *"tìm 3 phần mềm"* chính là đáp án.
- ❌ **Không bịa đề bài.** Chưa có đề thì dừng, báo người dùng.
- ❌ **Không bịa tiêu chí chấm.** Không nghe giảng viên nói thì ghi là suy luận của mình.
- ❌ **Không viết guide dài hơn mức cần.** Người dùng đi làm, quỹ thời gian hẹp —
  guide 200 dòng cho bài 2 tiếng là phản tác dụng.
- ❌ Không sửa `README.md` của bài tập — mục *Hướng tiếp cận* ở đó là **của người dùng**,
  họ phải tự viết trước khi được review.
