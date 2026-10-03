# IE105 — Flashcard

Bản đọc trong repo. Bản import Anki: [`flashcards.csv`](flashcards.csv)

| | |
|---|---|
| Số thẻ | 37 |
| Cập nhật | 2026-10-03 — thêm 12 thẻ L04 |

> Thẻ được sinh ra khi xử lý note bài giảng. Mỗi lần thêm thẻ vào đây thì
> **đồng thời** thêm vào `flashcards.csv`, hai file phải khớp nhau.

---

## Tag

- `L02` — Mã hoá cổ điển (Bài 2A)
- `L03` — Mã hoá hiện đại: DES, AES, RSA (Bài 2A)
- `L04` — Chứng thực dữ liệu: MAC, hàm băm, chữ ký số (Bài 2B)

---

## Thẻ

### Thẻ L02-1
**Mặt trước:** Ba trục phân loại mã hoá trên slide Bài 2A là gì?
**Mặt sau:** Cổ điển (thay thế / hoán vị) ↔ hiện đại · hiện đại chia theo khoá (đối xứng một khoá / bất đối xứng hai khoá) và theo dữ liệu vào (block cipher / stream cipher).

### Thẻ L02-2
**Mặt trước:** Block cipher và stream cipher khác nhau thế nào? Mỗi loại một ví dụ.
**Mặt sau:** Block mã các khối có chiều dài cố định 64 hoặc 128 bit (DES, AES) · stream mã từng bit của thông điệp (đại diện RC4).

### Thẻ L02-3
**Mặt trước:** A gửi thông điệp bí mật cho B bằng mã hoá bất đối xứng. Public key dùng để mã hoá là của ai?
**Mặt sau:** Của B — người nhận. Cả cặp khoá (public để mã hoá, private để giải mã) đều thuộc về B.

### Thẻ L02-4
**Mặt trước:** Hai sự kiện khiến mật mã học trở nên đại chúng là gì?
**Mặt sau:** Sự xuất hiện của tiêu chuẩn DES (công bố 17.03.1975) và sự ra đời của mật mã hoá khoá công khai.

### Thẻ L02-5
**Mặt trước:** Bức điện Zimmermann và việc phá mã Enigma gắn với hai cuộc chiến nào?
**Mặt sau:** Bức điện Zimmermann → Mỹ tham gia Thế chiến I. Phá mã hệ thống của Đức Quốc xã (máy Enigma) → Thế chiến II kết thúc sớm hơn.

### Thẻ L02-6
**Mặt trước:** Theo slide, giải thuật mật mã phải đáp ứng ba yêu cầu cơ bản nào?
**Mặt sau:** Bảo mật cao · công khai, dễ hiểu — khả năng bảo mật chốt vào khoá chứ không vào giải thuật · triển khai được trên thiết bị điện tử.

### Thẻ L02-7
**Mặt trước:** Mã thay thế đơn giản có bao nhiêu khoá, và vì sao vẫn yếu?
**Mặt sau:** 26! ≈ 4·10^26 khoá (mỗi khoá là một hoán vị của 26 chữ). Yếu vì mỗi chữ luôn thay bằng cùng một chữ, nên phân tích tần suất phá được.

### Thẻ L02-8
**Mặt trước:** Mã hoán vị bậc d với d = 5, h = (4 1 3 2 5) biến khối JOHN␣ thành gì?
**Mặt sau:** NJHO␣ — vị trí mới i lấy ký tự ở vị trí cũ h(i) · khoảng trắng cũng là một ký tự.

### Thẻ L02-9
**Mặt trước:** Quan hệ giữa Caesar và Vigenère là gì?
**Mặt sau:** Vigenère dùng khoá d ký tự viết lặp dưới thông báo, cộng mod 26. Caesar là Vigenère với d = 1: C = (p + k) mod 26.

### Thẻ L02-10
**Mặt trước:** Công thức mã Affine và giải mã? Khi nào Affine trở thành mã dịch chuyển?
**Mặt sau:** e(x) = ax + b (mod 26) · giải mã x = a⁻¹(y − b) (mod 26). a = 1 thì là mã dịch chuyển. Cần gcd(a, 26) = 1 để có a⁻¹.

### Thẻ L02-11
**Mặt trước:** Dựng ma trận khoá Playfair 5×5 thế nào?
**Mặt sau:** Lần lượt đưa các chữ của khoá vào (bỏ chữ trùng), rồi điền các chữ còn lại theo thứ tự A–Z · I và J xem là một. Ma trận 6×6 dùng khi có chữ số (26 chữ + 10 số), lúc đó I, J tách riêng.

