---
name: exam-map
description: Phân tích đề thi mẫu / đề cũ của một môn thành Map Đề Thi (từng câu → chương → mục trong chương → slide, dạng câu, điểm) và Exam Blueprint (đề kiểm tra kiến thức gì, dưới dạng nào, trọng số bao nhiêu). Dùng khi người dùng đưa file đề thi mẫu/đề cũ, hoặc nói "map đề thi", "phân tích đề mẫu", "đề thi hay ra phần nào", "blueprint đề thi", "cấu trúc đề thi", "ôn thi theo đề mẫu".
---

# Map Đề Thi + Exam Blueprint

Biến một (hoặc nhiều) đề thi mẫu thành bản đồ để **ôn đúng chỗ có điểm**. Hai đầu ra
nằm chung một file `exam-prep/exam-map.md` của môn:

1. **Map Đề Thi** — mỗi câu (và mỗi ý a/b nếu chấm riêng) → chương → mục trong chương
   → slide nguồn, kèm kiến thức kiểm tra, dạng câu, điểm.
2. **Exam Blueprint** — gộp các câu lại: trọng số theo chương, theo mục, theo dạng câu,
   theo mức nhận thức; phần slide chưa bị hỏi; ưu tiên ôn.

Nếu người dùng muốn **chắt lọc kiến thức của một chương và hướng dẫn từng câu** từ
đề, dùng [exam-study-guide](../exam-study-guide/SKILL.md). Skill đó có thể tham khảo
map đã có và tạo guide riêng trong `exam-prep/`.

## Mục lục

