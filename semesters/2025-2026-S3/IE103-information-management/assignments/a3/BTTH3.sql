/******************************************************************************
 * MÔN HỌC   : IE103 - Quản lý Thông tin
 * BÀI        : Bài tập thực hành 03 - An ninh thông tin
 * SINH VIÊN  : Nguyễn Quốc Trung
 * MSSV       : 25730081
 * NHÓM       : 10
 * NGÀY       : 2026-10-06
 *
 * File này chứa toàn bộ câu lệnh T-SQL của báo cáo, xếp theo đúng thứ tự câu
 * hỏi trong file 25730081_Nguyễn Quốc Trung_BTTH3.pdf.
 *
 * LƯU Ý KHI CHẠY:
 *   - Các lệnh được nhóm theo từng câu; nên chạy theo thứ tự vì có phụ thuộc
 *     (login -> user -> role -> quyền).
 *   - Những khối đánh dấu [KHÔNG CHẠY] là code minh hoạ hoặc hướng khắc phục,
 *     không nằm trong luồng thực thi chính.
 *   - Những câu yêu cầu thao tác giao diện (import/export, xem SQL Server Log)
 *     không có lệnh T-SQL tương ứng, đã ghi chú rõ ở vị trí của câu đó.
 ******************************************************************************/


/****************************************************************************
 * BÀI TẬP 1 - TỔ CHỨC DỮ LIỆU VÀ AN TOÀN DỮ LIỆU
 ***************************************************************************/

------------------------------------------------------------------------------
-- Câu 1. Ví dụ khai báo tối ưu kiểu dữ liệu cho từng field   [KHÔNG CHẠY - minh hoạ]
------------------------------------------------------------------------------
/*
CREATE TABLE KhachHang (
    MaKH        INT IDENTITY(1,1) PRIMARY KEY,  -- INT: đủ cho 2 tỷ bản ghi, tối ưu index
    HoTen       NVARCHAR(100) NOT NULL,         -- NVARCHAR: lưu tiếng Việt có dấu
    MaSoThue    CHAR(10) NULL,                  -- CHAR: mã định danh độ dài cố định 10 ký tự
    Email       VARCHAR(100) NULL,              -- VARCHAR: ký tự ASCII, tiết kiệm 50% so với NVARCHAR
    SoDu        DECIMAL(18,2) DEFAULT 0,        -- DECIMAL: tiền tệ, chính xác tuyệt đối 2 số thập phân
    NgayDangKy  DATE DEFAULT GETDATE(),         -- DATE: chỉ lưu ngày tháng năm, tốn 3 bytes
    KichHoat    BIT DEFAULT 1                   -- BIT: cờ boolean logic (0 hoặc 1)
);
*/

------------------------------------------------------------------------------
-- Câu 2, 3, 4. Câu lý thuyết - không có lệnh T-SQL
------------------------------------------------------------------------------
-- Câu 2: dung lượng tối đa 1 row  = 8060 bytes (~7.87 KB) trên page 8 KB.
-- Câu 3: dung lượng tối đa 1 table bị giới hạn bởi Database/Filegroup (~524,272 TB).
-- Câu 4: ý nghĩa sysusers / sysservers / sysxlogins trong CSDL master.
-- Có thể tra cứu nhanh ba system view tương ứng:
SELECT TOP (10) name, type_desc FROM sys.database_principals;   -- thay cho sysusers
SELECT TOP (10) name, product   FROM sys.servers;               -- thay cho sysservers
SELECT TOP (10) name, type_desc FROM sys.server_principals;     -- thay cho sysxlogins
GO

------------------------------------------------------------------------------
-- Câu 5. Số file tối thiểu khi tạo CSDL
------------------------------------------------------------------------------
-- Khi thực hiện câu lệnh tối giản:
CREATE DATABASE AAA;
GO

-- SQL Server ngầm định tạo 2 file vật lý (kế thừa thuộc tính từ database Model):
--   1. AAA.mdf      : Primary Data File      - dữ liệu, con trỏ tới các file khác
--   2. AAA_log.ldf  : Transaction Log File   - nhật ký giao dịch, phục vụ recovery
-- Kiểm tra lại hai file vừa được tạo:
SELECT name, type_desc, physical_name
FROM sys.master_files
WHERE database_id = DB_ID('AAA');
GO

