# Hướng dẫn restore: phục hồi CSDL QuanLyKhachSan

Phục hồi dùng tệp tạo theo `HUONG_DAN_BACKUP.md`:

| HĐH | Thư mục | Sao lưu thủ công | Sao lưu tự động |
|-----|---------|------------------|-----------------|
| macOS | `/opt/homebrew/var/mysql-backup` | `QuanLyKhachSan_full.sql` | `QuanLyKhachSan_<yyyymmdd>.sql` |
| Windows | `C:\mysql-backup` | `QuanLyKhachSan_full.sql` | `QuanLyKhachSan_dem.sql` |
| Linux | `/var/backups/mysql` | `QuanLyKhachSan_full.sql` | `QuanLyKhachSan_<yyyymmdd>.sql` |

Các lệnh dưới đây dùng `QuanLyKhachSan_full.sql`; phục hồi từ bản sao tự động thì đổi tên tệp.

**Chạy lệnh:**

- **macOS, Linux:** chạy trong Terminal. Mac chip Intel thay `/opt/homebrew` bằng `/usr/local`.
- **Windows:** chạy trong Command Prompt, không dùng PowerShell vì PowerShell không có toán tử `<`. Thư mục `bin` của MySQL phải nằm trong `PATH`.
- **Linux:** các lệnh có `sudo` vì thư mục sao lưu và thư mục dữ liệu MySQL chỉ `root` đọc được. Nếu `root` của MySQL đăng nhập bằng `auth_socket` (mặc định trên Ubuntu), cứ để trống mật khẩu khi được hỏi.

## 1. Phục hồi toàn bộ

Tệp sao lưu tự xoá rồi tạo lại `QuanLyKhachSan`: mọi dữ liệu hiện có bị thay bằng dữ liệu lúc sao lưu.

| HĐH | Lệnh |
|-----|------|
| macOS | `mysql -u root -p < /opt/homebrew/var/mysql-backup/QuanLyKhachSan_full.sql` |
| Windows (Command Prompt) | `mysql -u root -p < "C:/mysql-backup/QuanLyKhachSan_full.sql"` |
| Linux | `sudo sh -c 'mysql -u root -p < /var/backups/mysql/QuanLyKhachSan_full.sql'` |

Role, tài khoản và quyền nằm ở CSDL hệ thống `mysql`, không có trong tệp sao lưu. Phục hồi trên cùng máy chủ thì chúng vẫn còn nguyên; phục hồi sang máy khác thì chạy thêm `setup_database/08_Security_Roles.sql`.

## 2. Phục hồi đến một thời điểm

Dùng khi sự cố xảy ra sau lần sao lưu gần nhất (ví dụ lỡ tay `DELETE`). Bản sao đưa dữ liệu về lúc sao lưu, rồi binlog áp lại các thay đổi từ lúc đó đến ngay trước sự cố.

**1.** Phục hồi toàn bộ như mục 1, từ bản sao gần nhất trước sự cố.

**2.** Lấy vị trí binlog lúc sao lưu, được ghi ở đầu tệp sao lưu:

| HĐH | Lệnh |
|-----|------|
| macOS | `grep -m1 "SOURCE_LOG_POS" /opt/homebrew/var/mysql-backup/QuanLyKhachSan_full.sql` |
| Windows | `findstr "SOURCE_LOG_POS" "C:/mysql-backup/QuanLyKhachSan_full.sql"` |
| Linux | `sudo grep -m1 "SOURCE_LOG_POS" /var/backups/mysql/QuanLyKhachSan_full.sql` |

Kết quả có dạng:

```
-- CHANGE REPLICATION SOURCE TO SOURCE_LOG_FILE='binlog.000007', SOURCE_LOG_POS=156418;
```

**3.** Tìm thời điểm sự cố. Chạy `12_Restore.sql` bằng tài khoản `root` (trong công cụ SQL bạn dùng, hoặc `mysql -u root -p -t < 12_Restore.sql`): hai kết quả `SHOW BINARY LOGS` và `TienToTepBinlog` cho biết tên và thư mục các tệp binlog. Thường là `/opt/homebrew/var/mysql/` (macOS), `C:\ProgramData\MySQL\MySQL Server <phiên bản>\Data\` (Windows), `/var/lib/mysql/` (Linux).

macOS:
```bash
mysqlbinlog --base64-output=DECODE-ROWS --verbose --database=quanlykhachsan /opt/homebrew/var/mysql/binlog.000007 | grep -n -B12 "### DELETE FROM"
```

Windows (Command Prompt): ghi ra tệp rồi mở `binlog.txt`, tìm `### DELETE FROM`:
```bat
mysqlbinlog --base64-output=DECODE-ROWS --verbose --database=quanlykhachsan "<thư mục binlog>\binlog.000007" > binlog.txt
```

Linux:
```bash
sudo mysqlbinlog --base64-output=DECODE-ROWS --verbose --database=QuanLyKhachSan /var/lib/mysql/binlog.000007 | grep -n -B12 "### DELETE FROM"
```

Dòng `#260926 10:30:00 server id 1 …` ngay phía trên lệnh `DELETE` là thời điểm sự cố. Lấy mốc trước đó một giây (`2026-09-26 10:29:59`).

**4.** Áp binlog từ vị trí sao lưu đến ngay trước sự cố:

macOS:
```bash
mysqlbinlog --skip-gtids --database=quanlykhachsan --start-position=156418 --stop-datetime="2026-09-26 10:29:59" /opt/homebrew/var/mysql/binlog.000007 | mysql -u root -p
```

Windows (Command Prompt):
```bat
mysqlbinlog --skip-gtids --database=quanlykhachsan --start-position=156418 --stop-datetime="2026-09-26 10:29:59" "<thư mục binlog>\binlog.000007" | mysql -u root -p
```

Linux:
```bash
sudo sh -c 'mysqlbinlog --skip-gtids --database=QuanLyKhachSan --start-position=156418 --stop-datetime="2026-09-26 10:29:59" /var/lib/mysql/binlog.000007 | mysql -u root -p'
```

| Tùy chọn | Tác dụng |
|----------|----------|
| `--start-position` | Vị trí lấy ở bước 2, chỉ áp cho tệp binlog đầu tiên |
| `--stop-datetime` | Dừng ngay trước sự cố |
| `--database` | Chỉ áp thay đổi của `QuanLyKhachSan`, không áp lại lần hai cho CSDL khác. Viết **thường** (`quanlykhachsan`) trên macOS / Windows, vì ở đó binlog ghi tên CSDL bằng chữ thường (`lower_case_table_names` = 1 hoặc 2); viết hoa sẽ không khớp dòng nào. Linux giữ nguyên `QuanLyKhachSan`. |
| `--skip-gtids` | Bắt buộc khi `gtid_mode = ON`. Thiếu cờ này, MySQL coi các giao dịch là đã có và bỏ qua hết mà không báo lỗi. |

Nếu từ lúc sao lưu đã sang tệp binlog mới, liệt kê đủ các tệp theo thứ tự: `… binlog.000007 binlog.000008 | mysql -u root -p`.

