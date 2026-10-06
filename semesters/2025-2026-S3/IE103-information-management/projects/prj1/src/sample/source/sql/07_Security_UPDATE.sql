-- ============================================================
-- FILE: 07_Security.sql
-- MÔ TẢ: An toàn thông tin - Xác thực, Phân quyền,
--         Dynamic Data Masking, Views bảo mật
-- ------------------------------------------------------------
-- PHIÊN BẢN: Azure SQL Database (Contained Database Users)
-- THAY ĐỔI SO VỚI BẢN GỐC:
--   - Phần 1: Đổi CREATE LOGIN + CREATE USER FOR LOGIN
--             → CREATE USER WITH PASSWORD (Contained User)
--             Lý do: Azure SQL Database không hỗ trợ CREATE LOGIN
--             từ context user database. Contained User cho phép
--             xác thực trực tiếp tại database, không cần master.
--   - Toàn bộ Phần 2 → Phần 8: Giữ nguyên 100%
-- ------------------------------------------------------------
-- CÁCH CHẠY: Connect thẳng vào QL_DatXeCongNghe, chạy 1 lần.
--            KHÔNG cần connect vào master.
-- ============================================================

USE QL_DatXeCongNghe;
GO

-- ############################################################
-- PHẦN 1: TẠO CONTAINED DATABASE USERS
-- (Thay thế CREATE LOGIN + CREATE USER FOR LOGIN)
-- ############################################################

-- ============================================================
-- 1.1 DBA Admin (Toàn quyền)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'dba_admin')
    BEGIN
        CREATE USER dba_admin
            WITH PASSWORD = 'Nhom5#AbsoluteAuthority';
        ALTER ROLE db_owner ADD MEMBER dba_admin;
    END
GO

-- ============================================================
-- 1.2 Application Service Account (Chạy app chính)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'app_ridehailing_svc')
    BEGIN
        CREATE USER app_ridehailing_svc
            WITH PASSWORD = 'Nhom5#Lightning2026!';
    END
GO

-- ============================================================
-- 1.3 Customer Module Service
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'svc_customer_api')
    BEGIN
        CREATE USER svc_customer_api
            WITH PASSWORD = 'Nhom5#Phoenix2026!';
    END
GO

-- ============================================================
-- 1.4 Driver Module Service
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'svc_driver_api')
    BEGIN
        CREATE USER svc_driver_api
            WITH PASSWORD = 'Nhom5#Thunder2026!';
    END
GO

-- ============================================================
-- 1.5 Tableau / Analyst (Chỉ đọc báo cáo)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'user_tableau')
    BEGIN
        CREATE USER user_tableau
            WITH PASSWORD = 'Nhom5#Crystal2026!';
    END
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'user_analyst')
    BEGIN
        CREATE USER user_analyst
            WITH PASSWORD = 'Nhom5#Horizon2026!';
    END
GO

-- ============================================================
-- 1.6 Backup Operator
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'user_backup_job')
    BEGIN
        CREATE USER user_backup_job
            WITH PASSWORD = 'Nhom5#Fortress2026!';
    END
GO

PRINT N'✓ Tạo tất cả Contained Users thành công';
GO


-- ############################################################
-- PHẦN 2: TẠO DATABASE ROLES
-- ############################################################

-- ============================================================
-- 2.1 Role cho Application Service
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'role_app_service' AND type = 'R')
CREATE ROLE role_app_service;
GO

-- ============================================================
-- 2.2 Role chỉ đọc báo cáo
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'role_readonly_report' AND type = 'R')
CREATE ROLE role_readonly_report;
GO

-- ============================================================
-- 2.3 Role cho Customer Module
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'role_customer_module' AND type = 'R')
CREATE ROLE role_customer_module;
GO

-- ============================================================
-- 2.4 Role cho Driver Module
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'role_driver_module' AND type = 'R')
CREATE ROLE role_driver_module;
GO

-- ============================================================
-- 2.5 Role cho Backup Operator
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'role_backup_operator' AND type = 'R')
CREATE ROLE role_backup_operator;
GO