------------------------------------------------------------------------------
-- Câu 6. Số user kết nối đồng thời
------------------------------------------------------------------------------
SELECT @@MAX_CONNECTIONS AS [Max_User_Connections];

-- Hoặc xem cấu hình hiện tại thông qua sp_configure:
EXEC sp_configure 'user connections';
GO

------------------------------------------------------------------------------
-- Câu 7.1. BACKUP CSDL AAA thành file AAA.BAK
------------------------------------------------------------------------------
BACKUP DATABASE AAA
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\AAA.bak'
WITH FORMAT,
     INIT,
     NAME = 'Full Backup of AAA',
     STATS = 10;
GO

------------------------------------------------------------------------------
-- Câu 7.2. DELETE (xoá) CSDL AAA
------------------------------------------------------------------------------
USE master;
GO

-- Chuyển database sang Single User để ngắt toàn bộ kết nối hiện tại
ALTER DATABASE AAA SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Thực hiện lệnh xoá Database AAA
DROP DATABASE AAA;
GO

------------------------------------------------------------------------------
-- Câu 7.3. RESTORE CSDL AAA từ file AAA.BAK
------------------------------------------------------------------------------
USE master;
GO

RESTORE DATABASE AAA
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\AAA.bak'
WITH REPLACE,
     RECOVERY,
     STATS = 10;
GO

------------------------------------------------------------------------------
-- Câu 8. Đọc SQL Server Log
------------------------------------------------------------------------------
-- Thao tác chính thực hiện trên giao diện:
--   SSMS -> Object Explorer -> Management -> SQL Server Logs -> View SQL Server Log
-- Cách đọc nhanh bằng T-SQL (log hiện tại là log số 0):
EXEC xp_readerrorlog 0, 1, NULL, NULL, NULL, NULL, 'DESC';
GO

------------------------------------------------------------------------------
-- Câu 9. INSERT qua View EmployeeNames
------------------------------------------------------------------------------
USE AAA;
GO

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName  VARCHAR(50) NOT NULL,
    LastName   VARCHAR(50) NOT NULL,
    BirthDate  DATE NOT NULL,
    HireDate   DATE NOT NULL
);
GO

CREATE VIEW EmployeeNames
AS
    SELECT FirstName, LastName
    FROM Employees;
GO

-- Câu lệnh đề bài hỏi: KHÔNG thực hiện được.
-- View chỉ phơi ra 2 cột, các cột EmployeeID / BirthDate / HireDate của bảng gốc
-- là NOT NULL và không có giá trị mặc định -> vi phạm ràng buộc NOT NULL.
INSERT INTO EmployeeNames (FirstName, LastName)
VALUES ('QuanLyThongTin', 'IE103');
GO

-- Lỗi thực tế trả về:
--   Msg 515, Level 16, State 2, Line 1
--   Cannot insert the value NULL into column 'EmployeeID', table 'AAA.dbo.Employees';
--   column does not allow nulls. INSERT fails.
--   The statement has been terminated.

------------------------------------------------------------------------------
-- Câu 10. Trạng thái mã hoá dữ liệu - câu lý thuyết, không có lệnh T-SQL
------------------------------------------------------------------------------
-- Hình trong đề mô tả cơ chế Always Encrypted: dữ liệu được bảo vệ ở cả ba trạng thái,
-- trong đó điểm cốt lõi là Data in use (dữ liệu vẫn ở dạng mã hoá ngay khi SQL Server
-- xử lý; chỉ được giải mã tại phía client qua driver ADO.NET).


/****************************************************************************
 * BÀI TẬP 2 - IMPORT/EXPORT, XÁC THỰC VÀ PHÂN QUYỀN
 ***************************************************************************/

------------------------------------------------------------------------------
-- Câu 11. Import file dữ liệu sinh viên từ Excel vào SQL Server
------------------------------------------------------------------------------
-- Thao tác import thực hiện bằng giao diện:
--   SSMS -> chuột phải CSDL QLTT_BTTH3 -> Tasks -> Import Flat File...
--   Nguồn: resources/sample-students.csv (6 cột, 8 dòng)
--   Bảng đích: dbo.SampleStudents

-- Kiểm tra dữ liệu sau khi import:
USE QLTT_BTTH3;
GO

SELECT TOP (1000) [MSSV], [HoTen], [NgaySinh], [Lop], [Nganh], [DiemTB]
FROM [QLTT_BTTH3].[dbo].[SampleStudents];
GO

