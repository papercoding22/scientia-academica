---
name: exam-cheatsheet
description: Chắt lọc một hoặc vài câu trong guide ôn chương (exam-prep/chapter<N>-exam-study-guide.md) thành mục cheatsheet ngắn — công thức/ý cốt lõi, các bước làm bài, áp vào đề mẫu, cách kiểm tra, bảng bẫy giải thích từng phương án sai — rồi ghi vào exam-prep/cheatsheet-chapter<N>.md. Dùng khi người dùng nói "chắt lọc câu 20 ra cheatsheet", "làm cheatsheet chương 7", "tóm câu này thành cheatsheet", "thêm câu 21 vào cheatsheet". Chưa có guide chương thì dùng exam-study-guide trước; cheatsheet toàn môn từ IMPORTANT_NOTES (exam-prep/cheatsheet.md) không thuộc skill này.
---

# Cheatsheet theo câu đề mẫu

Guide chương (`exam-study-guide`) là bản **học**: giải thích đầy đủ, 5 bước § 3. Cheatsheet
là bản **xem nhanh trước giờ thi**: chỉ còn thứ cần để làm lại đúng dạng câu đó trong 1–2
phút. Mỗi câu (hoặc nhóm câu cùng dạng) là một mục `##` trong
`exam-prep/cheatsheet-chapter<N>.md`, file lớn dần theo từng lần gọi.

Mẫu chuẩn: mục *câu 20* của `IT007-operating-systems/exam-prep/cheatsheet-chapter7.md`
(tạo ngày 2026-09-29). Đọc mẫu đó trước khi viết mục mới.

---

## Mục lục

