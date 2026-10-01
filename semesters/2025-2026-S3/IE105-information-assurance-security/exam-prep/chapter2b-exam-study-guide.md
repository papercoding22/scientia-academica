# IE105 — Ôn Chương 2B: Chứng thực dữ liệu (Data authentication)

| | |
|---|---|
| Môn / chương | IE105 · Bài 2B — Chứng thực dữ liệu |
| Phạm vi | Đề 1, câu 02 và 07; công dụng của hàm băm |
| Đề nguồn | [SAMPLE_FINAL_EXAM.pdf](SAMPLE_FINAL_EXAM.pdf), trang 1–2 |
| Nguồn kiến thức | Slide Bài 2B, trang 21, 40–43 |
| Điểm nhìn thấy trong đề mẫu | 2 câu × 0,25 = 0,50/10 điểm; đề chỉ có 7/40 câu |
| Ngày cập nhật | 2026-10-02 |
| Trạng thái đáp án | Suy luận từ đề và slide; chưa có đáp án chính thức |

> Guide chỉ giải hai câu Chương 2B nhìn thấy trong bản đề mẫu chưa đầy đủ. Không dùng tỷ lệ 0,50/10 để dự đoán trọng số của đề thi thật. Cách gọi bảo mật, chứng thực và chữ ký số dưới đây theo **mô hình trong slide**.

## Mục lục