-- KẾT QUẢ: đúng 6 cột, 8 dòng; nhưng 2 cột bị wizard suy luận sai kiểu do
-- tuỳ chọn "Use Rich Data Type Detection" bật mặc định:
--   MSSV   : 25730001 -> 7300-01-25        (bị ép thành kiểu date)
--   DiemTB : 7.8      -> 7.80000019073486  (kiểu real, sai số dấu phẩy động)

-- [KHÔNG CHẠY] Hướng khắc phục: định nghĩa sẵn kiểu dữ liệu thay vì để wizard tự đoán
/*
CREATE TABLE dbo.SampleStudents_Fixed (
    MSSV      VARCHAR(10)   NOT NULL PRIMARY KEY,  -- mã định danh: giữ nguyên dạng chuỗi
    HoTen     NVARCHAR(100) NOT NULL,              -- Unicode cho tiếng Việt có dấu
    NgaySinh  DATE          NULL,
    Lop       VARCHAR(20)   NULL,
    Nganh     VARCHAR(20)   NULL,
    DiemTB    DECIMAL(4,2)  NULL                   -- chính xác tuyệt đối, không sai số
);
*/

------------------------------------------------------------------------------
-- Câu 12. Export table từ SQL Server ra Excel - thao tác giao diện
------------------------------------------------------------------------------
-- SSMS Tasks -> Export Data... bị vô hiệu hoá trên bản SQL Server Express
-- (không kèm SSIS), nên thực hiện bằng Excel:
--   Excel -> Data -> Get Data -> From Database -> From SQL Server Database
--   Server: PAPER-CODING22\SQLEXPRESS   |   Database: QLTT_BTTH3
--   Navigator -> chọn dbo.SampleStudents -> Transform Data -> Close & Load
-- Không có lệnh T-SQL cho câu này. Truy vấn dưới đây chỉ để đối chiếu số liệu hai đầu:
SELECT COUNT(*) AS SoDong FROM dbo.SampleStudents;   -- kỳ vọng: 8
GO

------------------------------------------------------------------------------
-- Câu 13.a. Tạo login cấp server cho u1, u4, u5, u6
------------------------------------------------------------------------------
USE master;
GO

CREATE LOGIN u1 WITH PASSWORD = 'Btth3_u1Pass!', CHECK_POLICY = OFF;
CREATE LOGIN u4 WITH PASSWORD = 'Btth3_u4Pass!', CHECK_POLICY = OFF;
CREATE LOGIN u5 WITH PASSWORD = 'Btth3_u5Pass!', CHECK_POLICY = OFF;
CREATE LOGIN u6 WITH PASSWORD = 'Btth3_u6Pass!', CHECK_POLICY = OFF;
GO

-- u2, u3 chỉ thuộc r2 (thuần cấp database) nên không cần login riêng.
-- Kiểm tra: phải trả về đúng 4 login u1, u4, u5, u6
SELECT name, type_desc, create_date
FROM sys.server_principals
WHERE type IN ('S', 'U') AND name IN ('u1','u2','u3','u4','u5','u6');
GO

------------------------------------------------------------------------------
-- Câu 13.b. Ánh xạ thành database user trong QLTT_BTTH3
------------------------------------------------------------------------------
USE QLTT_BTTH3;
GO

CREATE USER u1 FOR LOGIN u1;
CREATE USER u4 FOR LOGIN u4;
CREATE USER u5 FOR LOGIN u5;
CREATE USER u6 FOR LOGIN u6;

CREATE USER u2 WITHOUT LOGIN;
CREATE USER u3 WITHOUT LOGIN;
GO

-- u1 BẮT BUỘC phải có database user dù mục tiêu của nó là quyền cấp server,
-- vì r1 là database role (xem ghi chú lỗi Msg 15151 ở mục 13.3.d của báo cáo).

-- Kiểm tra: phải trả về đúng 6 dòng u1-u6
-- (u1, u4, u5, u6 -> INSTANCE ; u2, u3 -> NONE vì WITHOUT LOGIN)
SELECT name, type_desc, authentication_type_desc
FROM sys.database_principals
WHERE type IN ('S', 'U') AND name IN ('u1','u2','u3','u4','u5','u6');
GO

------------------------------------------------------------------------------
-- Câu 13.c. Tạo 3 role r1, r2, r3
------------------------------------------------------------------------------
USE QLTT_BTTH3;
GO

