# IE105 — Bài tập 5 · Hướng dẫn cách làm

| | |
|---|---|
| Bài tập | [`README.md`](README.md) — hàm băm, chứng chỉ số, chữ ký số |
| Buổi học | L04 · 2026-08-05 |
| **Hạn nộp** | **2026-08-05 21:30** ⚠️ đã qua |
| Ước lượng | **2,5 – 3 giờ** (câu 3 chiếm quá nửa) |

> ⚠️ **File này chỉ dạy CÁCH LÀM, không chứa lời giải.**
> Ba phần mềm nào, ba website nào, mô hình ra sao — bạn phải tự tìm và tự quyết.
> Xem [Phần bạn phải tự quyết](#phần-bạn-phải-tự-quyết) ở cuối.

---

## Mục lục

- [Đề yêu cầu gì](#đề-yêu-cầu-gì)
- [Kiến thức cần có](#kiến-thức-cần-có)
- [Câu 1 — Kiểm tra mã băm của phần mềm](#câu-1--kiểm-tra-mã-băm-của-phần-mềm)
- [Câu 2 — Chứng chỉ số và hàm băm tương ứng](#câu-2--chứng-chỉ-số-và-hàm-băm-tương-ứng)
- [Câu 3 — Tự xây một mô hình](#câu-3--tự-xây-một-mô-hình)
- [Checklist trước khi nộp](#checklist-trước-khi-nộp)
- [Phần bạn phải tự quyết](#phần-bạn-phải-tự-quyết)

---

## Đề yêu cầu gì

| Câu | Đầu ra phải nộp | Dạng |
|---|---|---|
| 1 | 3 phần mềm · hash công bố · hash bạn tính · kết luận tin cậy | **Bảng** + ảnh chụp minh chứng |
| 2 | 3 website · hàm băm dùng trong chứng chỉ | **Bảng** + ảnh chụp chứng chỉ |
| 3 | 1 mô hình tự thiết kế · phân tích hoạt động · ưu nhược điểm | **Sơ đồ** + đoạn phân tích |

Câu 1 và 2 là **thực hành, phải có minh chứng**. Câu 3 là **thiết kế, phải có lập luận**.
Hai loại khác nhau, đừng làm câu 3 theo kiểu liệt kê.

---

## Kiến thức cần có

| Cần biết | Học ở đâu |
|---|---|
| Hàm băm là gì, tính chất | `lectures/_raw/L04-2026-08-05-transcript.docx` |
| **6 công dụng của hàm băm** (6 hình A–F) | Slide `materials/slides/Bài 2B - Chứng thực dữ liệu.pdf` |
| Chữ ký số, tính toàn vẹn | cùng buổi L04 |
| Họ hàm băm: MD5, SHA-1, SHA-2, SHA-3 | L04 — thầy có nhắc SHA-2 gồm 224/256/384/512 |

Chưa nắm phần nào → hỏi trước khi bắt tay, đừng vừa làm vừa đoán.

---

## Câu 1 — Kiểm tra mã băm của phần mềm

**Đề hỏi:** chứng minh bạn biết **dùng hash để kiểm tra tính toàn vẹn của file tải về**.
Không phải sưu tầm phần mềm — mà là làm đủ vòng: lấy hash công bố → tự tính hash →
so sánh → kết luận.

**Đầu ra:** bảng 4–5 cột, mỗi phần mềm một dòng. Kèm ảnh chụp: nơi công bố hash,
và kết quả bạn tính được.

| Phần mềm | Nguồn tải | Hash công bố | Hash tự tính | Khớp? → kết luận |
|---|---|---|---|---|

**Tìm phần mềm có công bố hash ở đâu:**
- Trang tải chính thức, ngay cạnh nút download — thường ghi `SHA-256:` hoặc `MD5:`
- File riêng tên `SHA256SUMS`, `checksums.txt`, `*.sha256` trong thư mục tải
- Phần mềm mã nguồn mở và công cụ bảo mật hay công bố; phần mềm thương mại thường không

> 💡 **Thầy đã cho sẵn một cái trong lớp.** Buổi 4: *"tìm 3 phần mềm, trong đó CrypTool ❓
> nó cũng có là một rồi đó, có kèm theo mã băm"*. Còn **2 cái nữa bạn tự tìm**.
> (Transcript nghe ra `"twet tool"` / `"Rittool"` — nhiều khả năng là **CrypTool**,
> chính công cụ thầy demo trong buổi học.)

**Tính hash — chọn một cách:**

```bash
# macOS / Linux
shasum -a 256 <file>
md5 <file>

# Windows
CertUtil -hashfile <file> SHA256
```
Hoặc dùng **CrypTool** (thầy demo trong lớp), hoặc website cho phép băm file.
Thầy nói rõ: *"dùng cái gì băm cũng được"*.

**Các bước:**
1. Chọn phần mềm → chụp màn hình chỗ trang web **công bố hash**
2. Tải file về
3. Tự tính hash bằng công cụ bất kỳ → chụp màn hình kết quả
4. So sánh hai chuỗi, kết luận file **có bị sửa đổi hay không**
5. Lặp cho phần mềm thứ 2 và 3

**Thế nào là đủ:** mỗi phần mềm phải thấy được **cả hai** chuỗi hash và **kết luận về
độ tin cậy** — đó là chữ trong đề. Chỉ dán hash mà không kết luận là thiếu ý.

**Bẫy thường gặp:**
- Chụp hash công bố nhưng quên chụp hash tự tính → không chứng minh được gì
- Dùng nhầm thuật toán: trang công bố SHA-256 mà bạn tính MD5 → lệch là đương nhiên
- Quên kết luận, chỉ để bảng số trống trơn

> 💡 Muốn bảng thuyết phục hơn: sửa **một ký tự** trong file rồi băm lại, cho thấy hash
> đổi hoàn toàn. Thầy demo đúng chuyện này trong lớp (`"chữ hoa với chữ thường
> mà cái nó khác hẳn liền"`). Không bắt buộc, nhưng là ý hay.

---

## Câu 2 — Chứng chỉ số và hàm băm tương ứng

**Đề hỏi:** mở chứng chỉ số của 3 website bảo mật cao, đọc ra **hàm băm dùng trong
thuật toán chữ ký** của chứng chỉ đó.

**Đầu ra:** bảng 3 dòng + ảnh chụp cửa sổ chứng chỉ.

| Website | Tổ chức cấp (CA) | Thuật toán chữ ký | Hàm băm |
|---|---|---|---|

**Cách xem chứng chỉ (mọi trình duyệt đều tương tự):**
1. Mở website `https://` → bấm **biểu tượng ổ khoá** trên thanh địa chỉ
2. Chọn xem chi tiết chứng chỉ (*Connection is secure → Certificate is valid*)
3. Sang tab **Details**
4. Tìm trường **Signature Algorithm** — ví dụ dạng `SHA-256 with RSA Encryption`
5. Hàm băm là phần `SHA-...` trong đó

**Chọn website nào:** đề nói *"có yêu cầu bảo mật cao"* — nghĩ tới nhóm ngân hàng,
cổng thanh toán, dịch vụ công, sàn thương mại điện tử. Nên chọn **3 CA khác nhau**
để bảng có gì để so sánh.

**Thế nào là đủ:** thầy nói *"chủ yếu là SHA thôi, SHA-1 và SHA-2, SHA-3 gì đó"* —
tức là chỉ cần đọc đúng, không cần phân tích sâu. Nhưng nếu 3 website đều ra cùng
một hàm băm thì **thêm một câu nhận xét vì sao** sẽ ăn điểm hơn.

**Bẫy thường gặp:**
- Nhầm **Signature Algorithm** (thuật toán chữ ký của CA) với **Public Key Algorithm**
  hoặc với cipher suite của kết nối TLS — ba thứ khác nhau
- Chụp màn hình không thấy tên miền → không biết chứng chỉ của ai

---

## Câu 3 — Tự xây một mô hình

Câu nặng nhất, chiếm quá nửa thời gian. Ba việc riêng biệt: **thiết kế → phân tích → đánh giá**.

**Đề hỏi:** lấy 6 công dụng hàm băm đã học làm nguyên liệu, **ghép ra một mô hình
của riêng bạn** có đủ ba tính chất: *bảo mật · chứng thực · chữ ký số*.

> *Buổi 4 — "dựa trên 6 cái hình này, mấy em chế biến kiểu gì đó ra cái mô hình của mấy em.
> Mô hình của mình có thể nó phức tạp, có thể nó đơn giản"*

**Trước hết: đọc lại 6 hình cho kỹ.** Chúng khác nhau ở đúng hai trục:

| Trục | Các lựa chọn |
|---|---|
| **Mã hoá cái gì** | cả thông điệp + chuỗi băm · chỉ chuỗi băm · không mã hoá |
| **Dùng khoá nào** | khoá đối xứng · khoá công khai người nhận · khoá bí mật người gửi |

Nắm được hai trục này là bạn tự sinh ra được mô hình, không cần chép hình nào.

Ví dụ **cách đọc** (không phải đáp án) — hai hình đầu trong bài giảng:
- **Hình A:** băm M → ghép chữ băm vào M → mã hoá **cả gói** bằng khoá đối xứng.
  Bên nhận giải mã, băm lại M, so sánh. → có bảo mật, có toàn vẹn.
- **Hình B:** chỉ mã hoá **chuỗi băm**, M gửi đi dạng rõ. → không bảo mật, nhưng chống sửa đổi.
  Thầy giải thích vì sao lại chọn B: *"thông điệp quá lớn, mã hoá rất lâu"*, hoặc
  *"nội dung không cần giữ bí mật, ai muốn đọc thì đọc, nhưng không được sửa"*.

Bốn hình còn lại đọc theo đúng cách đó, lấy từ slide `Bài 2B`.

**Các bước:**
1. Liệt kê 6 hình, ghi mỗi hình đạt **tính chất nào** (bảo mật / toàn vẹn / chứng thực / chống chối bỏ)
2. Tìm tổ hợp đạt **đủ cả ba** yêu cầu của đề
3. Vẽ sơ đồ: phía gửi → đường truyền → phía nhận. Ghi rõ **khoá nào dùng ở bước nào**
4. **Phân tích hoạt động** — kể lại luồng theo thứ tự thời gian, mỗi bước một câu:
   ai làm gì, bằng khoá nào, để đạt được gì
5. **Ưu nhược điểm** — so với các mô hình trong bài học. Thầy nói rõ:
   *"nêu ưu nhược điểm của nó so với những cái mô hình của người ta"*

**Vẽ bằng gì:** thầy hướng dẫn ngay trong buổi — dùng **shape trong Word**
(hình chữ nhật, mũi tên, `Ctrl` + kéo để copy, Format để đổi màu), hoặc bút vẽ tay.
Không đòi công cụ chuyên nghiệp.

> *Buổi 4 — "tập cho quen nha, sau này học kỳ sau mình sẽ làm đồ án các loại,
> mình cũng phải tự thiết kế tự vẽ hệ thống của mình nhiều lắm"*

**Thế nào là đủ:**
- Mô hình **chạy được về mặt logic** — bên nhận phải có đủ khoá để làm việc bạn bắt họ làm
- Chỉ ra được **từng tính chất đến từ bước nào** (bảo mật nhờ bước nào, chứng thực nhờ bước nào)
- Nhược điểm phải là nhược điểm **thật**, có đánh đổi — không phải "hơi phức tạp"

**Bẫy thường gặp:**
- Vẽ lại y hệt một hình trong bài rồi đổi tên → đề yêu cầu *mô hình của mình*
- Mô hình dùng khoá mà phía nhận không thể có → logic hỏng, mất điểm nặng nhất
- Nhầm **chứng thực** (biết ai gửi) với **toàn vẹn** (nội dung không đổi) — hai thứ khác nhau
- Phần ưu nhược điểm viết chung chung, không so với mô hình nào cụ thể

---

## Checklist trước khi nộp

- [ ] Điền trang bìa: `IE105.F31.CN1.CNTT` · tên môn · GVHD **Tô Nguyễn Nhật Quang** · họ tên · MSSV · lớp
- [ ] Câu 1: đủ 3 phần mềm, mỗi cái có **cả hai** hash + kết luận
- [ ] Câu 2: đủ 3 website, đọc đúng trường **Signature Algorithm**
- [ ] Câu 3: có sơ đồ + phân tích luồng + ưu nhược điểm so sánh
- [ ] Ảnh chụp rõ, thấy được nội dung cần chứng minh
- [ ] Tên file: `Bài tập 5_Nguyễn Quốc Trung_25730081.docx` — **giữ dấu tiếng Việt**
- [ ] Nộp **file gốc `.docx`**, không phải PDF
- [ ] Nộp vào mục **"bài tập buổi học"**, không phải mục bài thực hành

> **Độ dài tham chiếu** từ bài bạn đã nộp cùng môn: 1.400 – 3.700 từ, trung bình ~2.800.
> Bài này có 3 câu và 1 phần thiết kế → khoảng **2.000 – 3.000 từ** là hợp lý.

---

## Phần bạn phải tự quyết

Hướng dẫn này **cố ý không đưa**:

- **2 trong 3 phần mềm** ở câu 1 — thầy đã cho sẵn 1, còn lại là việc của bạn
- **Giá trị hash cụ thể** — phải tự tải, tự tính mới có minh chứng
- **3 website** ở câu 2 và hàm băm của chúng
- **Chính cái mô hình** ở câu 3 — đây là toàn bộ điểm của câu này
- **Phân tích ưu nhược điểm** — lập luận phải là của bạn

Viết xong bản nháp thì quay lại nhờ review. Lúc đó tôi được phép chỉ ra chỗ sai
và **tại sao** sai — kể cả mô hình câu 3 có lỗ hổng logic ở đâu.