- [Phạm vi và câu hỏi thuộc chương](#phạm-vi-và-câu-hỏi-thuộc-chương)
- [Các công dụng của hàm băm (Hash function applications)](#các-công-dụng-của-hàm-băm-hash-function-applications)
  - [1. Trực giác](#1-trực-giác)
  - [2. Analogy](#2-analogy)
  - [3. Ví dụ nhỏ](#3-ví-dụ-nhỏ)
  - [4. Ký hiệu và hai luồng](#4-ký-hiệu-và-hai-luồng)
  - [5. Bảng phân biệt sáu cấu trúc](#5-bảng-phân-biệt-sáu-cấu-trúc)
- [Đáp án và hướng dẫn từng câu](#đáp-án-và-hướng-dẫn-từng-câu)
  - [Câu 02 — đọc biểu thức hai lớp](#câu-02--đọc-biểu-thức-hai-lớp)
  - [Câu 07 — đọc luồng trong sơ đồ](#câu-07--đọc-luồng-trong-sơ-đồ)
- [Tự kiểm tra](#tự-kiểm-tra)
- [Nguồn](#nguồn)
- [Bạn cần tự làm lại phần nào](#bạn-cần-tự-làm-lại-phần-nào)

---

## Phạm vi và câu hỏi thuộc chương

| Câu | Trang đề | Dữ kiện cần đọc | Việc cần làm | Điểm |
|---|---:|---|---|---:|
| 02 | 2 | A → B: E(K, [M ‖ E(PR_A, H(M))]) | Xác định bảo mật, chứng thực và chữ ký số từ hai lớp bảo vệ | 0,25 |
| 07 | 2 | Sơ đồ M đi thẳng và nhánh H(M ‖ S) nhập lại, B băm để Compare | Khôi phục biểu thức tương ứng với sơ đồ | 0,25 |

Đề ghi 0,25 điểm/câu ở trang 1. Bản PDF chỉ có câu 01–07 và một tình huống kết thúc trước phần câu hỏi; hai câu trên không đại diện cho toàn bộ đề thật.

## Các công dụng của hàm băm (Hash function applications)

### 1. Trực giác

Mã băm cho một giá trị để đối chiếu thông điệp. Nếu ai cũng tính lại được giá trị ấy, nó **chưa tự chứng minh người gửi**. Các sơ đồ trong slide thêm bí mật chung hoặc khoá riêng của A, rồi có thể mã hoá cả gói để bảo mật nội dung. [Bài 2B, trang 40–43]

### 2. Analogy

Hãy hình dung gửi một tờ giấy:

- **Bí mật chung S** giống một dấu kiểm mà chỉ A và B biết cách tạo. B kiểm tra được, nhưng vì B cũng biết S nên dấu này không xác định riêng A trước người thứ ba.
- **Khoá riêng PR_A** giống con dấu riêng của A trong mô hình slide; B dùng khoá công khai PU_A để kiểm chứng.
- **Khoá chung K** giống hộp khoá kín quanh cả tờ giấy và dấu kiểm. Nó che nội dung bên trong, nhưng bản thân hộp khoá chung không phải chữ ký riêng của A.

### 3. Ví dụ nhỏ

**Ví dụ tự dựng:** A muốn gửi M = “OK”, A và B cùng biết S. A gửi M ‖ H(M ‖ S). B dùng M và S để tính lại H(M ‖ S), rồi so sánh hai giá trị băm. Người nhìn đường truyền vẫn đọc được “OK”, vì M nằm ngoài mọi phép mã hoá. Đây là cấu trúc (e) của slide, đúng dạng sơ đồ câu 07. [Bài 2B, trang 41 và 43]

### 4. Ký hiệu và hai luồng

| Ký hiệu | Ý nghĩa trong slide |
|---|---|
| M | Thông điệp gốc |
| H(X) | Mã băm của dữ liệu X |
| X ‖ Y | Ghép X và Y theo thứ tự |
| E(K, X) / D(K, X) | Mã hoá / giải mã X bằng khoá K |
| K | Khoá bí mật A và B chia sẻ cho lớp mã hoá |
| S | Trị bí mật A và B chia sẻ để đưa vào dữ liệu băm |
| PR_A / PU_A | Khoá riêng của A / khoá công khai dùng kiểm chứng phần do A tạo |

**Câu 02 — cấu trúc (d):**

~~~text
A: M → H(M) → E(PR_A, H(M)) ─┐
   M ────────────────────────┴→ [M ‖ phần ký] → E(K, [...]) → B
B: D(K, ...) → lấy M và phần ký → dùng PU_A kiểm chứng → so với H(M)
~~~

Lớp ngoài E(K, ...) che M. Phần E(PR_A, H(M)) gắn với khoá riêng của A và được kiểm chứng bằng PU_A. Slide kết luận cấu trúc (d) có bảo mật, chứng thực và chữ ký số. [Bài 2B, trang 41 và 43]

**Câu 07 — cấu trúc (e):**

~~~text
A: M ────────────────────────┐
   M ‖ S → H(M ‖ S) ─────────┴→ M ‖ H(M ‖ S) → B
B: lấy M, ghép S, băm lại → Compare với mã băm nhận được
~~~

Sơ đồ không có bước E hoặc D. M đi thẳng sang B nên không được che; cả A và B cùng biết S. [Bài 2B, trang 41 và 43]

### 5. Bảng phân biệt sáu cấu trúc

Slide Bài 2B trang 40–43 đánh dấu sáu cấu trúc (a)–(f). Bảng dưới chốt **tính chất theo slide**, để phân biệt công thức gần giống nhau trong đáp án.

| Cấu trúc | Dữ liệu A gửi | Bảo mật | Chứng thực | Chữ ký số |
|---|---|:---:|:---:|:---:|
| (a) | E(K, [M ‖ H(M)]) | Có | Có | — |
| (b) | M ‖ E(K, H(M)) | — | Có | — |
| (c) | M ‖ E(PR_A, H(M)) | — | Có | Có |
| **(d) — câu 02** | **E(K, [M ‖ E(PR_A, H(M))])** | **Có** | **Có** | **Có** |
| **(e) — câu 07** | **M ‖ H(M ‖ S)** | — | **Có** | — |
| (f) | E(K, [M ‖ H(M ‖ S)]) | Có | Có | — |

**Cách đọc nhanh:** thấy E(K, ...) bọc ngoài M thì slide gán bảo mật; thấy PR_A bảo vệ H(M) thì có chữ ký số; chỉ thấy bí mật chung K hoặc S thì không có chữ ký riêng của A. Ở dòng (f), biểu thức được viết với dấu đóng đầy đủ theo **sơ đồ (f) trang 41**; dòng chữ trên trang 43 thiếu dấu đóng.

Ký hiệu E(PR_A, H(M)) là cách slide mô tả chữ ký số, không phải hướng dẫn triển khai một API ký số. Tương tự, H(M ‖ S) là đúng biểu thức của slide; không gọi nó là HMAC. Các tính chất trong bảng là kết luận của **mô hình giảng dạy**, không phải bảo đảm cho mọi giải thuật mã hoá bất kỳ.

## Đáp án và hướng dẫn từng câu

### Câu 02 — đọc biểu thức hai lớp

**Đề hỏi:** Với A → B: E(K, [M ‖ E(PR_A, H(M))]), chọn tính chất phù hợp. Các phương án là **a. Chỉ bảo mật; b. Bảo mật, chứng thực, chữ ký số; c. Bảo mật, chứng thực; d. Chỉ chứng thực.** [SAMPLE_FINAL_EXAM.pdf, trang 2]

**Đáp án suy luận: B — Bảo mật, chứng thực, chữ ký số.** Đề không kèm đáp án chính thức; biểu thức khớp nguyên cấu trúc (d) và kết luận trên slide Bài 2B trang 43.

**Cách làm:**

1. Đọc từ trong ra ngoài: H(M) là mã băm của M; E(PR_A, H(M)) là phần ký gắn với khoá riêng A trong mô hình slide.
2. Ghép M với phần ký. B có thể dùng PU_A để kiểm chứng phần ký và đối chiếu H(M): đây là chứng thực và chữ ký số theo slide.
3. E(K, [...]) bọc **cả M và phần ký**. Vì A và B chia sẻ K, slide gán thêm tính bảo mật.
4. Kết hợp ba tính chất → chọn B. Phương án A và C bỏ sót chữ ký số; D còn bỏ sót bảo mật.

**Bẫy:** Đừng dừng ở lớp E(K, ...) rồi kết luận chỉ bảo mật. Ngược lại, K là khoá chung nên riêng nó không tạo chữ ký số; lớp PR_A mới phân biệt phương án B với C. [Bài 2B, trang 21, 41 và 43]

**Tự kiểm tra:** Nếu bỏ E(PR_A, H(M)), tính chất “chữ ký số” phải biến mất; cấu trúc còn lại không còn là (d).

### Câu 07 — đọc luồng trong sơ đồ

**Đề hỏi:** Hình ở trang 2 mô tả quá trình nào? Phương án: **a. A → B: E(K, [M ‖ H(M)]); b. A → B: M ‖ H(M ‖ S); c. A → B: M ‖ E(K, H(M)); d. A → B: M ‖ E(PR_A, H(M)).** [SAMPLE_FINAL_EXAM.pdf, trang 2]

**Đáp án suy luận: B — A → B: M ‖ H(M ‖ S).** Đề không kèm đáp án chính thức; hình trùng sơ đồ (e) trên slide Bài 2B trang 41, được viết thành công thức ở trang 43.

**Cách làm:**

1. Bên A, một nhánh M đi thẳng tới phép ghép ‖; nhánh còn lại ghép **M với S trước khi băm**. Vậy mã băm là H(M ‖ S), không phải H(M).
2. Hai nhánh nhập lại thành M ‖ H(M ‖ S). Bên B dùng S băm lại cùng M và Compare.
3. Hình không có khối E/D hay khoá PR_A. Loại A, C, D vì cả ba đều đòi một phép mã hoá không có trong hình. Chọn B.

**Tính chất theo slide:** Có chứng thực nhờ S chia sẻ. Không có bảo mật vì M được gửi trực tiếp; không có chữ ký số riêng của A vì A và B cùng biết S. [Bài 2B, trang 41 và 43]

**Bẫy:** Vị trí S rất quan trọng: sơ đồ băm **M ‖ S**, rồi mới ghép mã băm với M. Đổi thành H(M) hoặc E(K, H(M)) là chuyển sang cấu trúc khác.

**Tự kiểm tra:** Che bốn phương án, lần ngược từng mũi tên từ đầu ra bên A và tự viết M ‖ H(M ‖ S).

## Tự kiểm tra

1. Vì sao gửi M ‖ H(M) đơn thuần chưa đủ để chứng thực người gửi?
2. Trong câu 02, lớp E(K, ...) cung cấp tính chất nào theo slide?
3. Trong câu 02, thành phần nào phân biệt chữ ký số với một mã kiểm tra dùng bí mật chung?
4. Trong câu 07, A băm dữ liệu nào, và A gửi hai thành phần nào?
5. Vì sao câu 07 có chứng thực theo slide nhưng không có bảo mật hoặc chữ ký số?

<details><summary>Đáp án và giải thích</summary>

1. Ai thấy M cũng tính lại được H(M), nên có thể thay M rồi thay luôn mã băm; không có bí mật hay khoá riêng để xác định người tạo.
2. Bảo mật: E(K, ...) bọc cả M và phần ký, và trong mô hình slide chỉ A/B có K để giải mã.
3. E(PR_A, H(M)): phần này gắn với khoá riêng A và B kiểm chứng bằng PU_A. K/S là bí mật chia sẻ, không phải chữ ký riêng.
4. A băm M ‖ S, rồi gửi M ‖ H(M ‖ S). Trật tự ghép S trước khi băm quyết định chọn phương án B.
5. S cho A/B cùng tạo và kiểm tra mã băm nên slide gọi là chứng thực; M vẫn truyền rõ và cả A/B đều biết S, nên không có bảo mật hoặc chữ ký riêng của A.

</details>

## Nguồn

- [SAMPLE_FINAL_EXAM.pdf](SAMPLE_FINAL_EXAM.pdf), Đề 1, trang 1–2: 0,25 điểm/câu; biểu thức và phương án câu 02; hình và phương án câu 07.
- [Slide Bài 2B — Chứng thực dữ liệu](../materials/slides/Ba%CC%80i%202B%20-%20Chu%CC%9B%CC%81ng%20thu%CC%9B%CC%A3c%20du%CC%9B%CC%83%20lie%CC%A3%CC%82u.pdf), trang 21: kết hợp bảo mật/chứng thực/chữ ký số; trang 40–41: sáu sơ đồ; trang 42–43: công thức và tính chất từng cấu trúc.
- [Map đề thi](exam-map.md), mục 1 và 2.8: định vị câu 02, 07 và giới hạn 7/40 câu của đề mẫu.

**Giới hạn nguồn:** Đề mẫu không có đáp án chính thức. Các đáp án B và B ở trên được suy ra từ công thức, sơ đồ và phần giải thích của slide; chưa thể suy rộng tỷ trọng hay số câu Chương 2B trong đề thi thật.

## Bạn cần tự làm lại phần nào

- Che bảng sáu cấu trúc; tự ghi cho từng dòng có/không có bảo mật, chứng thực và chữ ký số.
- Che đáp án câu 02; tự bóc lớp ngoài E(K, ...) và lớp trong E(PR_A, H(M)), rồi giải thích vì sao chọn B.
- Che đáp án câu 07; từ hình đề tự dựng lại M ‖ H(M ‖ S), sau đó loại ba phương án nhiễu.