CREATE ROLE r1;
CREATE ROLE r2;
CREATE ROLE r3;
GO

-- Kiểm tra: đúng 3 role, chưa có thành viên nào
SELECT name, type_desc
FROM sys.database_principals
WHERE type = 'R' AND name IN ('r1','r2','r3');
GO

------------------------------------------------------------------------------
-- Câu 13.d. Gán thành viên: u1->r1 ; u2,u3->r2 ; u4,u5,u6->r3
------------------------------------------------------------------------------
USE QLTT_BTTH3;
GO

ALTER ROLE r1 ADD MEMBER u1;
ALTER ROLE r2 ADD MEMBER u2;
ALTER ROLE r2 ADD MEMBER u3;
ALTER ROLE r3 ADD MEMBER u4;
ALTER ROLE r3 ADD MEMBER u5;
ALTER ROLE r3 ADD MEMBER u6;
GO

-- Kiểm tra: đúng 6 dòng, khớp từng ô của ma trận user x role
SELECT r.name AS role, m.name AS member
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE r.name IN ('r1','r2','r3')
ORDER BY r.name, m.name;
GO

------------------------------------------------------------------------------
-- Câu 13.e. Gán r1-r3 vào vai trò hệ thống
------------------------------------------------------------------------------
-- Phần CẤP DATABASE: r2, r3 vào db_owner và db_accessadmin
USE QLTT_BTTH3;
GO

ALTER ROLE db_owner       ADD MEMBER r2;
ALTER ROLE db_accessadmin ADD MEMBER r2;
ALTER ROLE db_owner       ADD MEMBER r3;
ALTER ROLE db_accessadmin ADD MEMBER r3;
GO

-- Kiểm tra phần database: r2 và r3 dưới cả db_owner lẫn db_accessadmin
SELECT dr.name AS fixed_db_role, m.name AS member
FROM sys.database_role_members rm
JOIN sys.database_principals dr ON dr.principal_id = rm.role_principal_id
JOIN sys.database_principals m  ON m.principal_id  = rm.member_principal_id
WHERE dr.name IN ('db_owner', 'db_accessadmin')
ORDER BY dr.name, m.name;
GO


-- Phần CẤP SERVER: SysAdmin
-- LƯU Ý: ALTER SERVER ROLE chỉ nhận login/server principal làm thành viên,
-- trong khi r1 và r3 là DATABASE role (tạo bằng CREATE ROLE). Vì vậy không thể
-- viết "ALTER SERVER ROLE SysAdmin ADD MEMBER r1;" - lệnh đó sẽ báo lỗi.
-- Cách xử lý đã chọn: gán trực tiếp các login tương ứng (u1 thuộc r1;
-- u4, u5, u6 thuộc r3) vào SysAdmin.
ALTER SERVER ROLE SysAdmin ADD MEMBER u1;
ALTER SERVER ROLE SysAdmin ADD MEMBER u4;
ALTER SERVER ROLE SysAdmin ADD MEMBER u5;
ALTER SERVER ROLE SysAdmin ADD MEMBER u6;
GO

-- Kiểm tra phần server: u1, u4, u5, u6 phải xuất hiện trong SysAdmin
SELECT sr.name AS server_role, m.name AS member
FROM sys.server_role_members srm
JOIN sys.server_principals sr ON sr.principal_id = srm.role_principal_id
JOIN sys.server_principals m  ON m.principal_id  = srm.member_principal_id
WHERE sr.name = 'SysAdmin'
ORDER BY m.name;
GO

------------------------------------------------------------------------------
-- Câu 13 - Kiểm chứng tổng hợp toàn bộ membership
------------------------------------------------------------------------------
-- (1) Toàn bộ membership cấp database
USE QLTT_BTTH3;
GO

SELECT r.name AS role, m.name AS member, 'user-role (13.3.d)' AS nguon
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE r.name IN ('r1','r2','r3')

UNION ALL

SELECT dr.name, m.name, 'role-into-fixedrole (13.3.e)'
FROM sys.database_role_members rm
JOIN sys.database_principals dr ON dr.principal_id = rm.role_principal_id
JOIN sys.database_principals m  ON m.principal_id  = rm.member_principal_id
WHERE dr.name IN ('db_owner', 'db_accessadmin')
ORDER BY nguon, role, member;
GO

