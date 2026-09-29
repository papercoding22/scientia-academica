# Hướng dẫn backup: sao lưu CSDL QuanLyKhachSan

`11_Backup.sql` đặt thời gian giữ binlog là 14 ngày. Chạy một lần bằng tài khoản `root` (mục 1).

Sao lưu gồm hai lớp:

1. **Bản sao đầy đủ** tạo bằng `mysqldump` (mục 2 và 3).
2. **Binary log** (binlog) ghi liên tục mọi thay đổi sau bản sao, dùng để phục hồi đến ngay trước thời điểm sự cố.

Các lệnh `mysqldump` chạy ở Terminal (macOS, Linux) hoặc Command Prompt (Windows). Cách phục hồi xem `HUONG_DAN_RESTORE.md`.

## 1. Chuẩn bị (một lần)

**Thư mục sao lưu.** Không để trong thư mục mã nguồn hay thư mục đồng bộ đám mây (OneDrive, Google Drive, …), vì tệp sao lưu chứa dữ liệu cá nhân chưa che (CCCD, SĐT, mật khẩu băm).

| HĐH | Thư mục | Lệnh tạo |
|-----|---------|----------|
| macOS | `/opt/homebrew/var/mysql-backup` | `mkdir -p /opt/homebrew/var/mysql-backup` |
| Windows | `C:\mysql-backup` | `mkdir C:\mysql-backup` |
| Linux | `/var/backups/mysql` | `sudo mkdir -m 700 -p /var/backups/mysql` |

- **macOS:** trên máy Mac chip Intel, Homebrew nằm ở `/usr/local` thay cho `/opt/homebrew`. Đổi đường dẫn trong mọi lệnh ở tài liệu này cho khớp.
- **Windows:** thêm thư mục `bin` của MySQL vào biến môi trường `PATH`, để gõ được `mysql`, `mysqldump` ở bất kỳ đâu.
- **Linux:** các lệnh có `sudo` vì thư mục sao lưu chỉ `root` đọc được. Nếu `root` của MySQL đăng nhập bằng `auth_socket` (mặc định trên Ubuntu), cứ để trống mật khẩu khi được hỏi.

**Binary log.** Xem cấu hình bằng `SELECT @@log_bin, @@binlog_format;`: phải là `1` và `ROW`. Nếu khác, thêm hai dòng sau vào mục `[mysqld]` của tệp cấu hình rồi khởi động lại MySQL:

```ini
log_bin       = binlog
binlog_format = ROW
```

| HĐH | Tệp cấu hình | Khởi động lại |
|-----|--------------|---------------|
| macOS | `/opt/homebrew/etc/my.cnf` | `brew services restart mysql` |
| Windows | `C:\ProgramData\MySQL\MySQL Server <phiên bản>\my.ini` | `services.msc` → dịch vụ MySQL → Restart |
| Linux | Ubuntu / Debian: `/etc/mysql/mysql.conf.d/mysqld.cnf`<br>RHEL / Fedora: `/etc/my.cnf` | `sudo systemctl restart mysql` (RHEL / Fedora: `mysqld`) |

**Giữ binlog 14 ngày.** Chạy `11_Backup.sql` bằng tài khoản `root`, chạy cả file: trong công cụ SQL bạn dùng (DBeaver, MySQL Workbench, …), hoặc ở dòng lệnh `mysql -u root -p < 11_Backup.sql`. Script đặt `binlog_expire_logs_seconds = 1209600` bằng `SET PERSIST`, nên giá trị này không mất khi khởi động lại MySQL.

## 2. Sao lưu thủ công

**Bước 1.** Tạo bản sao đầy đủ (gõ trên một dòng):

macOS:
```bash
mysqldump -u root -p --databases QuanLyKhachSan --add-drop-database --single-transaction --routines --triggers --events --source-data=2 --set-gtid-purged=OFF --result-file=/opt/homebrew/var/mysql-backup/QuanLyKhachSan_full.sql
```

