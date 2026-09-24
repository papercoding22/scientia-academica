# IE105 — Cheatsheet ôn thi

> Dựng từ **mục 2 và 3 của [`../IMPORTANT_NOTES.md`](../IMPORTANT_NOTES.md)** (những gì giảng viên đã nói sẽ thi),
> bổ sung phạm vi từ [`EXAM_PREP.pdf`](EXAM_PREP.pdf) và đối chiếu số liệu với slide.
> **Thi CN 2026-10-04, ca 2 (10:00)** — 40 câu trắc nghiệm, 75 phút, **được mang 2 tờ A4 viết tay**.
>
> - Nhãn nguồn `[B2A s31]` = slide Bài 2A, slide 31 (tra mã ở [`exam-map.md`](exam-map.md) mục 4).
> - **★** = ưu tiên chép tay. **❓** = chưa xác nhận, đừng chép khi chưa kiểm.
> - Đây là **bản tra cứu để chép**, không phải để đọc thay việc ôn. Giảng viên dặn: cần *nhận diện hình và tên gọi*,
>   không cần thuộc sâu toán bên trong (buổi 1, 3).

---

# TỜ 1 — Mật mã và chứng thực

## ★ 1. Bảng tổng hợp thuật toán *(giảng viên chỉ cách ôn, buổi 3)*

| Thuật toán | Nhóm | Đặc điểm cần nhớ | Độ an toàn |
|---|---|---|---|
| Thay thế đơn giản | Cổ điển | Khoá = hoán vị 26 ký tự, có 26! khoá `[B2A s23]` | Yếu: phá bằng tần suất ký tự `[B2A s39–40]` |
| Hoán vị bậc d | Cổ điển | Chia khối d ký tự, hoán vị vị trí `[B2A s25]` | Yếu (cùng nhóm cổ điển) |
| Caesar / Vigenère | Cổ điển (dịch chuyển) | Vigenère: khoá d ký tự viết lặp, cộng mod 26. **Caesar = Vigenère với d = 1** `[B2A s27]` | Yếu |
| Affine | Cổ điển | `e(x) = ax + b mod 26`; a = 1 → dịch chuyển; giải: `x = a⁻¹(y − b)` `[B2A s30]` | Yếu |
| **Playfair** | Cổ điển | Mã **từng cặp 2 ký tự**, ma trận 5×5 (I = J) từ khoá `[B2A s31–32]` | Yếu hơn hiện đại; **giảng viên nói chắc có thi** |
| Hill | Cổ điển | `C = HP mod 26`, `P = H⁻¹C`, khoá là ma trận vuông `[B2A s35]` | Yếu |
| **DES** | Hiện đại · đối xứng · block | **Khoá 56 bit · khối 64 bit · 16 vòng · 16 khoá con** `[B2A s43, s47–48]` | Khoá 56 bit không đủ chống vét cạn; 3DES an toàn hơn `[B2A s18, s43, s46]` |
| **AES** | Hiện đại · đối xứng · block | **Khối 128 bit**; khoá 128/192/256; 4 hàm mỗi vòng: SubBytes → ShiftRows → MixColumns → AddRoundKey `[B2A s49–57]` | Thay DES (chuẩn mới) `[B2A s19]` |
| **RSA** | Hiện đại · **bất đối xứng** | 2 khoá: public mã hoá, private giải mã; **private ký, public xác minh** `[B2A s58–61]` | An toàn nếu khoá đủ dài; chậm hơn DES hàng ngàn lần → **kết hợp**: đối xứng mã dữ liệu, RSA mã khoá `[B2A s64]` |

**Phân loại** *(có thể ra 1 câu)*: cổ điển (thay thế · hoán vị) ↔ hiện đại; theo khoá: đối xứng (`KE = KD`, vd AES) ↔ bất đối xứng (`KE ≠ KD`, vd RSA); theo dữ liệu: **block** (khối cố định; DES, 3DES, AES) ↔ **stream** (từng bit; RC4) `[B2A s10, s20, s42]`.
**Yêu cầu giải thuật**: công khai, **bảo mật nằm ở khoá** chứ không ở giải thuật `[B2A s22]`.

## ★ 2. Playfair — làm được bằng tay *(giảng viên: "giải thuật chính", 2/7 câu đề mẫu)*