- [Bước 1 — Xác định câu và nguồn](#bước-1--xác-định-câu-và-nguồn)
- [Bước 2 — Chọn khung theo dạng câu](#bước-2--chọn-khung-theo-dạng-câu)
- [Bước 3 — Kiểm chứng số và bẫy](#bước-3--kiểm-chứng-số-và-bẫy)
- [Bước 4 — Ghi file](#bước-4--ghi-file)
- [Bước 5 — Commit và báo lại](#bước-5--commit-và-báo-lại)
- [Không làm](#không-làm)

---

## Bước 1 — Xác định câu và nguồn

1. Suy ra **môn + chương + số câu** từ lời người dùng hoặc ngữ cảnh phiên (đang ôn chương
   nào, vừa mở guide nào). "Tại câu 20" nghĩa là chỉ câu 20; "cả chương" nghĩa là mọi câu
   trong cột *Phạm vi* của guide. Không suy ra được chương thì hỏi **một** câu.
2. Đọc trong `exam-prep/chapter<N>-exam-study-guide.md`:
   - mục `### Câu <k>` ở phần 3 (đề, đáp án, giải thích, bẫy, tự kiểm tra);
   - mục kiến thức ở phần 2 mà câu đó trỏ tới (công thức, định nghĩa, bảng so sánh).
3. Không có guide chương → dừng, đề xuất chạy `exam-study-guide` trước. Không tự chắt lọc
   thẳng từ đề + slide, vì cheatsheet phải khớp với đáp án đã phân tích trong guide.
4. Mở `cheatsheet-chapter<N>.md` nếu đã có, để biết câu nào đã có mục. Đã có → cập nhật
   mục cũ, không tạo mục trùng.

## Bước 2 — Chọn khung theo dạng câu

Heading mục: `## <Tên tiếng Việt> (<English term>) — câu <k>` theo `AGENTS.md` § 2. Nhiều
câu cùng một kiến thức (vd 21a, 21b) → gộp một mục, ghi `— câu 21a, 21b`.

| Dạng câu (cột *Dạng* của exam-map) | Khung mục |
|---|---|
| **Tính toán / mô phỏng giải thuật** | Công thức (khối `text`, có chú thích từng dòng) → Các bước làm bài (≤ 5 bước) → Bảng áp vào đề mẫu (Bước · Tính · Kết quả, dòng cuối in đậm đáp án) → Kiểm tra 30 giây → Bảng bẫy |
| **Nhận diện khái niệm / phát biểu đúng-sai** | Định nghĩa một dòng đúng chữ slide → Bảng phân biệt với khái niệm dễ nhầm (cặp nhiễu trong đề) → Từ khoá nhận diện trong câu hỏi → Bảng bẫy |
| **Điền thuật ngữ** | Bảng *định nghĩa (đúng chữ slide) → thuật ngữ tiếng Anh ≤ 2 từ* → thuật ngữ hay bị điền nhầm |
| **Sắp thứ tự quy trình** | Chuỗi bước dạng `A → B → C` → mẹo nhớ thứ tự → bước hay bị đảo |

Mọi mục đều giữ:
- Nhãn nguồn ngắn như trong guide: `[C7 s44]`, `[Đề tr5, C20]`.
- Chữ **suy luận** ở đầu file hoặc cạnh đáp án khi đề không có đáp án chính thức.
- Link ngược về guide ở đầu file; phần giải thích dài để lại trong guide.

**Bảng bẫy** là phần đáng giá nhất: với câu trắc nghiệm, **mỗi phương án sai một dòng**,
ghi rõ phép tính sai hay cách hiểu sai nào sinh ra đúng con số/phát biểu đó, và dấu hiệu
nhận ra. Cột: `Làm sai · Ra phương án · Nhận ra vì`. Thêm lỗi phổ biến không trùng
phương án nếu guide có nêu.

Độ dài: mỗi mục nên vừa một màn hình, khoảng 25–45 dòng. Không đưa analogy, code hay
đoạn giải thích dài vào cheatsheet.

## Bước 3 — Kiểm chứng số và bẫy

- Tính lại mọi con số trong mục (đáp án, bước trung gian, phép kiểm tra), không chép từ guide.
- Với bảng bẫy: **tự dựng phép tính sai** rồi xác nhận nó ra đúng phương án đang gán. Không
  dựng lại được → ghi `lệch số` hoặc bỏ dòng đó, không gán bừa.
- Lệch với guide → báo người dùng và sửa guide, không để hai file nói khác nhau.

## Bước 4 — Ghi file

File chưa có → tạo với đầu file:

```markdown
# <MÃ MÔN> — Cheatsheet Chương <N>: <tên chương>

> Chắt lọc từ [guide Chương <N>](chapter<N>-exam-study-guide.md) để xem nhanh trước giờ thi. Giải thích đầy đủ nằm trong guide.
> Đáp án là **suy luận**, vì đề mẫu không có đáp án chính thức. `[C<N> s44]` = slide C<N>, trang PDF 44.

---
```

(Bỏ câu *suy luận* nếu đề có đáp án chính thức.)

- Sắp các mục `##` theo **số câu tăng dần**, không phải theo thứ tự thêm vào.
- Cheatsheet **không có mục lục** (`AGENTS.md` § 2b).
- Lần đầu tạo file → thêm `· [Cheatsheet Chương <N>](cheatsheet-chapter<N>.md)` vào dòng
  *Liên quan* của guide chương.

## Bước 5 — Commit và báo lại

Chỉ stage file vừa ghi (`AGENTS.md` § 11):
`<MÃ MÔN>: cheatsheet chương <N> — câu <k> <chủ đề ngắn>`.

Báo lại 3–5 dòng: đường dẫn file, mục đã thêm, và bẫy nào **mới so với guide** (nếu có).

## Không làm

- ❌ Không ghi vào `exam-prep/cheatsheet.md`: file đó sinh từ `IMPORTANT_NOTES.md` mục 2, 3 (`AGENTS.md` § 8).
- ❌ Không bịa "câu này sẽ thi" hay lời giảng viên; cheatsheet chỉ chắt lọc từ đề mẫu và guide.
- ❌ Không chép lại cả mục guide. Cheatsheet dài gần bằng guide là cheatsheet hỏng.
- ❌ Không sửa `materials/`, `lectures/_raw/` hoặc file đề gốc (`AGENTS.md` § 12).