Windows (Command Prompt):
```bat
mysqldump -u root -p --databases QuanLyKhachSan --add-drop-database --single-transaction --routines --triggers --events --source-data=2 --set-gtid-purged=OFF --result-file="C:/mysql-backup/QuanLyKhachSan_full.sql"
```

Linux:
```bash
sudo mysqldump -u root -p --databases QuanLyKhachSan --add-drop-database --single-transaction --routines --triggers --events --source-data=2 --set-gtid-purged=OFF --result-file=/var/backups/mysql/QuanLyKhachSan_full.sql
```

| Tùy chọn | Tác dụng |
|----------|----------|
| `--databases … --add-drop-database` | Tệp sao lưu tự xoá rồi tạo lại CSDL khi phục hồi |
| `--single-transaction` | Chụp dữ liệu nhất quán trong một giao dịch, không khoá bảng InnoDB |
| `--routines --triggers --events` | Kèm hàm, thủ tục, trigger và event (khung nhìn luôn có sẵn) |
| `--source-data=2` | Ghi vị trí binlog lúc sao lưu vào đầu tệp, dùng khi phục hồi đến một thời điểm |
| `--set-gtid-purged=OFF` | Bắt buộc khi `gtid_mode = ON` (`SELECT @@gtid_mode;`), nếu không sẽ không phục hồi được trên chính máy chủ này |
| `--result-file` | Ghi tệp trực tiếp. Tránh dùng `>` trong PowerShell vì PowerShell đổi tệp sang UTF-16 |

**Bước 2.** Kiểm tra tệp vừa tạo: dòng cuối phải là `-- Dump completed …`.

| HĐH | Lệnh |
|-----|------|
| macOS | `tail -1 /opt/homebrew/var/mysql-backup/QuanLyKhachSan_full.sql` |
| Windows | `powershell Get-Content "C:/mysql-backup/QuanLyKhachSan_full.sql" -Tail 1` |
| Linux | `sudo tail -1 /var/backups/mysql/QuanLyKhachSan_full.sql` |

## 3. Sao lưu tự động lúc 02:00 hằng đêm

Mỗi đêm, tác vụ chạy lệnh `mysqldump` của mục 2. Các khối lệnh dưới đây tự tạo tệp lịch; chép cả khối vào Terminal / PowerShell là xong.

Trước tiên, lưu mật khẩu `root` một lần (được mã hoá trong tệp `.mylogin.cnf`), để tác vụ chạy tự động không phải hỏi mật khẩu:

| HĐH | Lệnh |
|-----|------|
| macOS, Windows | `mysql_config_editor set --login-path=qlks --user=root --password` |
| Linux | `sudo -H mysql_config_editor set --login-path=qlks --user=root --password` |

| HĐH | Công cụ | Máy ngủ lúc 02:00 | Máy tắt lúc 02:00 | Tệp tạo ra |
|-----|---------|-------------------|-------------------|------------|
| macOS | launchd | Chạy bù khi máy thức dậy | Bỏ qua | `QuanLyKhachSan_<yyyymmdd>.sql`, mỗi đêm một tệp |
| Windows | Task Scheduler | Chạy bù khi máy thức dậy | Chạy bù khi bật máy | `QuanLyKhachSan_dem.sql`, ghi đè mỗi đêm |
| Linux | systemd timer | Chạy bù khi máy thức dậy | Chạy bù khi bật máy | `QuanLyKhachSan_<yyyymmdd>.sql`, mỗi đêm một tệp |

Trên macOS và Windows, tác vụ chạy dưới tài khoản người dùng nên chỉ chạy khi tài khoản đó đang đăng nhập. Tệp theo ngày không tự xoá, nên thỉnh thoảng dọn tệp cũ. Binlog giữ 14 ngày nên đủ để phục hồi đến thời điểm giữa hai lần sao lưu.

### macOS (launchd)

