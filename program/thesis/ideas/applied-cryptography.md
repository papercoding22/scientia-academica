# Ý tưởng: Mật mã học ứng dụng (Applied cryptography)

| | |
|---|---|
| Ngày ghi | 2026-10-01 |
| **Nảy ra từ** | môn `IE105`, buổi 02 (2026-07-15) — nhắc lại ở buổi 1 và 3 |
| Trạng thái | 💡 mới ghi |
| Đánh giá khả thi | ❓ |

**Trạng thái:** `💡 mới ghi` · `🔍 đang tìm hiểu` · `✅ ứng viên mạnh` · `❌ đã loại`

---

## Vấn đề muốn giải quyết

Giảng viên IE105 gợi ý mật mã học là hướng làm đồ án / khoá luận tốt nghiệp được. Chưa có bài toán cụ thể —
đây mới là **một hướng**, cần thu hẹp thành vấn đề thật trước khi đánh giá.

> *IE105, buổi 2, 2026-07-15 — "Giả sử như là sau này mấy em thích về cái mật mã này thì em có thể là làm
> cái đồ án hoặc là […] đồ án tốt nghiệp […] lúc đó phải chú ý cái gì mình tạo ra một giải thuật thì cần phải
> bảo mật đương nhiên rồi. Nhưng mà cái công khai dễ hiểu […] Đặc biệt là phải làm sao chạy được trên máy tính"*
>
> *IE105, buổi 3, 2026-07-29 — "bạn nào quan tâm, bạn nào thích thì sau này có thể đi tìm hiểu sâu về mã hoá
> mật mã, có thể làm đồ án, làm đồ án tốt nghiệp, khoá luận tốt nghiệp"*

Ba tiêu chí giảng viên nêu cho một giải thuật tự thiết kế — trùng với yêu cầu ở slide Bài 2A s22:
bảo mật cao · công khai, dễ hiểu (bảo mật chốt vào khoá) · triển khai được trên thiết bị điện tử.

Ví dụ giảng viên chiếu trên lớp: đồ án môn của sinh viên chính quy — ứng dụng mã hoá/giải mã Playfair và Hill,
nhập/xuất file. Quy mô đó là **đồ án môn**, chưa đủ cho khoá luận.

## Vì sao tôi quan tâm

❓ — người dùng tự điền. Gợi ý liên hệ công việc dev: quản lý secret, ký JWT, mã hoá dữ liệu nhạy cảm khi lưu.

## Hướng làm

❓ chưa thu hẹp. Hướng khả dĩ `ngoài bài giảng`, chỉ để có điểm bắt đầu: đánh giá cách dùng mã hoá sai trong
mã nguồn thực tế (khoá cứng trong code, ECB, hash mật khẩu yếu) · công cụ dạy mật mã cổ điển → hiện đại.

---

## Đánh giá

| Tiêu chí | Đánh giá | Ghi chú |
|---|---|---|
| Khớp hướng chuyên ngành | ❓ | Xem `program/specialization/criteria.md` |
| Làm được khi vừa đi làm | ❓ | |
| Tận dụng kinh nghiệm đi làm | ❓ | |
| Phạm vi vừa một kỳ | ❓ | |
| Có GVHD phù hợp | ❓ | GV Tô Nguyễn Nhật Quang (IE105) dạy mảng này |

## Môn cần học trước

- `IE105` — Bài 2A (mã hoá), 2B (chứng thực, chữ ký số): [note L02](../../../semesters/2025-2026-S3/IE105-information-assurance-security/lectures/L02-classical-ciphers.md)

## Đã có ai làm chưa

- ❓

---

## Nếu bị loại

**Lý do loại:** ❓
*(Giữ file lại, không xoá — biết vì sao đã loại cũng là thông tin.)*