- [Xác định đầu vào](#xác-định-đầu-vào)
- [Đọc đề](#đọc-đề)
- [Map từng câu về slide](#map-từng-câu-về-slide)
- [Dựng Exam Blueprint](#dựng-exam-blueprint)
- [Cấu trúc file đầu ra](#cấu-trúc-file-đầu-ra)
- [Kiểm tra và bàn giao](#kiểm-tra-và-bàn-giao)
- [Không làm](#không-làm)

---

## Xác định đầu vào

1. Xác định đúng thư mục môn. Chưa rõ môn → hỏi một câu, không quét mọi môn.
2. Tìm file đề: đường dẫn người dùng đưa, hoặc tìm `*exam*`, `*de-thi*`, `*Đề*` trong
   thư mục môn. File đề là **đầu vào chỉ đọc** — không sửa, không đổi tên. Nếu đề nằm
   sai chỗ (ví dụ thả ở gốc thư mục môn), **chỉ báo lại** và gợi ý skill `tidy-files`;
   không tự `mv` trong skill này.
3. Đọc thêm để có khung chương/mục và quy định thi:
   - `materials/slides/` — nguồn chính để map. Có `materials/slides/knowledge-map.md`
     thì đọc trước, nó đã có sẵn cấu trúc chương.
   - `materials/syllabus/` hoặc slide chương 0 — hình thức thi, thời lượng, trọng số
     điểm, lịch từng buổi (để biết chương nào thuộc giữa kỳ / cuối kỳ / tự nghiên cứu).
   - `IMPORTANT_NOTES.md` mục 2, 3, 5 — lời giảng viên về đề thi.
4. `exam-prep/exam-map.md` đã tồn tại → đọc nó, **thêm đề mới** vào Map Đề Thi và
   **tính lại Blueprint trên toàn bộ đề**; không xoá map của đề cũ.

## Đọc đề

Nạp skill `anthropic-skills:pdf` nếu đề là PDF. Đọc **mọi trang**, gồm cả bảng trả lời
cuối đề — bảng trả lời cho biết ý nào được chấm riêng.

Khi map câu hỏi → slide: chạy `scripts/slides-to-md.py --course <mã>` rồi `grep -rn -i
"<thuật ngữ>" .cache/md/semesters/*/<mã>-*/` để tìm file và trang chứa khái niệm, sau đó
Read đúng trang đó để xác nhận. Không ghi số slide chỉ dựa vào kết quả grep.

Trích cho mỗi câu: số câu, phần (trắc nghiệm/tự luận), nội dung ngắn, các phương án,
mã chuẩn đầu ra nếu đề ghi (ví dụ `G2.1`), và điểm.

**Điểm:** lấy từ đề (`0.3 điểm/câu`, `0.5 điểm/câu`…). Khi câu tự luận có nhiều ý và
bảng trả lời chấm **từng ý một ô**, chia điểm theo ô và kiểm chứng bằng phép cộng
(tổng phải bằng điểm phần đó). Không khớp → ghi `❓ CẦN XÁC MINH`, **không làm tròn**.

Đề không rõ nguồn (trường/khoa để trống, không biết giảng viên nào ra) → ghi rõ ở đầu
file. Đề mẫu **không phải** lời giảng viên: không chép vào `IMPORTANT_NOTES.md`
(AGENTS.md § 8) trừ khi giảng viên đã nói đề thi thật theo cấu trúc này.

## Map từng câu về slide

Với mỗi câu, tìm **mục nhỏ nhất** trong slide chứa kiến thức để giải câu đó:

- Trích text slide, tìm từ khoá của câu (thuật ngữ, công thức, tên giải thuật). Slide
  bị dính chữ (mất khoảng trắng) → so khớp sau khi bỏ khoảng trắng.
- Ghi theo dạng `Ch<n> · <số mục> <tên mục>` + `[<mã file> s<số slide>]`. Số mục lấy
  **đúng như slide ghi** (`5.6.2`, `8.3.5`…). Slide không đánh số mục (ví dụ phụ lục)
  → ghi tên như slide ghi (`Appendix A: Liveness`), không tự bịa số.
- Câu có đáp án gây nhiễu lấy từ **mục khác** (ví dụ phương án sai mô tả dynamic
  linking trong câu về bộ nhớ ảo) → ghi thêm vào cột ghi chú: người ôn cần phân biệt
  cả hai.
- Nếu đề dùng tên hàm/thuật ngữ mà slide không có (ví dụ `sem_wait()` trong khi slide
  viết `wait(S)`) → vẫn map về mục gần nhất và ghi chú khác biệt.
- Không tìm được mục nào → `❓ CẦN XÁC MINH`, không đoán chương.

**Dạng câu** — dùng bộ nhãn cố định để Blueprint gộp được qua nhiều đề:

| Nhãn | Nhận biết |
|---|---|
| Nhận diện khái niệm | Cho mô tả → chọn đúng tên thuật ngữ, hoặc ngược lại |
| Phát biểu đúng/sai | "Chọn phát biểu ĐÚNG / SAI / KHÔNG phải" |
| Sắp thứ tự quy trình | Xếp các bước của một cơ chế |
| Phân tích code | Đọc đoạn code, nhận xét lỗi/tính đúng |
| Tính toán | Áp công thức ra một con số |
| Mô phỏng giải thuật | Chạy tay giải thuật trên dữ liệu (thay trang, định thời, cấp phát…) |
| Điền thuật ngữ | Tự viết thuật ngữ (thường bằng tiếng Anh) |

**Mức nhận thức** — Nhớ · Hiểu · Vận dụng · Phân tích (Bloom rút gọn). Nhớ = thuộc
định nghĩa; Hiểu = phân biệt/giải thích; Vận dụng = tính, mô phỏng; Phân tích = soi
lỗi trong code hoặc lập luận nhiều bước.

Có thể **tự giải** để chắc câu đó thuộc dạng nào (ví dụ tính thử để biết cần công thức
nào), nhưng đáp án chỉ đưa vào file khi người dùng yêu cầu, và khi đưa thì gập trong
`<details>` (AGENTS.md § 4).

## Dựng Exam Blueprint

Mọi con số trong Blueprint phải **cộng lại đúng tổng điểm của đề**. Gồm:

1. **Thông tin đề** — số câu, cấu trúc phần, thời lượng (nguồn: đề, hoặc syllabus/slide
   chương 0 — ghi nguồn), chuẩn đầu ra được kiểm tra.
2. **Trọng số theo chương** — điểm, %, số câu; thanh ASCII (`█`, 1 ô ≈ 0.25 điểm) cho
   nhìn nhanh. Liệt kê cả chương **0 điểm** và lý do có nguồn (thuộc giữa kỳ, tự nghiên
   cứu…); không có nguồn thì chỉ ghi "không xuất hiện trong đề này".
3. **Trọng số theo mục** — bảng chương → mục → câu → điểm. Đây là phần giá trị nhất:
   nó cho thấy mục nào "đáng tiền".
4. **Theo dạng câu** và **theo mức nhận thức** — điểm và %, kèm một dòng hệ quả cho
   việc ôn (ví dụ: 2 điểm điền thuật ngữ tiếng Anh → phải thuộc từ tiếng Anh, không chỉ
   hiểu nghĩa).
5. **Ma trận chương × dạng câu** — điểm ở mỗi ô, hàng/cột tổng.
6. **Mục có trong slide nhưng chưa bị hỏi** — liệt kê theo chương. Ghi rõ: *một đề mẫu
   không chứng minh mục đó không thi*.
7. **Ưu tiên ôn** — xếp theo điểm kỳ vọng, mỗi dòng nói dạng bài cần luyện và slide bài
   tập mẫu tương ứng nếu có. Đánh dấu đây là **suy luận từ đề mẫu**, không phải lời
   giảng viên.

Khi có từ 2 đề trở lên: Blueprint tính trên tổng tất cả đề, thêm cột "xuất hiện ở n/N
đề" — mục lặp lại qua nhiều đề là tín hiệu mạnh nhất.

## Cấu trúc file đầu ra

````markdown
# <MÃ MÔN> — Map Đề Thi & Exam Blueprint

| | |
|---|---|
| Đề đã phân tích | [<tên file>](<đường dẫn tương đối, URL-encode>) — mã đề …, … trang |
| Nguồn gốc đề | … / ❓ CẦN XÁC MINH |
| Cập nhật | YYYY-MM-DD |

> Quy ước nguồn: `[C5-2 s10]` = file slide mã C5-2, slide 10 (xem bảng Nguồn slide).

## Mục lục

## 1. Map Đề Thi
### Đề <mã> — Phần 1: Trắc nghiệm (<điểm>)
| Câu | Chủ đề | Mục trong chương | Kiến thức | Dạng câu | Mức | Điểm | Nguồn |
### Đề <mã> — Phần 2: Tự luận (<điểm>)
(cùng bảng, mỗi ý chấm riêng một dòng: 21a, 21b…)

## 2. Exam Blueprint
### 2.1. Thông tin đề
### 2.2. Trọng số theo chương
### 2.3. Trọng số theo mục
### 2.4. Theo dạng câu
### 2.5. Theo mức nhận thức
### 2.6. Ma trận chương × dạng câu
### 2.7. Chưa xuất hiện trong đề
### 2.8. Ưu tiên ôn

## 3. Cần xác minh

## 4. Nguồn slide
| Mã | File |
````

Cột **Chủ đề** ghi `Ch<n> — <tên chương>`; cột **Mục trong chương** ghi số mục + tên
mục đúng như slide. Nội dung tiếng Việt có dấu, thuật ngữ giữ tiếng Anh (AGENTS.md § 2).

## Kiểm tra và bàn giao

- Mỗi câu/ý của đề xuất hiện **đúng một dòng** trong Map; không sót, không trùng.
- Cộng điểm: tổng theo chương = tổng theo dạng câu = tổng theo mức = tổng điểm đề.
  Kiểm bằng một đoạn Python nhỏ, đừng cộng nhẩm.
- Mọi số slide đã được mở ra xem, không suy ra từ mục lục chương.
- Chạy `scripts/toc.py check <exam-map.md>`.
- Cập nhật dòng `exam-prep/` trong `README.md` của môn nếu có bảng liệt kê file.
- Commit: `<MÃ MÔN>: map đề thi mẫu + exam blueprint` (AGENTS.md § 11). Chỉ stage file
  của việc này.
- Báo cho người dùng: 3 chương/mục nặng điểm nhất, dạng câu chiếm nhiều điểm nhất,
  mục chưa bị hỏi đáng lo nhất, và các điểm cần xác minh.

## Không làm

- Không sửa, đổi tên, di chuyển file đề hay slide gốc.
- Không ghi đề mẫu thành "giảng viên nói sẽ thi" trong `IMPORTANT_NOTES.md`.
- Không kết luận "mục X không thi" từ một đề mẫu.
- Không đưa đáp án ra ngoài khi chưa được yêu cầu; có yêu cầu thì gập trong `<details>`.
- Không map về chương theo cảm giác khi chưa tìm thấy slide chứa kiến thức đó.