PRINT N'✓ Tạo tất cả Database Roles thành công';
GO


-- ############################################################
-- PHẦN 3: GÁN USER VÀO ROLE
-- ############################################################

ALTER ROLE role_app_service     ADD MEMBER app_ridehailing_svc;
ALTER ROLE role_customer_module ADD MEMBER svc_customer_api;
ALTER ROLE role_driver_module   ADD MEMBER svc_driver_api;
ALTER ROLE role_readonly_report ADD MEMBER user_tableau;
ALTER ROLE role_readonly_report ADD MEMBER user_analyst;
ALTER ROLE role_backup_operator ADD MEMBER user_backup_job;
GO

PRINT N'✓ Gán User vào Role thành công';
GO


-- ############################################################
-- PHẦN 4: PHÂN QUYỀN CHI TIẾT
-- ############################################################

-- ============================================================
-- 4.1 role_app_service: EXECUTE tất cả SP/Function, không truy cập bảng trực tiếp
-- ============================================================
-- Cấp EXECUTE trên tất cả SP
GRANT EXECUTE ON dbo.sp_DatXe            TO role_app_service;
GRANT EXECUTE ON dbo.sp_NhanCuocXe       TO role_app_service;
GRANT EXECUTE ON dbo.sp_HoanThanhChuyen  TO role_app_service;
GRANT EXECUTE ON dbo.sp_HuyChuyen        TO role_app_service;
GRANT EXECUTE ON dbo.sp_NapTienVi        TO role_app_service;

-- Cấp EXECUTE trên Function
GRANT EXECUTE ON dbo.fn_TinhCuocPhi      TO role_app_service;
GRANT EXECUTE ON dbo.fn_KiemTraVoucher   TO role_app_service;
GRANT SELECT  ON dbo.fn_DoanhThuTheoThang TO role_app_service;

-- KHÔNG cấp SELECT/INSERT/UPDATE/DELETE trực tiếp trên bảng
-- → App chỉ tương tác qua SP, bảo mật tốt hơn
GO

-- ============================================================
-- 4.2 role_customer_module: Chỉ SP liên quan khách hàng
-- ============================================================
GRANT EXECUTE ON dbo.sp_DatXe          TO role_customer_module;
GRANT EXECUTE ON dbo.sp_HuyChuyen      TO role_customer_module;
GRANT EXECUTE ON dbo.sp_NapTienVi      TO role_customer_module;
GRANT EXECUTE ON dbo.fn_TinhCuocPhi    TO role_customer_module;
GRANT EXECUTE ON dbo.fn_KiemTraVoucher TO role_customer_module;
GO

-- ============================================================
-- 4.3 role_driver_module: Chỉ SP liên quan tài xế
-- ============================================================
GRANT EXECUTE ON dbo.sp_NhanCuocXe      TO role_driver_module;
GRANT EXECUTE ON dbo.sp_HoanThanhChuyen TO role_driver_module;
GRANT SELECT  ON dbo.fn_DoanhThuTheoThang TO role_driver_module;
-- Cho phép xem danh sách cuốc xe đang chờ (Pool)
GRANT SELECT ON dbo.CUOCXE  TO role_driver_module;
GRANT SELECT ON dbo.DIEMDEN TO role_driver_module;
GO

-- ============================================================
-- 4.4 role_backup_operator: Chỉ backup
-- ============================================================
ALTER ROLE db_backupoperator ADD MEMBER user_backup_job;
GO

PRINT N'✓ Phân quyền chi tiết thành công';
GO


-- ############################################################
-- PHẦN 5: TẠO VIEWS BẢO MẬT CHO BÁO CÁO
-- (Masking thông tin nhạy cảm cho Tableau/Analyst)
-- ############################################################

-- ============================================================
-- View 1: Dữ liệu khách hàng (ẩn SDT, Email)
-- ============================================================
IF OBJECT_ID('dbo.vw_KhachHang_BaoCao', 'V') IS NOT NULL
    DROP VIEW dbo.vw_KhachHang_BaoCao;