### Thẻ L02-12
**Mặt trước:** Ba luật mã hoá một cặp chữ của Playfair?
**Mặt sau:** Dư 1 chữ thì thêm x. Cùng dòng → lấy chữ bên phải (cột cuối vòng về đầu). Cùng cột → lấy chữ bên dưới (hàng cuối vòng lên đầu). Hình chữ nhật → lấy hai góc còn lại trên cùng dòng của mỗi chữ.

### Thẻ L03-1
**Mặt trước:** 4 đặc điểm của mã hoá hiện đại so với cổ điển?
**Mặt sau:** Mã khối (nhiều ký tự một lần) · kết hợp hoán vị và thay thế · lặp nhiều vòng · mỗi vòng một khoá con sinh từ khoá ban đầu.

### Thẻ L03-2
**Mặt trước:** DES: kích thước khoá, khối, số vòng, số khoá con?
**Mặt sau:** Khoá 56 bit · khối 64 bit · 16 vòng · 16 khoá con. Đối xứng, thuộc hệ mã khoá bí mật.

### Thẻ L03-3
**Mặt trước:** Luồng tổng quát của DES (slide s48)?
**Mặt sau:** Khối 64 bit → hoán vị IP → 16 vòng DES (mỗi vòng một khoá con, sinh từ khoá 56 bit qua PC1/PC2) → IP⁻¹ → bản mã 64 bit.

### Thẻ L03-4
**Mặt trước:** Vì sao DES bị thay và 3DES được khuyến cáo?
**Mặt sau:** Khoá 56 bit không chống được vét cạn (Deep Crack 1998 phá trong 56 giờ). 3DES chạy DES 3 lần, khoá dài gấp 3 → khuyến cáo 25.10.1999. AES thay DES làm chuẩn 26.05.2002.

### Thẻ L03-5
**Mặt trước:** AES: kích thước khối và kích thước khoá?
**Mặt sau:** Khối đầu vào 128 bit (16 byte, ma trận trạng thái 4×4). Khoá 128 / 192 / 256 bit (AES-128/192/256). Tên khác: Rijndael.

### Thẻ L03-6
**Mặt trước:** Bốn hàm mỗi vòng của AES và mỗi hàm tác động lên đâu?
**Mặt sau:** SubBytes: từng byte qua S-box · ShiftRows: từng hàng dịch trái 0/1/2/3 · MixColumns: từng cột nhân ma trận · AddRoundKey: XOR với khoá vòng.

### Thẻ L03-7
**Mặt trước:** AES-128 có bao nhiêu vòng, vòng cuối khác gì?
**Mặt sau:** 10 vòng: 9 vòng đủ 4 hàm, vòng cuối bỏ MixColumns. Có 11 khoá vòng (thêm 1 AddRoundKey trước vòng lặp).

### Thẻ L03-8
**Mặt trước:** ShiftRows dịch các hàng thế nào?
**Mặt sau:** Hàng 1 không đổi, hàng 2 dịch trái 1, hàng 3 dịch trái 2, hàng 4 dịch trái 3 (xoay vòng).

### Thẻ L03-9
**Mặt trước:** Bob mã thông điệp bằng public key của Alice. Đạt bảo mật hay chứng thực?
**Mặt sau:** Bảo mật: chỉ Alice (có private key) giải được. Không chứng thực: ai cũng có public key của Alice nên Alice không biết chắc ai gửi.

### Thẻ L03-10
**Mặt trước:** Alice mã thông điệp bằng private key của mình gửi Bob. Kẻ nghe lén đọc được không?
**Mặt sau:** Đọc được: giải bằng public key của Alice (công khai). Đạt chứng thực (chỉ Alice tạo được), không đạt bảo mật.

### Thẻ L03-11
**Mặt trước:** Muốn vừa bảo mật vừa chứng thực bằng RSA thì làm sao?
**Mặt sau:** Mã hai lần: bằng private key của người gửi (chứng thực) và bằng public key của người nhận (bảo mật). Bên nhận giải hai lần tương ứng.

### Thẻ L03-12
**Mặt trước:** Vì sao thực tế kết hợp RSA với DES/AES?
**Mặt sau:** RSA rất an toàn nhưng chậm hơn DES hàng ngàn lần → DES/AES mã khối văn bản, RSA chỉ mã khoá mà DES/AES đã dùng (slide s64).

### Thẻ L03-13
**Mặt trước:** Theo slide s68–69, vét cạn khoá 56 bit và 128 bit mất bao lâu?
**Mặt sau:** 56 bit: ~10 giờ ở 10⁶ lần thử/µs, 3,5 giờ với ngân sách $1M. 128 bit: ~5,4·10¹⁸ năm. Thêm 1 bit khoá → thời gian gấp đôi.

