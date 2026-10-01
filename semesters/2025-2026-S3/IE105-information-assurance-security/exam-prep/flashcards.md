# IE105 — Flashcard

Bản đọc trong repo. Bản import Anki: [`flashcards.csv`](flashcards.csv)

| | |
|---|---|
| Số thẻ | 12 |
| Cập nhật | 2026-10-01 — thêm 12 thẻ L02 |

> Thẻ được sinh ra khi xử lý note bài giảng. Mỗi lần thêm thẻ vào đây thì
> **đồng thời** thêm vào `flashcards.csv`, hai file phải khớp nhau.

---

## Tag

- `L02` — Mã hoá cổ điển (Bài 2A)

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

<!--
Mẫu:

### Thẻ 1
**Mặt trước:** <câu hỏi>
**Mặt sau:** <đáp án>
**Tag:** L01 concept
-->
