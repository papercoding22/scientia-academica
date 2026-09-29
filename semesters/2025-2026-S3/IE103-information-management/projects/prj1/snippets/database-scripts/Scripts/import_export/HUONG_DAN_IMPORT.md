# Hướng dẫn import: nhập bảng giá phòng từ CSV

| Tệp | Nội dung |
|-----|----------|
| `09_Import.sql` | Nhập bảng giá phòng từ CSV vào `BANG_GIA_PHONG`: nhập cả tệp hoặc không nhập dòng nào |
| `data/bang_gia_phong.csv` | 10 dòng hợp lệ (`BG00000011` – `BG00000020`, năm 2028) |

Cần chạy `setup_database/01` → `07` trước. Chạy `09_Import.sql` bằng tài khoản `root`, chạy cả file: trong công cụ SQL bạn dùng (DBeaver, MySQL Workbench, …), hoặc ở dòng lệnh `mysql -u root -p -t < 09_Import.sql`.

## 1. Chuẩn bị (một lần)

### 1.1. Thư mục `secure_file_priv`

Script đọc tệp CSV bằng hàm `LOAD_FILE()`, hàm này chỉ đọc được tệp nằm trong thư mục `secure_file_priv` của máy chủ MySQL. Script tự lấy thư mục này từ `@@secure_file_priv`, nên không cần sửa đường dẫn trong script. Xem thư mục bằng:

```sql
SELECT @@secure_file_priv;
```

| HĐH | Giá trị thường gặp | Việc cần làm |
|-----|--------------------|--------------|
| macOS (Homebrew) | `NULL` (tính năng đang tắt) | Bật như dưới đây |
| Windows (MySQL Installer) | `C:\ProgramData\MySQL\MySQL Server <phiên bản>\Uploads\` | Không cần làm gì |
| Linux (gói deb / rpm) | `/var/lib/mysql-files/` | Không cần làm gì |

**Bật trên macOS.** Tạo thư mục:

```bash
mkdir -p /opt/homebrew/var/mysql-files
```

Thêm dòng sau vào mục `[mysqld]` của `/opt/homebrew/etc/my.cnf`, rồi chạy `brew services restart mysql`:

```ini
secure_file_priv = /opt/homebrew/var/mysql-files
```

Trên Mac chip Intel, thay `/opt/homebrew` bằng `/usr/local` ở cả ba chỗ.

**Muốn dùng thư mục khác** thì trỏ `secure_file_priv` tới thư mục đó trong tệp cấu hình của máy chủ, rồi khởi động lại MySQL. Thư mục phải có sẵn trước khi khởi động lại, nếu không MySQL sẽ không khởi động được. Đường dẫn có dấu cách thì bọc trong ngoặc kép; trên Windows viết bằng dấu `/`.

- **macOS (Homebrew):** thư mục nào thuộc tài khoản của bạn cũng được, không cần cấp quyền, vì `brew services` chạy MySQL bằng chính tài khoản đăng nhập. Tránh `Desktop`, `Documents`, `Downloads`: macOS có thể chặn MySQL chạy nền truy cập ba thư mục này (`Operation not permitted`), trừ khi cấp Full Disk Access cho `mysqld`. Nếu cài MySQL bằng gói DMG của Oracle thì MySQL chạy bằng tài khoản `_mysql`, nên phải cấp quyền đọc thư mục cho tài khoản này.
- **Windows:** cấp quyền đọc / ghi thư mục cho tài khoản chạy dịch vụ MySQL (thường là `NETWORK SERVICE`), nếu không MySQL sẽ báo `Permission denied` (errno 13).
- **Ubuntu:** nên giữ mặc định, vì AppArmor chặn `mysqld` đọc thư mục khác.

### 1.2. Chép tệp CSV vào thư mục đó

Chạy trong thư mục `import_export`:

| HĐH | Lệnh |
|-----|------|
| macOS | `cp data/bang_gia_phong.csv /opt/homebrew/var/mysql-files/` |
| Windows (Command Prompt) | `copy data\bang_gia_phong.csv "C:\ProgramData\MySQL\MySQL Server <phiên bản>\Uploads\"` |
| Linux | `sudo cp data/bang_gia_phong.csv /var/lib/mysql-files/` |

