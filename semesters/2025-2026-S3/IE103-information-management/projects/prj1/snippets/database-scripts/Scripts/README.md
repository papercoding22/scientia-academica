# Scripts — Quản lý khách sạn (MySQL 8.0.26+)

```
setup_database/            Cài đặt CSDL: chạy 01 → 08 theo thứ tự
import_export/
  09_Import.sql            Nhập bảng giá phòng từ CSV
  10_Export.sql            Xuất báo cáo ra CSV
  data/                    CSV mẫu để nhập
  HUONG_DAN_IMPORT.md      Hướng dẫn import
  HUONG_DAN_EXPORT.md      Hướng dẫn export
backup_restore/
  11_Backup.sql            Giữ binlog 14 ngày
  12_Restore.sql           Liệt kê tệp binlog để phục hồi đến một thời điểm
  HUONG_DAN_BACKUP.md      Hướng dẫn backup (thủ công và tự động)
  HUONG_DAN_RESTORE.md     Hướng dẫn restore
```

Mọi file `.sql` đều chạy bằng tài khoản `root`, không cần cấp thêm quyền: chạy cả file trong công cụ SQL bạn dùng (DBeaver, MySQL Workbench, …), hoặc ở dòng lệnh `mysql -u root -p -t < tên_tệp.sql`. Script chỉ chứa lệnh thực hiện chức năng, không có phần kiểm tra. Cách chuẩn bị, các lệnh Terminal / Command Prompt và kết quả mong đợi của 09 – 12 nằm trong bốn tệp hướng dẫn, có đủ macOS, Windows và Linux.

## 1. Cài đặt CSDL

| # | File | Nội dung |
|---|------|----------|
| 01 | `01_Create_Database.sql` | CSDL + 14 bảng + chỉ mục |
| 02 | `02_Functions.sql` | 5 hàm (mục 4.1.3) |
| 03 | `03_Views.sql` | 3 khung nhìn (mục 4.1.5) |
| 04 | `04_Triggers.sql` | 13 trigger vật lý (mục 4.1.2) |
| 05 | `05_Cursors.sql` | 2 thủ tục bao gói con trỏ (mục 4.1.4) |
| 06 | `06_Procedures.sql` | 12 thủ tục nội tại + 5 thủ tục báo cáo |
| 07 | `07_Sample_Data.sql` | Dữ liệu mẫu |
| 08 | `08_Security_Roles.sql` | Xác thực, role, user, quyền |

**File 01 xoá sạch CSDL** (`DROP DATABASE`). Chạy lại riêng 02, 05 hoặc 06 thì phải chạy lại 08, vì MySQL tự thu hồi quyền `EXECUTE` khi xoá thủ tục hay hàm.

## 2. Vận hành

| Việc | Script | Hướng dẫn |
|------|--------|-----------|
| Import | `09_Import.sql` | [HUONG_DAN_IMPORT.md](import_export/HUONG_DAN_IMPORT.md): cấu hình `secure_file_priv`, định dạng CSV, các lỗi MySQL chặn khi nhập |
| Export | `10_Export.sql` | [HUONG_DAN_EXPORT.md](import_export/HUONG_DAN_EXPORT.md): nơi ghi tệp, nội dung tệp xuất, quy tắc che dữ liệu |
| Backup | `11_Backup.sql` | [HUONG_DAN_BACKUP.md](backup_restore/HUONG_DAN_BACKUP.md): sao lưu thủ công, sao lưu tự động lúc 02:00 (launchd / Task Scheduler / systemd) |
| Restore | `12_Restore.sql` | [HUONG_DAN_RESTORE.md](backup_restore/HUONG_DAN_RESTORE.md): phục hồi toàn bộ, phục hồi đến một thời điểm bằng binlog |