1. **Ma trận:** viết khoá (bỏ ký tự trùng) → điền tiếp A–Z chưa dùng; **I và J là một** `[B2A s31]`.
2. **Tách cặp** 2 ký tự; dư 1 ký tự thì thêm `x` cuối `[B2A s32]`.
3. **Ba luật** cho mỗi cặp `[B2A s32]`:
   - **cùng hàng** → lấy ký tự **bên phải** (cột cuối quay về cột đầu)
   - **cùng cột** → lấy ký tự **bên dưới** (hàng cuối quay về hàng đầu)
   - **hình chữ nhật** → lấy ký tự **cùng hàng của mình, ở cột của ký tự kia**

**Ví dụ có sẵn trong slide** `[B2A s34]`, khoá `PLAYFAIR`, bản rõ `THANH PHO HO CHI MINH`:

```
P L A Y F        cặp:  TH AN HP HO HO CH IM IN HX
I R B C D        mã :  QM PQ EA GQ GQ BK DE EU KW
E G H K M
N O Q S T        Kiểm tay: TH → T(hàng 4, cột 5), H(hàng 3, cột 3): hình chữ nhật → Q, M ✓
U V W X Z
```

## ★ 3. Chứng thực — MAC · hàm băm · chữ ký số *(giảng viên: cho biểu thức ↔ hình, sơ đồ bị che ô)*

**4 cách dùng mã hoá thông điệp** `[B2B s17–21]`

| Sơ đồ | Bảo mật | Chứng thực | Chữ ký số |
|---|:-:|:-:|:-:|
| `A→B: E(K, M)` — khoá chung K | ✓ | ✓ | ✗ (B giả mạo được, A chối được) |
| `A→B: E(PUb, M)` | ✓ | ✗ | ✗ |
| `A→B: E(PRa, M)` | ✗ | ✓ | ✓ |
| `A→B: E(PUb, E(PRa, M))` — **mã hoá hai lần** | ✓ | ✓ | ✓ |

> Giảng viên (buổi 3): vừa bảo mật vừa chứng thực → **mã hoá hai lần**, một lần bằng **khoá công khai của người nhận**.

**★ 6 công dụng của hàm băm (a–f)** `[B2B s40–44]` — `‖` là nối, `H` là băm, `S` là bí mật chung

| | Biểu thức | Bảo mật | Chứng thực | Chữ ký số |
|---|---|:-:|:-:|:-:|
| a | `E(K, [M ‖ H(M)])` | ✓ | ✓ | ✗ |
| b | `M ‖ E(K, H(M))` | ✗ | ✓ | ✗ |
| c | `M ‖ E(PRa, H(M))` | ✗ | ✓ | ✓ |
| d | `E(K, [M ‖ E(PRa, H(M))])` | ✓ | ✓ | ✓ |
| e | `M ‖ H(M ‖ S)` — **không mã hoá gì**, chỉ băm cùng bí mật S | ✗ | ✓ | ✗ |
| f | `E(K, [M ‖ H(M ‖ S)])` | ✓ | ✓ | ✗ |

**Cách đọc nhanh:** có `E(K, …)` bao ngoài → **bảo mật**. Có `E(PRa, …)` → **chữ ký số**. Có `S` bên trong `H(… ‖ S)` → chứng thực nhờ bí mật chung, **không** có chữ ký số.

**★ Chữ ký số** `[B2B s50–52]`
- **Ký:** băm thông điệp → mã **digest** bằng **private key người gửi** (thường RSA) → gửi kèm thông điệp.
- **Kiểm:** giải chữ ký bằng **public key người gửi** → băm lại thông điệp nhận → **so sánh**. Trùng → không bị sửa và đúng người gửi.
- Sơ đồ bị che ô: xác định ô là *hàm băm*, *mã bằng private key*, hay *so sánh*.

**Hash và MAC** `[B2B s22, s35, s37, s45–49]`
- **MAC** `= C(K, M)`: có khoá bí mật chung. **Hash**: không khoá. **CHF** cần *một chiều* + *kháng đụng độ*.
- MD5 → **128 bit** · SHA-1 → **160 bit** · SHA-2 → 224/256/384/512 · SHA-3 (Keccak). MD5, SHA-1 đã bị chứng minh không kháng đụng độ (2004–2005).
- Sửa một ký tự, hash đổi hoàn toàn `[B2B s46]`.