Script nhập tệp có tên ghi ở dòng `SET @tep = 'bang_gia_phong.csv';` đầu `09_Import.sql`.

## 2. Định dạng tệp CSV

- Dòng đầu là tiêu đề. Các cột theo thứ tự `MaBangGia, MaLoaiPhong, HeSo, ApDungTuNgay, DenNgay, DonGia`, mỗi dòng đúng 6 cột.
- Phân cách bằng dấu phẩy, ngày dạng `YYYY-MM-DD`, số thập phân dùng dấu chấm, không có dấu phẩy bên trong ô.
- Tệp lưu từ Excel (xuống dòng CRLF, ô bọc ngoặc kép) vẫn đọc được. Dòng trống bị bỏ qua.

## 3. Cách hoạt động

Script chỉ có một lệnh `INSERT`: đọc cả tệp bằng `LOAD_FILE(CONCAT(@@secure_file_priv, @tep))`, tách thành dòng và cột bằng `JSON_TABLE`, bỏ dòng tiêu đề và dòng trống, rồi thêm thẳng vào `BANG_GIA_PHONG`.

Script không tự kiểm tra dữ liệu. Dòng sai bị chính bảng `BANG_GIA_PHONG` chặn:

| Dữ liệu sai | Bị chặn bởi | Lỗi MySQL |
|-------------|-------------|-----------|
| Ngày không có thật, số sai dạng | Strict mode | 1292, 1366 |
| `MaBangGia` đã có | Khoá chính | 1062 |
| `MaLoaiPhong` không tồn tại | Khoá ngoại | 1452 |
| `DenNgay` trước `ApDungTuNgay`, `HeSo` không dương, `DonGia` âm | Ràng buộc `CHECK` | 3819 |
| Chồng ngày với bảng giá khác của cùng loại phòng | Trigger `trg_BangGia_KhongGiaoNhau` | 1644 |

Vì cả tệp nằm trong một lệnh, chỉ một dòng sai là MySQL báo lỗi và không dòng nào được thêm.

## 4. Kết quả

Với `bang_gia_phong.csv`: thêm 10 dòng `BG00000011` – `BG00000020` vào `BANG_GIA_PHONG`. Xem bằng `SELECT * FROM BANG_GIA_PHONG ORDER BY MaBangGia;`.

- **Chạy lại cùng một tệp:** MySQL báo lỗi 1644 (chồng ngày với chính các dòng đã nhập), không thêm dòng nào. Muốn nhập lại từ đầu thì chạy lại `setup_database/07_Sample_Data.sql`.
- **Không báo lỗi nhưng không thêm dòng nào:** script không đọc được tệp (sai tên, chưa chép vào thư mục `secure_file_priv`, hoặc `secure_file_priv` là `NULL`).

## 5. Ghi chú kỹ thuật

- **Dùng `LOAD_FILE()` thay cho `LOAD DATA INFILE`:** `LOAD DATA INFILE` chỉ nhận đường dẫn viết sẵn trong câu lệnh: không nhận biến hay biểu thức, không chạy được qua `PREPARE` (lỗi 1295) hay trong thủ tục (lỗi 1314). `LOAD_FILE()` là hàm nên nhận được đường dẫn ghép từ `@@secure_file_priv`. Khi không đọc được tệp (kể cả tệp lớn hơn `max_allowed_packet`), hàm trả về `NULL` chứ không báo lỗi.
- **Tách dòng và cột:** nội dung tệp được đổi thành mảng JSON, mỗi dòng một mảng, mỗi ô một phần tử, sau khi escape các ký tự `\`, `"` và tab. Script tự bỏ `\r`, khoảng trắng và dấu `"` ở từng cột, nên tệp CRLF và ô bọc ngoặc kép từ Excel vẫn đọc được. Các cột của `JSON_TABLE` khai báo `utf8mb4` để tiếng Việt đọc đúng dù phiên kết nối dùng bảng mã khác.