-- (2) Toàn bộ membership cấp server
SELECT sr.name AS server_role, m.name AS member
FROM sys.server_role_members srm
JOIN sys.server_principals sr ON sr.principal_id = srm.role_principal_id
JOIN sys.server_principals m  ON m.principal_id  = srm.member_principal_id
WHERE sr.name = 'SysAdmin'
ORDER BY m.name;
GO

------------------------------------------------------------------------------
-- Câu 14.1-14.2. Chọn T1-T3 theo MSSV và tạo ba bảng mẫu
------------------------------------------------------------------------------
-- MSSV 25730081 -> chữ số cuối là 1 -> theo bảng trang 4 của đề:
--   T1 = GV_HV_CN   |   T2 = HOIDONG_GV   |   T3 = HOCVI

USE QLTT_BTTH3;
GO

-- Đề không cho cấu trúc cụ thể của CSDL Quản lý đề tài nên tự tạo cấu trúc
-- tối giản, đủ để chạy thật SELECT / INSERT / UPDATE / DELETE ở các bước kiểm chứng.
CREATE TABLE dbo.GV_HV_CN (
    MaGV    INT PRIMARY KEY,
    HoTenGV NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.HOIDONG_GV (
    MaHoiDong  INT PRIMARY KEY,
    TenHoiDong NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.HOCVI (
    MaHocVi  INT PRIMARY KEY,
    TenHocVi NVARCHAR(100) NOT NULL
);
GO

INSERT INTO dbo.GV_HV_CN   VALUES (1, N'Nguyen Van A'), (2, N'Tran Thi B');
INSERT INTO dbo.HOIDONG_GV VALUES (1, N'Hoi dong bao ve dot 1');
INSERT INTO dbo.HOCVI      VALUES (1, N'Thac si'), (2, N'Tien si');
GO

-- Kiểm tra: phải trả về đủ 3 bảng
SELECT name FROM sys.tables
WHERE name IN ('GV_HV_CN', 'HOIDONG_GV', 'HOCVI');
GO

------------------------------------------------------------------------------
-- Câu 14.3. Tạo U1, U2, U3  (đặt tên U1_PQ, U2_PQ, U3_PQ)
------------------------------------------------------------------------------
-- LÝ DO ĐỔI TÊN: collation mặc định của SQL Server KHÔNG phân biệt hoa/thường
-- nên U1 và u1 là cùng một principal - mà u1 đã tồn tại từ Câu 13 và đang là
-- thành viên SysAdmin. Thành viên SysAdmin bỏ qua mọi kiểm tra quyền, nên nếu
-- dùng lại tên đó thì GRANT / DENY / REVOKE của Câu 14 sẽ không kiểm chứng được.
USE master;
GO

CREATE LOGIN U1_PQ WITH PASSWORD = 'Btth3_U1Pass!', CHECK_POLICY = OFF;
CREATE LOGIN U2_PQ WITH PASSWORD = 'Btth3_U2Pass!', CHECK_POLICY = OFF;
CREATE LOGIN U3_PQ WITH PASSWORD = 'Btth3_U3Pass!', CHECK_POLICY = OFF;
GO

USE QLTT_BTTH3;
GO

CREATE USER U1_PQ FOR LOGIN U1_PQ;
CREATE USER U2_PQ FOR LOGIN U2_PQ;
CREATE USER U3_PQ FOR LOGIN U3_PQ;
GO

-- Kiểm tra: đúng 3 database user
SELECT name, type_desc FROM sys.database_principals
WHERE name IN ('U1_PQ', 'U2_PQ', 'U3_PQ');
GO

------------------------------------------------------------------------------
-- Câu 14.5. GRANT - cấp quyền
------------------------------------------------------------------------------
USE QLTT_BTTH3;
GO

-- U1 có quyền select, delete trên T1, T3
GRANT SELECT, DELETE ON dbo.GV_HV_CN TO U1_PQ;
GRANT SELECT, DELETE ON dbo.HOCVI    TO U1_PQ;

-- U2 có quyền update, delete trên T2
GRANT UPDATE, DELETE ON dbo.HOIDONG_GV TO U2_PQ;

-- U3 có quyền insert trên T1, T2, T3
GRANT INSERT ON dbo.GV_HV_CN   TO U3_PQ;
GRANT INSERT ON dbo.HOIDONG_GV TO U3_PQ;
GRANT INSERT ON dbo.HOCVI      TO U3_PQ;
GO

------------------------------------------------------------------------------
-- Câu 14.6. DENY - từ chối quyền
------------------------------------------------------------------------------
-- U1 bị từ chối quyền insert trên T1, T2
DENY INSERT ON dbo.GV_HV_CN   TO U1_PQ;
DENY INSERT ON dbo.HOIDONG_GV TO U1_PQ;

-- U2 bị từ chối quyền delete trên T3
DENY DELETE ON dbo.HOCVI TO U2_PQ;
GO

-- DENY không phải là "huỷ GRANT": đây là trạng thái riêng, ưu tiên cao hơn GRANT.

------------------------------------------------------------------------------
-- Câu 14.7. REVOKE - thu hồi quyền
------------------------------------------------------------------------------
-- Thu hồi các quyền của U1 trên T1
REVOKE SELECT, DELETE ON dbo.GV_HV_CN FROM U1_PQ;

-- Thu hồi các quyền của U3 trên T2
REVOKE INSERT ON dbo.HOIDONG_GV FROM U3_PQ;
GO

-- REVOKE chỉ xoá đúng những quyền được liệt kê trong câu lệnh; nó KHÔNG đụng tới
-- DENY INSERT đã đặt ở mục 14.6. Muốn bỏ luôn DENY thì phải viết thêm:
--     REVOKE INSERT ON dbo.GV_HV_CN FROM U1_PQ;
-- Đề không yêu cầu nên không thực hiện.

------------------------------------------------------------------------------
-- Câu 14.8. Kiểm chứng trạng thái quyền trong catalog
------------------------------------------------------------------------------
SELECT dp.name AS grantee, o.name AS table_name,
       pr.permission_name, pr.state_desc
FROM sys.database_permissions pr
JOIN sys.objects o              ON pr.major_id = o.object_id
JOIN sys.database_principals dp ON pr.grantee_principal_id = dp.principal_id
WHERE dp.name IN ('U1_PQ', 'U2_PQ', 'U3_PQ')
ORDER BY dp.name, o.name, pr.permission_name;
GO

-- KẾT QUẢ KỲ VỌNG: đúng 9 dòng
--   U1_PQ | GV_HV_CN   | INSERT | DENY     <- vẫn còn: REVOKE không chạm tới DENY
--   U1_PQ | HOCVI      | DELETE | GRANT
--   U1_PQ | HOCVI      | SELECT | GRANT
--   U1_PQ | HOIDONG_GV | INSERT | DENY
--   U2_PQ | HOCVI      | DELETE | DENY
--   U2_PQ | HOIDONG_GV | DELETE | GRANT
--   U2_PQ | HOIDONG_GV | UPDATE | GRANT
--   U3_PQ | GV_HV_CN   | INSERT | GRANT
--   U3_PQ | HOCVI      | INSERT | GRANT
-- U1_PQ trên GV_HV_CN không còn dòng SELECT/DELETE (đã REVOKE).
-- U3_PQ trên HOIDONG_GV không còn dòng nào (đã REVOKE INSERT).

------------------------------------------------------------------------------
-- Câu 14.9. Kiểm chứng bằng hành vi thực tế
------------------------------------------------------------------------------
EXECUTE AS USER = 'U1_PQ';

SELECT * FROM dbo.GV_HV_CN;                 -- kỳ vọng LỖI: quyền SELECT đã bị REVOKE
INSERT INTO dbo.HOIDONG_GV DEFAULT VALUES;  -- kỳ vọng LỖI: DENY INSERT vẫn còn hiệu lực

REVERT;
GO

-- Lỗi thực tế trả về - hai lý do khác nhau nhưng cùng một mã lỗi:
--   Msg 229, Level 14, State 5, Line 2
--   The SELECT permission was denied on the object 'GV_HV_CN', database 'QLTT_BTTH3', schema 'dbo'.
--   Msg 229, Level 14, State 5, Line 3
--   The INSERT permission was denied on the object 'HOIDONG_GV', database 'QLTT_BTTH3', schema 'dbo'.
--
-- Câu SELECT hỏng vì KHÔNG CÒN quyền (đã REVOKE - xoá bản ghi quyền).
-- Câu INSERT hỏng vì CÓ lệnh cấm tường minh (DENY - trạng thái chủ động cấm).
-- Luôn gọi REVERT ngay sau khi test, nếu không các lệnh sau sẽ chạy dưới quyền U1_PQ.

/****************************** HẾT ******************************/
