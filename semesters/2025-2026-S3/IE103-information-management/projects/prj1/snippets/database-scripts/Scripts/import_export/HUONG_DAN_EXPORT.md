# Hướng dẫn export: xuất báo cáo ra CSV

`10_Export.sql` xuất doanh thu theo tháng và danh sách khách đang lưu trú ra hai tệp CSV. Cần chạy `setup_database/01` → `07` trước. Chạy bằng tài khoản `root`, chạy cả file: trong công cụ SQL bạn dùng (DBeaver, MySQL Workbench, …), hoặc ở dòng lệnh `mysql -u root -p -t < 10_Export.sql`.

## 1. Chuẩn bị (một lần): thư mục `secure_file_priv`

`SELECT … INTO OUTFILE` chỉ ghi được tệp vào thư mục `secure_file_priv` của máy chủ MySQL. Script tự lấy thư mục này từ `@@secure_file_priv`, nên không cần sửa gì trong script. Xem thư mục bằng:

```sql
SELECT @@secure_file_priv;
```

| HĐH | Giá trị thường gặp (nơi ghi tệp xuất) | Việc cần làm |
|-----|---------------------------------------|--------------|
| macOS (Homebrew) | `NULL` (tính năng đang tắt) | Bật như dưới đây |
| Windows (MySQL Installer) | `C:\ProgramData\MySQL\MySQL Server <phiên bản>\Uploads\` | Không cần làm gì |
| Linux (gói deb / rpm) | `/var/lib/mysql-files/` | Không cần làm gì |

Máy đã chuẩn bị cho import (`HUONG_DAN_IMPORT.md`) thì không cần làm gì thêm.

**Bật trên macOS.** Tạo thư mục:

```bash
mkdir -p /opt/homebrew/var/mysql-files
```

Thêm dòng sau vào mục `[mysqld]` của `/opt/homebrew/etc/my.cnf`, rồi chạy `brew services restart mysql`:

```ini
secure_file_priv = /opt/homebrew/var/mysql-files
```

Trên Mac chip Intel, thay `/opt/homebrew` bằng `/usr/local` ở cả ba chỗ.

**Linux:** tệp xuất thuộc về người dùng `mysql`, nên xem và lấy ra bằng `sudo`:

```bash
sudo ls /var/lib/mysql-files
sudo cp /var/lib/mysql-files/*.csv ~/
```

**Muốn ghi vào thư mục khác** thì trỏ `secure_file_priv` tới thư mục đó trong tệp cấu hình của máy chủ, rồi khởi động lại MySQL. Thư mục phải có sẵn trước khi khởi động lại, nếu không MySQL sẽ không khởi động được. Đường dẫn có dấu cách thì bọc trong ngoặc kép; trên Windows viết bằng dấu `/`.

- **macOS (Homebrew):** thư mục nào thuộc tài khoản của bạn cũng được, không cần cấp quyền, vì `brew services` chạy MySQL bằng chính tài khoản đăng nhập. Tránh `Desktop`, `Documents`, `Downloads`: macOS có thể chặn MySQL chạy nền truy cập ba thư mục này (`Operation not permitted`), trừ khi cấp Full Disk Access cho `mysqld`. Nếu cài MySQL bằng gói DMG của Oracle thì MySQL chạy bằng tài khoản `_mysql`, nên phải cấp quyền ghi thư mục cho tài khoản này.
- **Windows:** cấp quyền ghi thư mục cho tài khoản chạy dịch vụ MySQL (thường là `NETWORK SERVICE`), nếu không MySQL sẽ báo `Permission denied` (errno 13).
- **Ubuntu:** nên giữ mặc định, vì AppArmor chặn `mysqld` ghi vào thư mục khác.

## 2. Tệp xuất ra

Mỗi lần chạy ghi **hai tệp mới**, tên kèm thời điểm chạy. `INTO OUTFILE` không ghi đè tệp đã có, nên tệp cũ vẫn giữ nguyên.

| Tệp | Cột | Dữ liệu |
|-----|-----|---------|
| `doanh_thu_theo_thang_<yyyymmdd_hhmmss>.csv` | `Thang, SoHoaDon, DoanhThu` | Hoá đơn `DaThanhToan`, gộp theo tháng lập; `DoanhThu` là tổng `TongTien` |
| `khach_dang_luu_tru_<yyyymmdd_hhmmss>.csv` | `HoTen, CCCD, SDT, SoPhong, NgayCheckIn, NgayCheckOut` | Khách có phiếu `DangO`, mỗi phòng một dòng |

**Quy tắc bảo mật:** tệp xuất ra ngoài hệ thống chỉ chứa số tổng hợp, hoặc dữ liệu cá nhân đã che. CCCD và SĐT chỉ giữ 4 ký tự cuối (`079201000001` → `********0001`). Dữ liệu gốc trong CSDL không đổi.

**Định dạng tệp:** UTF-8 có BOM (để Excel hiện đúng tiếng Việt), phân cách bằng dấu phẩy, xuống dòng CRLF, dòng đầu là tiêu đề, ô không bọc ngoặc kép.

## 3. Kết quả

Script trả về bảng `TepDaGhi` gồm đường dẫn hai tệp vừa ghi. Nếu `secure_file_priv` là `NULL` (chưa cấu hình, mục 1), script dừng ở lệnh `PREPARE` với lỗi 1064 và không ghi tệp nào.

## 4. Ghi chú kỹ thuật

- **BOM viết thẳng trong câu lệnh** (`_utf8mb4 0xEFBBBF`): nếu đi qua biến, BOM mang collation của phiên, khác collation của cột, nên `UNION` báo lỗi 1271. Các ô không bọc ngoặc kép vì BOM phải là ba byte đầu tiên của tệp.
- **Tên tệp được ghép sẵn rồi chạy bằng `PREPARE`**, vì `INTO OUTFILE` chỉ nhận tên tệp là hằng chuỗi.
- **Trên Windows,** `@@secure_file_priv` trả về đường dẫn có dấu `\`; script đổi sang `/` trước khi ghép tên tệp.