## 4. Bài 1 — Tổng quan ❓

Slide Bài 1 **hỏng**, transcript buổi 1 chưa thành note → **chưa có nội dung kiểm chứng**. Danh mục ôn theo `EXAM_PREP.pdf`:
- Kỹ thuật tấn công cơ bản: Eavesdropping · Cryptanalysis · Password Pilfering · Identity Spoofing · Intrusion · Denial of Service
- Các **nhóm attacker** (đề mẫu có 1 câu phân biệt black-hat, script kiddies, cyber terrorists, vicious employees) và **thứ tự hành động của hacker**
- Mô hình bảo mật cơ bản: các thành phần + phòng thủ theo chiều sâu
- Giảng viên (buổi 1): có câu dạng **"đặc điểm nào sau đây KHÔNG phải…"** về yêu cầu của dữ liệu.

> ❓ Đọc transcript `lectures/_raw/L01-…docx` để điền phần này, rồi chép.

---

# TỜ 2 — Tấn công, mã độc, không dây

## ★ 5. Quét mạng — nhận diện kỹ thuật từ hình *(giảng viên, buổi 6)*

3 loại quét: **port · vulnerability · network** `[B3B s4]`. Methodology: live systems → open ports → banner grabbing → vulnerability → vẽ sơ đồ → proxy `[B3B s5]`.

| Kỹ thuật | Đặc trưng gói gửi đi | Dấu hiệu `[B3B s16–24]` |
|---|---|---|
| TCP connect (full open) | Hoàn tất bắt tay 3 bước rồi RST | — |
| **Stealth / half-open** | SYN, **không** hoàn tất | SYN/ACK = mở · RST = đóng |
| **XMAS** | Cờ FIN + URG + PSH | Không trả lời = mở · RST = đóng |
| FIN | Chỉ cờ FIN | Như XMAS |
| **NULL** | **Không** cờ nào | Như XMAS |
| ACK | Cờ ACK | Không trả lời = bị lọc (có firewall) · RST = không lọc |
| UDP | UDP, không bắt tay | ICMP port unreachable = đóng · im lặng = mở |
| Inverse TCP flag | Cờ FIN/URG/PSH hoặc không cờ | Không trả lời = mở · RST/ACK = đóng |

> Xmas, FIN, NULL chỉ hiệu quả với hệ theo RFC 793, **không** hiệu quả với Windows hiện tại `[B3B s18–20]`.

**Thăm dò (footprinting)** `[B3A s7]`: WHOIS · DNS · network (traceroute) · website · email · Google hacking. Phòng chống: split DNS + hạn chế zone transfer, tắt directory listing, dịch vụ privacy cho Whois, đào tạo về social engineering `[B3A s52–53]`.

## ★ 6. Mật khẩu và hệ thống *(giảng viên, buổi 7: cho nhiều chuỗi, hỏi chuỗi yếu/mạnh nhất)*

- **Tiêu chí:** độ dài + số loại ký tự (chữ, số, ký tự đặc biệt) `[B4 s8]`; từ có trong từ điển, tên, ngày sinh là yếu `[B4 s28]`. ❓ Slide s8 nêu 7 ví dụ độ phức tạp nhưng không xếp hạng — **xem lại slide** để chọn được chuỗi mạnh/yếu nhất.
- **Phòng chống:** 8–12 ký tự hỗn hợp · không dùng lại · đổi định kỳ · giám sát log · không lưu mật khẩu chỗ không bảo vệ `[B4 s28]`.
- Giảng viên buổi 7 còn nhắc: dumpster diving (lục thùng rác), mã hoá dữ liệu nhạy cảm, alternate data stream (NTFS) `[IMPORTANT_NOTES mục 6]`.
- **Keylogger:** ghi lại phím gõ. **Spyware:** ghi hoạt động người dùng mà họ không biết `[B4 s14, s39, s45]`.
- 5 giai đoạn hệ thống `[B4 s4]`: gaining access → escalating privileges → executing applications → hiding files → covering tracks.

## 7. Mã độc — ý chính *(EXAM_PREP: chỉ cần ý chính)*