```bash
mkdir -p ~/Library/LaunchAgents
cat > ~/Library/LaunchAgents/com.qlks.saoluu.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.qlks.saoluu</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>-c</string>
        <string>/opt/homebrew/bin/mysqldump --login-path=qlks --databases QuanLyKhachSan --add-drop-database --single-transaction --routines --triggers --events --source-data=2 --set-gtid-purged=OFF --result-file=/opt/homebrew/var/mysql-backup/QuanLyKhachSan_$(date +%Y%m%d).sql</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/opt/homebrew/var/mysql-backup/saoluu.log</string>
    <key>StandardErrorPath</key>
    <string>/opt/homebrew/var/mysql-backup/saoluu.log</string>
</dict>
</plist>
EOF
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.qlks.saoluu.plist
```

| Việc | Lệnh |
|------|------|
| Chạy thử ngay | `launchctl kickstart gui/$(id -u)/com.qlks.saoluu` |
| Xem lỗi | `cat /opt/homebrew/var/mysql-backup/saoluu.log` |
| Gỡ bỏ | `launchctl bootout gui/$(id -u)/com.qlks.saoluu` rồi xoá tệp `~/Library/LaunchAgents/com.qlks.saoluu.plist` |

### Windows (Task Scheduler)

Chạy trong PowerShell. Nếu báo `Access is denied`, mở PowerShell bằng *Run as administrator*.

```powershell
$lenh = '/c mysqldump --login-path=qlks --databases QuanLyKhachSan --add-drop-database --single-transaction --routines --triggers --events --source-data=2 --set-gtid-purged=OFF --result-file="C:/mysql-backup/QuanLyKhachSan_dem.sql" 2>> C:\mysql-backup\saoluu.log'
Register-ScheduledTask -TaskName QLKS_SaoLuu `
    -Action   (New-ScheduledTaskAction -Execute 'cmd.exe' -Argument $lenh) `
    -Trigger  (New-ScheduledTaskTrigger -Daily -At 2am) `
    -Settings (New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries)
```

`-StartWhenAvailable` là phần giúp chạy bù khi lỡ giờ. Hai cờ `Battery` cho phép chạy cả khi laptop đang dùng pin; nếu thiếu, Windows mặc định bỏ qua tác vụ khi không cắm sạc.

| Việc | Lệnh (PowerShell) |
|------|-------------------|
| Chạy thử ngay | `Start-ScheduledTask -TaskName QLKS_SaoLuu` |
| Xem kết quả | `Get-ScheduledTaskInfo -TaskName QLKS_SaoLuu` (`LastTaskResult` bằng 0 là thành công), lỗi ghi ở `C:\mysql-backup\saoluu.log` |
| Gỡ bỏ | `Unregister-ScheduledTask -TaskName QLKS_SaoLuu -Confirm:$false` |

### Linux (systemd timer)

```bash
sudo tee /etc/systemd/system/qlks-saoluu.service > /dev/null <<'EOF'
[Unit]
Description=Sao luu CSDL QuanLyKhachSan

[Service]
Type=oneshot
User=root
ExecStart=/bin/sh -c 'mysqldump --login-path=qlks --databases QuanLyKhachSan --add-drop-database --single-transaction --routines --triggers --events --source-data=2 --set-gtid-purged=OFF --result-file=/var/backups/mysql/QuanLyKhachSan_$$(date +%%Y%%m%%d).sql'
EOF
sudo tee /etc/systemd/system/qlks-saoluu.timer > /dev/null <<'EOF'
[Unit]
Description=Sao luu QuanLyKhachSan luc 02:00 hang dem

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now qlks-saoluu.timer
```

Trong tệp `.service`, `$$` và `%%` là cách systemd viết một ký tự `$` và `%`. Đừng sửa thành `$` hay `%` đơn. `Persistent=true` là phần giúp chạy bù khi máy tắt lúc 02:00.

| Việc | Lệnh |
|------|------|
| Chạy thử ngay | `sudo systemctl start qlks-saoluu.service` |
| Xem lần chạy kế tiếp | `systemctl list-timers qlks-saoluu.timer` |
| Xem lỗi | `journalctl -u qlks-saoluu.service` |
| Gỡ bỏ | `sudo systemctl disable --now qlks-saoluu.timer` rồi xoá hai tệp trong `/etc/systemd/system/` |