### Thẻ L04-1
**Mặt trước:** Bốn cách mã hóa thông điệp (a)(b)(c)(d) — đâu đạt bảo mật, đâu đạt chứng thực?
**Mặt sau:** (a) E(K,M): bảo mật ✅, chứng thực ❌ · (b) E(PUb,M): bảo mật ✅, chứng thực ❌ · (c) E(PRa,M): bảo mật ❌, chứng thực ✅ · (d) E(PUb,E(PRa,M)): bảo mật ✅, chứng thực ✅.
**Tag:** L04

### Thẻ L04-2
**Mặt trước:** MAC = C(K, M) — C là gì, K là gì, kết quả dùng để làm gì?
**Mặt sau:** C là hàm chứng thực (authentication function) · K là khoá bí mật chung hai bên · Kết quả là chuỗi độ dài cố định gửi kèm M để bên nhận kiểm tra M chưa bị sửa và đến đúng nguồn.
**Tag:** L04

### Thẻ L04-3
**Mặt trước:** Sơ đồ MAC (a): Alice gửi gì? Bob kiểm thế nào?
**Mặt sau:** Alice gửi M‖C(K,M). Bob tính lại C(K,M) từ M nhận được, so sánh với MAC nhận được — khớp thì M toàn vẹn và đến từ Alice.
**Tag:** L04

### Thẻ L04-4
**Mặt trước:** Sơ đồ MAC (b) và (c) khác nhau thế nào? Mỗi cái gửi gì?
**Mặt sau:** (b) E(K2, M‖C(K1,M)): mã hóa cả M lẫn MAC → Bob giải mã trước rồi mới kiểm MAC · (c) E(K2,M)‖C(K1,M): MAC của M gốc gửi ngoài → Bob kiểm MAC mà không cần giải mã M trước.
**Tag:** L04

### Thẻ L04-5
**Mặt trước:** Hai tính chất cốt lõi của hàm băm?
**Mặt sau:** (1) One-way: cho H(M) không thể tìm lại M · (2) Collision resistance: không thể tìm M' ≠ M sao cho H(M') = H(M).
**Tag:** L04

### Thẻ L04-6
**Mặt trước:** Công dụng hàm băm (a) và (c) — cái nào dùng khoá đối xứng, cái nào dùng private key?
**Mặt sau:** (a) M‖E(K, H(M)): dùng khoá đối xứng K — chứng thực, không có non-repudiation · (c) M‖E(PRa, H(M)): dùng private key PRa của Alice — chứng thực + chữ ký số, có non-repudiation.
**Tag:** L04

### Thẻ L04-7
**Mặt trước:** Công dụng hàm băm (e): biểu thức là gì và S là gì?
**Mặt sau:** M‖H(M‖S) — S là secret value bí mật chung hai bên. Không cần mã hóa: Eve không biết S → không tính lại H(M‖S) dù có M gốc.
**Tag:** L04

### Thẻ L04-8
**Mặt trước:** MD5 — độ dài hash, tác giả, năm, tình trạng hiện tại?
**Mặt sau:** 128 bit · Ronald Rivest, MIT · 1991 · Đã vỡ — không dùng cho bảo mật, chỉ dùng checksum không bảo mật.
**Tag:** L04

### Thẻ L04-9
**Mặt trước:** SHA-2 có những biến thể kích thước hash nào?
**Mặt sau:** 224 / 256 / 384 / 512 bit. SHA-3 (Keccak) cũng có các biến thể tương tự.
**Tag:** L04

### Thẻ L04-10
**Mặt trước:** Biểu thức chữ ký số. Alice ký M rồi gửi gì (sơ đồ không mã hóa)?
**Mặt sau:** Chữ ký DS = E(PRa, H(M)). Gửi: M‖DS.
**Tag:** L04

### Thẻ L04-11
**Mặt trước:** Bob nhận được M‖DS (chữ ký số). Kiểm tra bằng cách nào?
**Mặt sau:** (1) Tính H(M) từ M nhận được · (2) Giải D(PUa, DS) → H(M) gốc · (3) So sánh hai hash — khớp thì M chưa bị sửa và DS do Alice tạo.
**Tag:** L04

### Thẻ L04-12
**Mặt trước:** Tại sao chữ ký số ký trên H(M) thay vì ký trực tiếp lên M?
**Mặt sau:** RSA/ECC chỉ mã hóa được dữ liệu nhỏ (≤ kích thước khoá modulus). H(M) có độ dài cố định ngắn (e.g. SHA-256: 256 bit) → RSA xử lý được. M có thể dài hàng MB.
**Tag:** L04

<!--
Mẫu:

### Thẻ 1
**Mặt trước:** <câu hỏi>
**Mặt sau:** <đáp án>
**Tag:** L01 concept
-->