- **Vòng đời** `[B5 s13]`: Delivery/Infection → Execution → Persistence → Lateral Movement → C2 → Actions on Objectives.
- **Phân tích tĩnh** = không chạy mẫu (cấu trúc file, strings, import/API, hash) · **phân tích động** = chạy trong **sandbox** cô lập, quan sát tiến trình/file/registry/mạng `[B5 s59–105]`.
- **IoC** 4 mức: hệ thống · mạng · tập tin · hành vi `[B5 s49–58]`.
- **Phát hiện:** signature (nhanh nhưng không bắt biến thể) · hành vi · ML · sandbox `[B5 s110–111]`. **Phòng chống** 3 cấp: người dùng · hệ thống · mạng `[B5 s106–109]`.

## ★ 8. Wi-Fi

| | WEP | WPA | WPA2 |
|---|---|---|---|
| Thuật toán | RC4 | RC4 + TKIP | **AES-CCMP** |
| IV | **24 bit** (quá ngắn, lặp) | 48 bit | 48 bit |
| Khoá | 40/104 bit, **tĩnh** | 128 bit, đổi theo gói | 128 bit |
| Toàn vẹn | CRC-32 | Michael MIC | CCMP |
| Đánh giá | **Yếu, bỏ dùng** | Không còn khuyến nghị | Tốt (Personal PSK / Enterprise EAP) |

*Nguồn: `[B6 s16, s25–34]`. WPA3: SAE + AES-GCMP, mạnh nhất `[B6 s16]`.*

- **Kiểu chứng thực:** open system · shared key (WEP) · WPA/WPA2 (Personal PSK, Enterprise 802.1X/RADIUS/EAP) · MAC filtering · captive portal · WPS `[B6 s14–24]`. **Khuyến nghị:** công cộng → open/captive portal · gia đình → WPA2/3 Personal · doanh nghiệp → WPA2/3 Enterprise `[B6 s24]`.
- **SSID:** tên định danh mạng, tối đa 32 ký tự, phân biệt hoa thường; giữ giá trị mặc định là rủi ro `[B6 s11–13]`.
- **Mối đe doạ (tên cần nhận):** rogue AP · evil twin · honeyspot · MAC spoofing · ad hoc · misconfigured AP · client mis-association · unauthorized association · DoS (deauthentication) · jamming `[B6 s35–48, s84–86]`.
- **Phòng chống:** WPA2 Enterprise, đổi SSID/mật khẩu mặc định, VPN/IPsec, phát hiện và chặn rogue AP, Wireless IPS `[B6 s104–110]`.
- ❓ **Chuẩn 802.11 (tốc độ, năm ra đời)** — EXAM_PREP yêu cầu nhớ. Chỉ đã xác nhận: 802.11a 54 Mbps 5 GHz · 802.11b 11 Mbps 2.4 GHz · 802.11ax 9,6 Gbps `[B6 s9–10]`. **Đối chiếu bảng đầy đủ ở slide B6 s9–10 trước khi chép.**

## 9. Lab và tình huống ❓

- EXAM_PREP: nắm **mục đích, lệnh/công cụ, cách dùng** của 4 lab (kiểm tra bảo mật cơ bản · dò mật khẩu · dò thông tin trong bộ nhớ · Wi-Fi & thiết bị di động) + ý chính bài quản lý rủi ro và xu thế an ninh.
- ❓ Handout lab không có trong repo; số lab trong EXAM_PREP có thể lệch thư mục `assignments/lab*`.
- Tình huống Hybrid Working của đề mẫu: bảng *dấu hiệu → vùng kiến thức* ở [`exam-map.md`](exam-map.md) mục 1.

---

## Gợi ý chia 2 tờ A4 viết tay

| Tờ | Chép | Bỏ qua nếu hết chỗ |
|---|---|---|
| **1** | Bảng thuật toán (mục 1) · Playfair 3 luật + ví dụ (2) · bảng 4 cách + **6 công dụng hash** + chữ ký số (3) | Chi tiết MD5/SHA |
| **2** | Bảng kỹ thuật quét (5) · quy tắc mật khẩu (6) · bảng WEP/WPA/WPA2 + tên mối đe doạ (8) · vòng đời mã độc (7) | Danh sách công cụ |

**Chép tay chính là ôn.** Viết xong, che tờ giấy đi và tự viết lại bảng 6 công dụng hash từ trí nhớ.
