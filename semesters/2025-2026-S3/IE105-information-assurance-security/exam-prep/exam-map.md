# IE105 — Map Đề Thi & Exam Blueprint

| | |
|---|---|
| Đề đã phân tích | [`SAMPLE_FINAL_EXAM.pdf`](SAMPLE_FINAL_EXAM.pdf) — Đề 1, 3 trang. **Chỉ có 7 / 40 câu** — xem [Cần xác minh](#3-cần-xác-minh) |
| Tài liệu phạm vi | [`EXAM_PREP.pdf`](EXAM_PREP.pdf) — "Nội dung ôn tập" thi cuối kỳ, 3 trang |
| Nguồn gốc đề | Đầu đề: Trường ĐH Công nghệ Thông tin · Trung tâm Phát triển CNTT · "Đề thi cuối học kỳ: II (2025-2026)". Không ghi giảng viên ra đề — ❓ |
| Cập nhật | 2026-09-24 |
| Sinh bởi | skill `exam-map` |

> **Quy ước nguồn:** `[B2B s41]` = file slide mã **B2B**, slide số **41** (tra mã ở [Nguồn slide](#4-nguồn-slide)).
> Đây là phân tích **một đề mẫu chưa đầy đủ**, không phải lời giảng viên — không thay cho
> [`IMPORTANT_NOTES.md`](../IMPORTANT_NOTES.md).
>
> ⚠️ **Đề mẫu chỉ còn 1,75 / 10 điểm.** Mọi con số trong Blueprint mô tả 7 câu ấy, **không** suy ra
> được cấu trúc cả đề. Phạm vi thi đáng tin hơn nằm ở `EXAM_PREP.pdf`.

---

## Mục lục

- [1. Map Đề Thi](#1-map-đề-thi)
  - [Đề 1 — Trắc nghiệm (10 điểm)](#đề-1--trắc-nghiệm-10-điểm)
  - [Tình huống "Hybrid Working" — chưa có câu hỏi nào](#tình-huống-hybrid-working--chưa-có-câu-hỏi-nào)
- [2. Exam Blueprint](#2-exam-blueprint)
  - [2.1. Thông tin đề](#21-thông-tin-đề)
  - [2.2. Trọng số theo chương](#22-trọng-số-theo-chương)
  - [2.3. Trọng số theo mục](#23-trọng-số-theo-mục)
  - [2.4. Theo dạng câu](#24-theo-dạng-câu)
  - [2.5. Theo mức nhận thức](#25-theo-mức-nhận-thức)
  - [2.6. Ma trận chương × dạng câu](#26-ma-trận-chương--dạng-câu)
  - [2.7. Chưa xuất hiện trong đề](#27-chưa-xuất-hiện-trong-đề)
  - [2.8. Ưu tiên ôn](#28-ưu-tiên-ôn)
- [3. Cần xác minh](#3-cần-xác-minh)
- [4. Nguồn slide](#4-nguồn-slide)

---

## 1. Map Đề Thi

### Đề 1 — Trắc nghiệm (10 điểm)

40 câu × 0,25 điểm, chọn 1 đáp án a–d, điền vào bảng trả lời `[đề, trang 1]`. **Đề mẫu chỉ có câu 01–07** (7 câu = 1,75 điểm).

| Câu | Chủ đề | Mục trong chương | Kiến thức | Dạng câu | Mức | Điểm | Nguồn |
|---|---|---|---|---|---|---:|---|
| 01 | Ch4 — Các nguy cơ bảo mật trên hệ thống | Chạy ứng dụng — Keylogger | Mục đích của keylogger. Phương án nhiễu gần với spyware (theo dõi hoạt động người dùng) | Nhận diện khái niệm | Nhớ | 0,25 | [B4 s14, s39–41] · nhiễu [B4 s45] |
| 02 | Ch2B — Chứng thực dữ liệu | 3 Hàm băm — Các công dụng cơ bản | Đọc biểu thức hai lớp `E(K, [M ‖ E(PR_A, H(M))])`: lớp ngoài dùng khoá gì, lớp trong dùng khoá gì → mỗi lớp cho tính chất nào (bảo mật / chứng thực / chữ ký số) | Nhận diện khái niệm | Hiểu | 0,25 | [B2B s41, s43] · so với [B2B s21] |
| 03 | Ch1 — Tổng quan | Các kỹ thuật tấn công cơ bản — Eavesdropping *(theo `EXAM_PREP.pdf`)* | Chọn biện pháp chống nghe trộm trên đường truyền trong 4 phương án (chứng thực gói, mã hoá dữ liệu truyền, bỏ mạng không dây, tường lửa) | Nhận diện khái niệm | Hiểu | 0,25 | ❓ [B1] không đọc được · liên quan [B4 s11], [B2B s18–19] |
| 04 | Ch1 — Tổng quan | Lý lịch của những kẻ tấn công — Phân biệt các nhóm attacker *(theo `EXAM_PREP.pdf`)* | Từ định nghĩa ("dùng công cụ do hacker mũ đen viết") gọi tên đúng nhóm trong 4 nhóm: black-hat, script kiddies, cyber terrorists, vicious employees | Nhận diện khái niệm | Nhớ | 0,25 | ❓ [B1] không đọc được |
| 05 | Ch2A — Các giải thuật mã hoá | 3.5 Mã Playfair | Dựng ma trận khóa 5×5 từ `BAOMAT`: bỏ ký tự trùng, I = J, điền tiếp A–Z; tra một ô theo hàng/cột. Chung tình huống với 06 | Mô phỏng giải thuật | Vận dụng | 0,25 | [B2A s31–34] · bài mẫu [B2A s73] |
| 06 | Ch2A — Các giải thuật mã hoá | 3.5 Mã Playfair | Mã hoá `THANH PHO HO CHI MINH`: tách cặp, áp ba quy tắc (cùng dòng / cùng cột / hình chữ nhật), lấy ký tự thứ hai của bản mã. Slide dùng **đúng thông điệp này** (khoá `PLAYFAIR`) | Mô phỏng giải thuật | Vận dụng | 0,25 | [B2A s32, s34] · bài mẫu [B2A s73] |
| 07 | Ch2B — Chứng thực dữ liệu | 3 Hàm băm — Các công dụng cơ bản | Đọc sơ đồ: có bí mật `S` hay không, có phép `E` hay không, so sánh ở đâu → đối chiếu với 6 công dụng (a–f). Cả 4 phương án lấy từ 4 trong 6 công dụng đó | Nhận diện khái niệm | Hiểu | 0,25 | [B2B s40–43] |

### Tình huống "Hybrid Working" — chưa có câu hỏi nào

Đề đặt một tình huống (10 dấu hiệu) rồi kết thúc bằng "Hãy trả lời các câu hỏi sau:". **Không có câu hỏi** nên không có điểm để map.
Bảng dưới là **suy luận** về vùng kiến thức tình huống dễ chạm tới — không phải lời giảng viên.

| # | Dấu hiệu trong tình huống | Vùng kiến thức khả dĩ | Nguồn |
|---|---|---|---|
| 1 | Tiến trình lạ chiếm gần 2 GB RAM; nhiều tiến trình tên gần giống, khác PID | Ch5 — hành vi điển hình, dấu hiệu lây nhiễm mức hệ thống · Lab 3 (bộ nhớ) | [B5 s41–48, s50] · ❓ lab |
| 2 | `netstat -ano` thấy cổng 445 và 3389 mở | Ch5 — công cụ quan sát kết nối · Ch3B — cổng mở là gì · Lab 1 (lệnh, công cụ) | [B5 s53, s93, s114] · [B3B s15–28] · ❓ lab |
| 3 | Tài khoản Guest đang bật | Cấu hình cơ bản — Lab 1. Slide chỉ có Guest xuất hiện trong ví dụ SAM | [B4 s22] · ❓ lab |
| 4 | Mật khẩu đơn giản `Company2025` | Ch4 — độ phức tạp mật khẩu, biện pháp bảo vệ mật khẩu | [B4 s8, s28] |
| 5 | Firewall tắt trên mạng Public | Ch5 — phòng vệ cấp hệ thống, cấp mạng · Ch6 — cấu hình an toàn | [B5 s108–109] · [B6 s106] |
| 6 | Nhiều sự kiện 4625 từ cùng một IP | Ch4 — tấn công đoán mật khẩu trực tuyến (tốn thời gian, dễ bị phát hiện), giám sát log · Lab 2 | [B4 s13, s28] · ❓ lab (slide không có mã sự kiện 4625) |
| 7 | Tài khoản vừa được thêm vào nhóm Administrators | Ch4 — leo thang đặc quyền, biện pháp phòng chống | [B4 s29–35] |
| 8 | Hotspot cá nhân WPA2 dùng mật khẩu `12345678` | Ch6 — WPA2-Personal (PSK), cấu hình chứng thực an toàn | [B6 s16, s28, s108] |
| 9 | Nhân viên dùng Wi-Fi miễn phí ở sân bay | Ch6 — mối đe doạ mạng không dây công cộng, biện pháp phòng chống (VPN, IPsec, WIDS) | [B6 s41, s85–86, s107, s109] |

---

## 2. Exam Blueprint

### 2.1. Thông tin đề

| | |
|---|---|
| Cấu trúc | 40 câu trắc nghiệm × 0,25 = **10 điểm**, 1 đáp án đúng `[đề, trang 1]` — đề mẫu chỉ có 7 câu (1,75 điểm) |
| Thời lượng | **75 phút** `[EXAM_PREP.pdf, trang 1]` — khớp lời giảng viên buổi 3 `[IMPORTANT_NOTES.md mục 5]` |
| Tài liệu được mang | **2 tờ A4 viết tay** `[EXAM_PREP.pdf, trang 1]` |
| Chuẩn đầu ra | Đề không ghi mã |
| Phạm vi thi | Bài 1, 2A, 2B, 3A, 3B, 4, 5, 6 + 4 bài lab + ý chính bài "Quản lý rủi ro" và "Xu thế an ninh thông tin" `[EXAM_PREP.pdf]` |

### 2.2. Trọng số theo chương

Tính trên **7 câu có trong đề** (1,75 điểm). `█` ≈ 0,25 điểm.

| Chương | Điểm | Số câu | Tỉ lệ 7 câu | |
|---|---:|---:|---:|---|
| Ch1 — Tổng quan | 0,50 | 2 | 2/7 | `██` |
| Ch2A — Các giải thuật mã hoá | 0,50 | 2 | 2/7 | `██` |
| Ch2B — Chứng thực dữ liệu | 0,50 | 2 | 2/7 | `██` |
| Ch4 — Các nguy cơ bảo mật trên hệ thống | 0,25 | 1 | 1/7 | `█` |
| Ch3A, Ch3B, Ch5, Ch6, các lab | 0 | 0 | 0 | không xuất hiện trong 7 câu này — **nhưng nằm trong phạm vi ôn tập** |
| **Tổng** | **1,75** | **7** | 7/7 | |

### 2.3. Trọng số theo mục

| Chương | Mục | Câu | Điểm |
|---|---|---|---:|
| Ch2A | 3.5 Mã Playfair | 05, 06 | 0,50 |
| Ch2B | 3 Hàm băm — Các công dụng cơ bản | 02, 07 | 0,50 |
| Ch1 | Các kỹ thuật tấn công cơ bản — Eavesdropping | 03 | 0,25 |
| Ch1 | Lý lịch của những kẻ tấn công | 04 | 0,25 |
| Ch4 | Chạy ứng dụng — Keylogger | 01 | 0,25 |
| | **Tổng** | 7 câu | **1,75** |

Hai mục "đáng tiền" (Playfair, 6 công dụng của hàm băm) đều là mục có thể **luyện đến chắc điểm**.

### 2.4. Theo dạng câu

| Dạng câu | Câu | Điểm |
|---|---|---:|
| Nhận diện khái niệm | 01, 02, 03, 04, 07 | 1,25 |
| Mô phỏng giải thuật | 05, 06 | 0,50 |
| Phát biểu đúng/sai · Sắp thứ tự · Phân tích code · Tính toán · Điền thuật ngữ | — | 0 |
| **Tổng** | 7 | **1,75** |

Hệ quả: đề là trắc nghiệm nhưng có **câu phải tính tay** (Playfair) — cần giấy nháp và luyện trước. Câu "nhận diện" không chỉ hỏi định nghĩa mà còn **đọc ký hiệu và sơ đồ** (câu 02, 07).

### 2.5. Theo mức nhận thức

| Mức | Câu | Điểm |
|---|---|---:|
| Nhớ | 01, 04 | 0,50 |
| Hiểu | 02, 03, 07 | 0,75 |
| Vận dụng | 05, 06 | 0,50 |
| Phân tích | — | 0 |
| **Tổng** | 7 | **1,75** |

### 2.6. Ma trận chương × dạng câu

| Chương | Nhận diện khái niệm | Mô phỏng giải thuật | Tổng |
|---|---:|---:|---:|
| Ch1 | 0,50 | — | 0,50 |
| Ch2A | — | 0,50 | 0,50 |
| Ch2B | 0,50 | — | 0,50 |
| Ch4 | 0,25 | — | 0,25 |
| **Tổng** | **1,25** | **0,50** | **1,75** |

### 2.7. Chưa xuất hiện trong đề

Chỉ 7/40 câu được thấy, nên **gần như mọi thứ đều "chưa xuất hiện"** — bảng dưới chỉ liệt kê theo phạm vi của `EXAM_PREP.pdf`. *Một đề mẫu chưa đầy đủ không chứng minh mục nào không thi.*

| Chương | Mục thuộc phạm vi ôn tập nhưng chưa có câu nào |
|---|---|
| Ch1 | Cryptanalysis, Password Pilfering, Identity Spoofing, Intrusion, Denial of Service · thứ tự hành động của hacker · mô hình bảo mật cơ bản, phòng thủ theo chiều sâu |
| Ch2A | Phân loại giải thuật · mã thay thế đơn giản · mã dịch chuyển · DES · AES |
| Ch2B | MAC · MD5, SHA · chữ ký số (tạo và kiểm tra) |
| Ch3A, Ch3B | Toàn bộ |
| Ch4 | Các kỹ thuật crack mật khẩu · leo thang đặc quyền · Spyware · NTFS, steganography · xoá dấu vết |
| Ch5 | Toàn bộ (định nghĩa, phân loại, vòng đời, cấu trúc, phân tích tĩnh/động, phòng chống) |
| Ch6 | Toàn bộ (các kiểu mạng, chuẩn, SSID, chứng thực, WEP, mối đe doạ, phòng chống) |
| Lab & bài bổ sung | Lab 1–4 · ý chính bài Quản lý rủi ro, Xu thế an ninh thông tin |

### 2.8. Ưu tiên ôn

> **Suy luận từ đề mẫu và `EXAM_PREP.pdf`, không phải lời giảng viên.**

1. **6 công dụng của hàm băm + 4 cách dùng mã hoá** — 2/7 câu cùng một cụm, cả dạng đọc biểu thức lẫn đọc sơ đồ. Luyện: với mỗi công thức (a–f), tự ghi nó cho bảo mật / chứng thực / chữ ký số hay không. Bài mẫu: [B2B s55].
2. **Playfair** — 2/7 câu vận dụng, tính tay. Luyện dựng ma trận với khoá **có ký tự lặp** và mã hoá một cụm cặp ký tự. Bài mẫu: [B2A s72–73]; ví dụ chạy sẵn: [B2A s34].
3. **Bài 1 (Eavesdropping, các nhóm attacker)** — 2/7 câu nhớ, nhưng **slide Bài 1 hỏng**. Nguồn thay thế: transcript buổi 1 (`lectures/_raw/`) và danh mục trong `EXAM_PREP.pdf`. Nên xử lý buổi 1 thành note.
4. **Keylogger / Spyware và biện pháp phòng chống** — 1/7 câu; ôn kèm phần phòng chống [B4 s43–44, s48–49].
5. **Tình huống Hybrid Working** — đề dùng một tình huống dài nên có thể hỏi rộng qua Ch4, Ch5, Ch6 và Lab 1–3. Ôn theo hướng **dấu hiệu → nguyên nhân → biện pháp** (bảng ở mục 1).
6. **2 tờ A4 viết tay:** dồn chỗ nhớ máy móc — 6 công dụng hàm băm, quy tắc Playfair, bảng WEP/WPA/WPA2 [B6 s16, s30].

---

## 3. Cần xác minh

> ❓ **CẦN XÁC MINH:** Đề mẫu chỉ có **7 / 40 câu** và một tình huống **không có câu hỏi** — trang 3 kết thúc ở "Hãy trả lời các câu hỏi sau:". Có bản đầy đủ không? Nếu có, thêm vào để tính lại Blueprint.

> ❓ **CẦN XÁC MINH:** Tình huống ghi "áp dụng cho các câu từ 01-10", nhưng 01–07 lại là câu độc lập. Có thể đánh số sai (ví dụ 31–40). Nếu tình huống đi kèm ~10 câu thì nó chiếm khoảng **2,5 / 10 điểm** — chỉ là suy đoán, chưa có nguồn.

> ❓ **CẦN XÁC MINH:** Slide **Bài 1 — Tổng quan bị hỏng** (PDF không render được), nên câu 03, 04 không có số slide. Chương lấy từ `EXAM_PREP.pdf`. Cần bản PDF mới.

> ❓ **CẦN XÁC MINH:** Nguồn gốc đề — đầu đề ghi "Học kỳ II (2025-2026)" trong khi lớp học ở HK3 2025–2026, và không ghi giảng viên ra đề. Đây có phải đề giảng viên gửi cho lớp không?

> ❓ **CẦN XÁC MINH:** Nguồn phát hành của `EXAM_PREP.pdf` — file được thả vào repo ngày 2026-09-24, không ghi ai ban hành. Nội dung "2 tờ A4 viết tay" đã chép vào `IMPORTANT_NOTES.md` mục 5 kèm chú thích nguồn này.

- Handout **Lab 1–4** không có trong repo, nên các dòng tình huống gắn với lab (`netstat`, sự kiện 4625, tài khoản Guest) chưa đối chiếu được.
- Đề dùng thuật ngữ `Cyber terrorists`, `Vicious employees` (câu 04) — thuật ngữ này nằm ở Bài 1 nên chưa kiểm được cách slide gọi.

---

## 4. Nguồn slide

| Mã | File |
|---|---|
| B1 | [`Bài 1 - Tổng quan.pdf`](../materials/slides/Ba%CC%80i%201%20-%20To%CC%82%CC%89ng%20quan.pdf) — Bài 1 — Tổng quan · **PDF hỏng, không đọc được** (89 trang trắng) |
| B1B | [`Bài 1B - Mã hoá hiện đại, chứng thực, chữ ký số.pdf`](../materials/slides/Ba%CC%80i%201B%20-%20Ma%CC%83%20hoa%CC%81%20hie%CC%A3%CC%82n%20%C4%91a%CC%A3i%2C%20chu%CC%9B%CC%81ng%20thu%CC%9B%CC%A3c%2C%20chu%CC%9B%CC%83%20ky%CC%81%20so%CC%82%CC%81.pdf) — Bài 1B — Đề thực hành 1B (CrypTool 1), không phải slide bài giảng |
| B2A | [`Bài 2A - Các giải thuật mã hoá.pdf`](../materials/slides/Ba%CC%80i%202A%20-%20Ca%CC%81c%20gia%CC%89i%20thua%CC%A3%CC%82t%20ma%CC%83%20hoa%CC%81.pdf) — Bài 2A — Các giải thuật mã hoá |
| B2B | [`Bài 2B - Chứng thực dữ liệu.pdf`](../materials/slides/Ba%CC%80i%202B%20-%20Chu%CC%9B%CC%81ng%20thu%CC%9B%CC%A3c%20du%CC%9B%CC%83%20lie%CC%A3%CC%82u.pdf) — Bài 2B — Chứng thực dữ liệu |
| B3A | [`Bài 3A - Dò tìm lỗ hổng bảo mật thông tin - Thăm dò.pdf`](../materials/slides/Ba%CC%80i%203A%20-%20Do%CC%80%20ti%CC%80m%20lo%CC%82%CC%83%20ho%CC%82%CC%89ng%20ba%CC%89o%20ma%CC%A3%CC%82t%20tho%CC%82ng%20tin%20-%20Tha%CC%86m%20do%CC%80.pdf) — Bài 3A — Thăm dò |
| B3B | [`Bài 3B - Dò tìm lỗ hổng bảo mật thông tin - Quét mạng.pdf`](../materials/slides/Ba%CC%80i%203B%20-%20Do%CC%80%20ti%CC%80m%20lo%CC%82%CC%83%20ho%CC%82%CC%89ng%20ba%CC%89o%20ma%CC%A3%CC%82t%20tho%CC%82ng%20tin%20-%20Que%CC%81t%20ma%CC%A3ng.pdf) — Bài 3B — Quét mạng |
| B4 | [`Bài 4 - Các nguy cơ bảo mật trên hệ thống.pdf`](../materials/slides/Ba%CC%80i%204%20-%20Ca%CC%81c%20nguy%20co%CC%9B%20ba%CC%89o%20ma%CC%A3%CC%82t%20tre%CC%82n%20he%CC%A3%CC%82%20tho%CC%82%CC%81ng.pdf) — Bài 4 — Các nguy cơ bảo mật trên hệ thống |
| B5 | [`Bài 5 - Mã độc và kỹ thuật phân tích mã độc.pdf`](../materials/slides/Ba%CC%80i%205%20-%20Ma%CC%83%20%C4%91o%CC%A3%CC%82c%20va%CC%80%20ky%CC%83%20thua%CC%A3%CC%82t%20pha%CC%82n%20ti%CC%81ch%20ma%CC%83%20%C4%91o%CC%A3%CC%82c.pdf) — Bài 5 — Mã độc và kỹ thuật phân tích mã độc |
| B6 | [`Bài 6 - Bảo mật mạng không dây.pdf`](../materials/slides/Ba%CC%80i%206%20-%20Ba%CC%89o%20ma%CC%A3%CC%82t%20ma%CC%A3ng%20kho%CC%82ng%20da%CC%82y.pdf) — Bài 6 — Bảo mật mạng không dây |