GO

CREATE VIEW dbo.vw_KhachHang_BaoCao
AS
SELECT
    Ma_Khach_Hang,
    Ten_Khach_Hang,
    -- Mask SDT: chỉ hiện 3 số cuối → 0901***001
    LEFT(SDT, 4) + '***' + RIGHT(SDT, 3) AS SDT_Masked,
    -- Mask Email: chỉ hiện domain → a***@gmail.com
    LEFT(Email, 1) + '***@' + RIGHT(Email, LEN(Email) - CHARINDEX('@', Email)) AS Email_Masked,
    Trang_Thai
FROM KHACHHANG;
GO

-- ============================================================
-- View 2: Dữ liệu tài xế (ẩn SDT)
-- ============================================================
IF OBJECT_ID('dbo.vw_TaiXe_BaoCao', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TaiXe_BaoCao;
GO

CREATE VIEW dbo.vw_TaiXe_BaoCao
AS
SELECT
    Ma_Tai_Xe,
    Ten_Tai_Xe,
    LEFT(SDT, 4) + '***' + RIGHT(SDT, 3) AS SDT_Masked,
    Trang_Thai,
    Diem_Uy_Tin
FROM TAIXE;
GO

-- ============================================================
-- View 3: Tổng quan cuốc xe (cho dashboard)
-- ============================================================
IF OBJECT_ID('dbo.vw_CuocXe_Dashboard', 'V') IS NOT NULL
    DROP VIEW dbo.vw_CuocXe_Dashboard;
GO

CREATE VIEW dbo.vw_CuocXe_Dashboard
AS
SELECT
    cx.Ma_Cuoc_Xe,
    cx.Ma_Khach_Hang,
    kh.Ten_Khach_Hang,
    cx.Ma_Tai_Xe,
    tx.Ten_Tai_Xe,
    bg.Loai_Xe,
    bg.Khung_Gio,
    cx.Khoang_Cach,
    cx.Gia_Uoc_Tinh,
    cx.Tong_Tien,
    cx.Trang_Thai,
    cx.Thoi_Gian_Tao,
    cx.Ma_Voucher,
    -- Thông tin điểm đón
    dd_don.Dia_Chi AS DiaChi_Don,
    -- Thông tin điểm trả
    dd_tra.Dia_Chi AS DiaChi_Den
FROM CUOCXE cx
         LEFT JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
         LEFT JOIN TAIXE tx ON cx.Ma_Tai_Xe = tx.Ma_Tai_Xe
         LEFT JOIN BANGGIA bg ON cx.Ma_Bang_Gia = bg.Ma_Bang_Gia
         LEFT JOIN DIEMDEN dd_don ON cx.Ma_Cuoc_Xe = dd_don.Ma_Cuoc_Xe AND dd_don.Loai_Diem_Den = 'Diem don'
         LEFT JOIN DIEMDEN dd_tra ON cx.Ma_Cuoc_Xe = dd_tra.Ma_Cuoc_Xe AND dd_tra.Loai_Diem_Den = 'Diem tra';
GO

-- ============================================================
-- View 4: Doanh thu tổng hợp (cho dashboard)
-- ============================================================
IF OBJECT_ID('dbo.vw_DoanhThu_Dashboard', 'V') IS NOT NULL
    DROP VIEW dbo.vw_DoanhThu_Dashboard;
GO

CREATE VIEW dbo.vw_DoanhThu_Dashboard
AS
SELECT
    cx.Ma_Cuoc_Xe,
    cx.Tong_Tien,
    cx.Trang_Thai,
    cx.Thoi_Gian_Tao,
    bg.Loai_Xe,
    bg.Khung_Gio,
    cx.Khoang_Cach,
    cx.Ma_Voucher,
    v.Ma_Code       AS Voucher_Code,
    v.Loai_Giam_Gia,
    v.Gia_Tri_Giam,
    CAST(cx.Thoi_Gian_Tao AS DATE)            AS Ngay,
    DATEPART(HOUR,    cx.Thoi_Gian_Tao)       AS Gio,
    DATEPART(WEEKDAY, cx.Thoi_Gian_Tao)       AS Thu_Trong_Tuan,
    MONTH(cx.Thoi_Gian_Tao)                   AS Thang,
    YEAR(cx.Thoi_Gian_Tao)                    AS Nam
FROM CUOCXE cx
         LEFT JOIN BANGGIA bg ON cx.Ma_Bang_Gia = bg.Ma_Bang_Gia
         LEFT JOIN VOUCHER v  ON cx.Ma_Voucher  = v.Ma_Voucher
WHERE cx.Trang_Thai = 'Hoan thanh';
GO

-- ============================================================
-- View 5: Hiệu suất tài xế (cho dashboard)
-- ============================================================
IF OBJECT_ID('dbo.vw_HieuSuatTaiXe_Dashboard', 'V') IS NOT NULL
    DROP VIEW dbo.vw_HieuSuatTaiXe_Dashboard;
GO

CREATE VIEW dbo.vw_HieuSuatTaiXe_Dashboard
AS
SELECT
    tx.Ma_Tai_Xe,
    tx.Ten_Tai_Xe,
    tx.Diem_Uy_Tin,
    tx.Trang_Thai AS Trang_Thai_Hien_Tai,
    -- Tổng cuốc xe
    COUNT(cx.Ma_Cuoc_Xe) AS Tong_Cuoc,
    -- Cuốc hoàn thành
    SUM(CASE WHEN cx.Trang_Thai = 'Hoan thanh' THEN 1 ELSE 0 END) AS Cuoc_Hoan_Thanh,
    -- Cuốc bị hủy
    SUM(CASE WHEN cx.Trang_Thai = 'Da huy' THEN 1 ELSE 0 END) AS Cuoc_Bi_Huy,
    -- Tỷ lệ hoàn thành
    CASE
        WHEN COUNT(cx.Ma_Cuoc_Xe) > 0
            THEN CAST(SUM(CASE WHEN cx.Trang_Thai = 'Hoan thanh' THEN 1 ELSE 0 END) * 100.0
            / COUNT(cx.Ma_Cuoc_Xe) AS DECIMAL(5,2))
        ELSE 0
        END AS Ty_Le_Hoan_Thanh,
    -- Tổng doanh thu
    SUM(CASE WHEN cx.Trang_Thai = 'Hoan thanh' THEN cx.Tong_Tien ELSE 0 END) AS Tong_Doanh_Thu,
    -- Điểm đánh giá trung bình
    AVG(CAST(dg.Diem_Danh_Gia AS DECIMAL(5,2))) AS Diem_TB_Danh_Gia
FROM TAIXE tx
         LEFT JOIN CUOCXE cx  ON tx.Ma_Tai_Xe    = cx.Ma_Tai_Xe
         LEFT JOIN DANHGIA dg ON cx.Ma_Cuoc_Xe   = dg.Ma_Cuoc_Xe
GROUP BY tx.Ma_Tai_Xe, tx.Ten_Tai_Xe, tx.Diem_Uy_Tin, tx.Trang_Thai;
GO

-- ============================================================
-- View 6: Order Pool monitoring (cho dashboard)
-- ============================================================
IF OBJECT_ID('dbo.vw_OrderPool_Dashboard', 'V') IS NOT NULL
    DROP VIEW dbo.vw_OrderPool_Dashboard;
GO

CREATE VIEW dbo.vw_OrderPool_Dashboard
AS
SELECT
    hd.Ma_Hang_Doi,
    hd.Ma_Cuoc_Xe,
    hd.Ban_Kinh_Phat_Song,
    hd.So_Lan_Phat_Song,
    hd.Thoi_Gian_Phat_Song,
    hd.Trang_Thai         AS Trang_Thai_Pool,
    cx.Trang_Thai         AS Trang_Thai_CuocXe,
    cx.Khoang_Cach,
    cx.Gia_Uoc_Tinh,
    cx.Thoi_Gian_Tao,
    -- Thời gian chờ trong pool (phút)
    DATEDIFF(MINUTE, hd.Thoi_Gian_Phat_Song,
             CASE WHEN hd.Trang_Thai = 'Dang hoat dong' THEN GETDATE()
                  ELSE hd.Thoi_Gian_Phat_Song END) AS Thoi_Gian_Cho_Phut,
    bg.Loai_Xe
FROM HANGDOI hd
         INNER JOIN CUOCXE cx  ON hd.Ma_Cuoc_Xe  = cx.Ma_Cuoc_Xe
         LEFT JOIN  BANGGIA bg ON cx.Ma_Bang_Gia  = bg.Ma_Bang_Gia;
GO

PRINT N'✓ Tạo tất cả Views bảo mật thành công';
GO


-- ############################################################
-- PHẦN 6: PHÂN QUYỀN CHO ROLE BÁO CÁO TRÊN VIEWS
-- ############################################################

-- Cấp SELECT trên Views (KHÔNG trên bảng gốc)
GRANT SELECT ON dbo.vw_KhachHang_BaoCao         TO role_readonly_report;
GRANT SELECT ON dbo.vw_TaiXe_BaoCao             TO role_readonly_report;
GRANT SELECT ON dbo.vw_CuocXe_Dashboard         TO role_readonly_report;
GRANT SELECT ON dbo.vw_DoanhThu_Dashboard        TO role_readonly_report;
GRANT SELECT ON dbo.vw_HieuSuatTaiXe_Dashboard  TO role_readonly_report;
GRANT SELECT ON dbo.vw_OrderPool_Dashboard       TO role_readonly_report;

-- DENY truy cập trực tiếp bảng chứa thông tin nhạy cảm
DENY SELECT ON dbo.KHACHHANG      TO role_readonly_report;
DENY SELECT ON dbo.TAIXE          TO role_readonly_report;
DENY SELECT ON dbo.VIDIENTU       TO role_readonly_report;
DENY SELECT ON dbo.LICHSUGIAODICH TO role_readonly_report;
GO

PRINT N'✓ Phân quyền Views cho báo cáo thành công';
GO


-- ############################################################
-- PHẦN 7: DYNAMIC DATA MASKING (Bảo vệ tầng thêm)
-- ############################################################

-- Mask SDT khách hàng
ALTER TABLE KHACHHANG
    ALTER COLUMN SDT ADD MASKED WITH (FUNCTION = 'partial(4, "***", 3)');
GO

-- Mask Email khách hàng
ALTER TABLE KHACHHANG
    ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');
GO

-- Mask SDT tài xế
ALTER TABLE TAIXE
    ALTER COLUMN SDT ADD MASKED WITH (FUNCTION = 'partial(4, "***", 3)');
GO

-- Mask số dư ví
ALTER TABLE VIDIENTU
    ALTER COLUMN So_Du ADD MASKED WITH (FUNCTION = 'default()');
GO

PRINT N'✓ Dynamic Data Masking đã được áp dụng';
GO

-- Cấp quyền UNMASK cho admin
GRANT UNMASK TO dba_admin;
GRANT UNMASK TO app_ridehailing_svc;
GO


-- ############################################################
-- PHẦN 8: AUDIT & LOGGING TABLE
-- ############################################################

IF OBJECT_ID('dbo.IMPORT_LOG', 'U') IS NOT NULL
    DROP TABLE dbo.IMPORT_LOG;
GO

CREATE TABLE IMPORT_LOG (
                            Log_ID          INT IDENTITY(1,1) PRIMARY KEY,
                            Batch_Name      NVARCHAR(100) NOT NULL,
                            Table_Name      NVARCHAR(50)  NOT NULL,
                            Records_Success INT           DEFAULT 0,
                            Records_Failed  INT           DEFAULT 0,
                            Error_Message   NVARCHAR(MAX) NULL,
                            Imported_By     NVARCHAR(50)  DEFAULT SYSTEM_USER,
                            Imported_At     DATETIME      DEFAULT GETDATE()
);
GO

IF OBJECT_ID('dbo.EXPORT_AUDIT_LOG', 'U') IS NOT NULL
    DROP TABLE dbo.EXPORT_AUDIT_LOG;
GO

CREATE TABLE EXPORT_AUDIT_LOG (
                                  Log_ID          INT IDENTITY(1,1) PRIMARY KEY,
                                  Export_Type     VARCHAR(50)   NOT NULL,   -- 'CSV', 'Tableau Refresh', etc.
                                  Table_Or_View   NVARCHAR(100) NOT NULL,
                                  Records_Count   INT           DEFAULT 0,
                                  Exported_By     NVARCHAR(50)  DEFAULT SYSTEM_USER,
                                  Exported_At     DATETIME      DEFAULT GETDATE()
);
GO

PRINT N'✓ Tạo bảng Audit Log thành công';
GO


-- ############################################################
-- TỔNG KẾT PHÂN QUYỀN
-- ############################################################
PRINT N'';
PRINT N'╔═══════════════════════════════════════════════════════════════╗';
PRINT N'║           TỔNG KẾT AN TOÀN THÔNG TIN                       ║';
PRINT N'╠═══════════════════════════════════════════════════════════════╣';
PRINT N'║ Role                    │ User              │ Quyền         ║';
PRINT N'╠═════════════════════════╪═══════════════════╪═══════════════╣';
PRINT N'║ db_owner                │ dba_admin         │ Toàn quyền    ║';
PRINT N'║ role_app_service        │ app_ridehailing   │ EXEC SP/Func  ║';
PRINT N'║ role_customer_module    │ svc_customer_api  │ EXEC SP KH    ║';
PRINT N'║ role_driver_module      │ svc_driver_api    │ EXEC SP TX    ║';
PRINT N'║ role_readonly_report    │ user_tableau      │ SELECT Views  ║';
PRINT N'║ role_readonly_report    │ user_analyst      │ SELECT Views  ║';
PRINT N'║ role_backup_operator    │ user_backup_job   │ Backup only   ║';
PRINT N'╚═══════════════════════════════════════════════════════════════╝';
GO

-- VERIFY: Danh sách Contained Users đã tạo (EXPECT 7 users)
SELECT
    name                     AS UserName,
    type_desc                AS UserType,
    authentication_type_desc AS AuthType
FROM sys.database_principals
WHERE type = 'S'
  AND authentication_type = 2   -- 2 = Contained (DATABASE level)
  AND name NOT LIKE '##%';
GO

-- VERIFY: Danh sách Database Roles và Users đã tạo (EXPECT 6 roles)
SELECT
    r.name AS RoleName,
    m.name AS MemberName
FROM sys.database_role_members rm
         JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
         JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
WHERE r.name LIKE 'role_%'
ORDER BY r.name;
GO

-- Giả lập: user_tableau cố SELECT thẳng bảng KHACHHANG
-- (đã bị DENY trong file 07)
EXECUTE AS USER = 'user_tableau';
-- Thử 1: SELECT bảng bị DENY → phải báo lỗi
BEGIN TRY
    SELECT TOP 1 * FROM KHACHHANG;
    PRINT N'❌ SAI: user_tableau không được SELECT KHACHHANG trực tiếp';
END TRY
BEGIN CATCH
    PRINT N'✅ ĐÚNG: Bị chặn — ' + ERROR_MESSAGE();
END CATCH

-- Thử 2: SELECT qua View → phải thành công, dữ liệu bị masked
BEGIN TRY
    SELECT TOP 3 * FROM vw_KhachHang_BaoCao;
    PRINT N'✅ ĐÚNG: user_tableau xem được View với data masked';
END TRY
BEGIN CATCH
    PRINT N'❌ SAI: ' + ERROR_MESSAGE();
END CATCH
REVERT;

