# IE103.F21.CN1.CNTT Quan Ly Thong Tin - Group 5

- Lê Anh Vũ - 24730245
- Nguyễn Chí Trung - 25730079
- Nguyễn Thị Thùy Dương - 24730186
- Phạm Hữu Duy Khoa - 24730204
- Phạm Trần Khánh Vũ - 24730246

# Information Management Project — Group 5 (2025-2026)

A ride-hailing system demo (inspired by Grab/Gojek) that showcases SQL Server business logic through Stored Procedures, Triggers, Functions, and Cursors via a Django web interface.

URL DEMO: <https://ride-hailing-system-demo-bmfqbuhsefb6f0e8.eastasia-01.azurewebsites.net/>

---

## Tech Stack

| Component | Technology |
|---|---|
| Backend | Django 6.0.5 |
| Database | Azure SQL Database (Microsoft SQL Azure 12.0) |
| DB Driver | pyodbc 5.3.0, mssql-django 1.7.1, ODBC Driver 18 |
| Frontend | Bootstrap 5 (Django Templates) |
| Python | 3.14.x |

---

## Prerequisites

- Python 3.10+
- [Microsoft ODBC Driver 18 for SQL Server](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)

**Install ODBC Driver on macOS:**

```bash
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
brew install msodbcsql18
```

**Install ODBC Driver on Ubuntu/Debian:**

```bash
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18
```

---

## Project Structure

```
doan_qltt_2026_nhom5/
├── booking/            # Main app (views, urls)
├── config/             # Django settings, db config
├── templates/          # HTML templates (Django + Bootstrap 5)
├── static/             # Static CSS, JS
├── sql/                # SQL source files (schema, SP, triggers, functions, cursors, sample data)
├── venv/               # Python virtual environment
├── .env                # Environment variables — DO NOT commit or share publicly
├── .env.example        # Configuration template (no real credentials)
├── requirements.txt
└── manage.py
```

---

## Getting Started

### 1. Clone the repository

```bash
git clone <repo-url>
cd doan_qltt_2026_nhom5
```

### 2. Create and activate a virtual environment

```bash
python3 -m venv venv
source venv/bin/activate        # macOS/Linux
# venv\Scripts\activate         # Windows
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure environment variables

```bash
cp .env.example .env
```

Open `.env` and fill in the Azure SQL credentials — contact the team lead to obtain them:

```env
DB_NAME=<database name>
DB_USER=<username>
DB_PASSWORD=<password>
DB_HOST=<server>.database.windows.net
DB_PORT=1433

SECRET_KEY=<django secret key>
DEBUG=True
```

> `.env` is listed in `.gitignore` and must never be committed to the repository.

### 5. Run the development server

```bash
python manage.py migrate
python manage.py runserver
```

Open: **<http://127.0.0.1:8000>**

---

## Daily Usage (after initial setup)

```bash
source venv/bin/activate
python manage.py runserver
```

Open: **<http://127.0.0.1:8000>**

> No additional services need to be started — Azure SQL is always available on the cloud.

---

## Architecture

```
Browser
    ↓
Django Templates (HTML + Bootstrap 5)
    ↓
Django Views (Python — raw SQL, no ORM)
    ↓
Azure SQL Database
    ↓ (automatically)
Triggers / Functions / Cursors
```

All business logic (SPs, Triggers, Functions, Cursors) lives inside Azure SQL Database. Django only calls them and displays the results.

---

## Database

The database is hosted on **Azure SQL Database** (`ql-datxecongnghe.database.windows.net`, DB `QL_DatXeCongNghe`).

### Schema — Main Tables (13)

| Table | PK | Description |
|---|---|---|
| KHACHHANG | Ma_Khach_Hang CHAR(10) | Customers |
| TAIXE | Ma_Tai_Xe CHAR(10) | Drivers |
| BANGGIA | Ma_Bang_Gia CHAR(10) | Pricing table |
| VOUCHER | Ma_Voucher CHAR(10) | Discount codes |
| CUOCXE | Ma_Cuoc_Xe CHAR(10) | Ride bookings (central table) |
| DIEMDEN | Ma_Diem_Den CHAR(10) | Pickup / dropoff / stops |
| HANGDOI | Ma_Hang_Doi CHAR(10) | Order pool — driver broadcast |
| VIDIENTU | Ma_Vi CHAR(10) | E-wallets (customer + driver) |
| LICHSUGIAODICH | Ma_Giao_Dich CHAR(10) | Wallet transaction history |
| PHUONGTIEN | Ma_Phuong_Tien CHAR(10) | Driver vehicles |
| DANHGIA | Ma_Danh_Gia CHAR(10) | Trip ratings (1 per booking) |
| THONGBAO | Ma_Thong_Bao CHAR(10) | Notifications |
| KHACHHANG_VOUCHER | (Ma_Khach_Hang, Ma_Voucher) | Customer voucher wallet |

Audit tables: `IMPORT_LOG`, `EXPORT_AUDIT_LOG`

### SQL Objects

| Type | Objects |
|---|---|
| Stored Procedures | `sp_DatXe`, `sp_NhanCuocXe`, `sp_HoanThanhChuyen`, `sp_HuyChuyen`, `sp_NapTienVi` |
| Functions | `fn_TinhCuocPhi` (scalar), `fn_DoanhThuTheoThang` (TVF), `fn_KiemTraVoucher` (scalar) |
| Triggers | `trg_CapNhatDiemUyTin`, `trg_KiemTraSoDuTruocGiaoDich`, `trg_CapNhatLuotVoucher`, `trg_NganXoaCuocXe`, `trg_ThongBaoTrangThai` |
| Cursor SPs | `sp_Cursor_Top50TaiXeDoanhThuNgay`, `sp_Cursor_ThuongTop3KhachHang` |
| Security Views | `vw_KhachHang_BaoCao`, `vw_TaiXe_BaoCao`, `vw_CuocXe_Dashboard`, `vw_DoanhThu_Dashboard`, `vw_HieuSuatTaiXe_Dashboard`, `vw_OrderPool_Dashboard` |

### Security

Database users follow a least-privilege model with role-based access:

| User | Role | Access |
|---|---|---|
| `dba_admin` | db_owner | Full access |
| `app_ridehailing_svc` | role_app_service | EXEC all SPs/Functions |
| `svc_customer_api` | role_customer_module | Customer SPs |
| `svc_driver_api` | role_driver_module | Driver SPs + SELECT CUOCXE/DIEMDEN |
| `user_tableau` | role_readonly_report | SELECT `vw_*` views only |
| `user_analyst` | role_readonly_report | SELECT `vw_*` views only |
| `user_backup_job` | role_backup_operator | Backup only |

Dynamic Data Masking applied to: `KHACHHANG.SDT`, `KHACHHANG.Email`, `TAIXE.SDT`, `VIDIENTU.So_Du`.

SQL source files are stored in the `sql/` directory for version control and project submission.

---

## Demo Pages

| URL | Page | Content |
|---|---|---|
| `/` | Dashboard | Live KPI cards (drivers ready, trips, revenue) |
| `/drivers/` | Drivers | Full driver list with status filter |
| `/trips/` | Trips | Full trip list with status filter |
| `/demo/procedures/` | Stored Procedures | 5 SPs — `sp_DatXe`, `sp_NhanCuocXe`, `sp_HoanThanhChuyen`, `sp_HuyChuyen`, `sp_NapTienVi` |
| `/demo/triggers/` | Triggers | 5 Triggers — rating, balance check, voucher count, delete guard, notification |
| `/demo/functions/` | Functions | 3 Functions — `fn_TinhCuocPhi` (scalar), `fn_DoanhThuTheoThang` (TVF), `fn_KiemTraVoucher` (BIT) |
| `/demo/cursors/` | Cursors | 2 Cursor SPs — TOP 50 driver notifications, TOP 3 customer rewards |
| `/demo/security/` | Security | 6 Security Views + DDM column masking info + Users/Roles |

## Demo Flow

Each feature is demonstrated in 5 steps (B1→B5):

| Step | Description |
|---|---|
| B1 | Business requirement explanation |
| B2 | Display the exact SQL / SP / Function to be executed |
| B3 | **BEFORE** data — loaded live from Azure SQL |
| B4 | Execute button — makes a real call to Azure SQL |
| B5 | **AFTER** data — reloaded from Azure SQL after execution |

> Functions are read-only — B5 shows the function's return value instead of a state change.

---

## Troubleshooting

**ODBC Driver not found:**

```
django.db.utils.InterfaceError: ('IM002', ...)
```

→ Install ODBC Driver 18 as described in the Prerequisites section.

**Azure SQL connection error (timeout / firewall):**

```
django.db.utils.OperationalError: ('HYT00', ...)
```

→ Your IP address has not been whitelisted in the Azure Portal firewall rules. Contact the team lead to get access.

**Port 8000 already in use:**

```bash
python manage.py runserver 8080
# Open http://127.0.0.1:8080
```

---

## Group 5 — Information Management, UIT 2025-2026
