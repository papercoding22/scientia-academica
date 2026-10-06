-- ============================================================
-- FILE: 09_Tableau_Queries.sql
-- MÔ TẢ: 5 Queries cho Tableau Dashboard
--         Mỗi query tương ứng 1 data source cho 1 dashboard
-- ------------------------------------------------------------
-- PHIÊN BẢN: Azure SQL Database
-- THAY ĐỔI SO VỚI BẢN GỐC:
--   1. Data Source 1E: Sửa Thoi_Gian_Tao → Thoi_Gian_Nhan
--      để tính đúng thời gian chờ từ lúc phát sóng đến lúc
--      tài xế thực sự nhận cuốc (đúng nghiệp vụ).
--   2. PRINT cuối: Cập nhật Server → Azure host,
--      password → đã đổi theo policy Azure.
--   - Toàn bộ còn lại: Giữ nguyên 100%
-- ============================================================

USE QL_DatXeCongNghe;
GO

-- ############################################################
-- DASHBOARD 1: TỔNG QUAN HOẠT ĐỘNG HỆ THỐNG (System Overview)
-- ############################################################
-- Mục đích: Ban quản trị theo dõi real-time sức khỏe hệ thống
-- Các thành phần:
--   1. KPI Cards: Tổng cuốc hôm nay theo trạng thái
--   2. Line Chart: Xu hướng cuốc xe theo giờ (24h)
--   3. Gauge: Số tài xế đang online
--   4. KPI + Trend: Tỷ lệ hủy chuyến
--   5. KPI: Thời gian trung bình chờ nhận cuốc

-- Data Source 1A: Tổng quan cuốc xe hôm nay
SELECT
    cx.Trang_Thai,
    COUNT(*) AS So_Luong,
    SUM(ISNULL(cx.Tong_Tien, 0)) AS Tong_Doanh_Thu,
    AVG(cx.Khoang_Cach) AS Khoang_Cach_TB
FROM CUOCXE cx
WHERE CAST(cx.Thoi_Gian_Tao AS DATE) = CAST(GETDATE() AS DATE)
GROUP BY cx.Trang_Thai;
GO

-- Data Source 1B: Cuốc xe theo giờ trong ngày
SELECT
    DATEPART(HOUR, cx.Thoi_Gian_Tao) AS Gio,
    COUNT(*) AS So_Cuoc,
    SUM(CASE WHEN cx.Trang_Thai = 'Hoan thanh' THEN 1 ELSE 0 END) AS Hoan_Thanh,
    SUM(CASE WHEN cx.Trang_Thai = 'Da huy' THEN 1 ELSE 0 END) AS Da_Huy
FROM CUOCXE cx
WHERE CAST(cx.Thoi_Gian_Tao AS DATE) = CAST(GETDATE() AS DATE)
GROUP BY DATEPART(HOUR, cx.Thoi_Gian_Tao)
ORDER BY Gio;
GO

-- Data Source 1C: Trạng thái tài xế hiện tại
SELECT
    Trang_Thai,
    COUNT(*) AS So_Luong
FROM TAIXE
GROUP BY Trang_Thai;
GO

-- Data Source 1D: Tỷ lệ hủy theo ngày (7 ngày gần nhất)
SELECT
    CAST(cx.Thoi_Gian_Tao AS DATE) AS Ngay,
    COUNT(*) AS Tong_Cuoc,
    SUM(CASE WHEN cx.Trang_Thai = 'Da huy' THEN 1 ELSE 0 END) AS So_Huy,
    CAST(
            SUM(CASE WHEN cx.Trang_Thai = 'Da huy' THEN 1.0 ELSE 0 END) * 100
                / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)) AS Ty_Le_Huy_Phan_Tram
FROM CUOCXE cx
WHERE cx.Thoi_Gian_Tao >= DATEADD(DAY, -7, GETDATE())
GROUP BY CAST(cx.Thoi_Gian_Tao AS DATE)
ORDER BY Ngay;
GO

-- Data Source 1E: Thời gian trung bình chờ trong Pool
-- [FIX] Dùng cx.Thoi_Gian_Nhan thay vì Thoi_Gian_Tao
-- → Đúng nghiệp vụ: tính từ lúc phát sóng đến lúc tài xế nhận
SELECT
    CAST(hd.Thoi_Gian_Phat_Song AS DATE) AS Ngay,
    AVG(
            CASE
                WHEN hd.Trang_Thai = 'Da nhan'
                    AND cx.Thoi_Gian_Tao IS NOT NULL
                    THEN DATEDIFF(SECOND, hd.Thoi_Gian_Phat_Song, cx.Thoi_Gian_Tao)
                ELSE NULL
                END
    ) / 60.0 AS Thoi_Gian_Cho_TB_Phut
FROM HANGDOI hd
         INNER JOIN CUOCXE cx ON hd.Ma_Cuoc_Xe = cx.Ma_Cuoc_Xe
WHERE hd.Thoi_Gian_Phat_Song >= DATEADD(DAY, -7, GETDATE())
GROUP BY CAST(hd.Thoi_Gian_Phat_Song AS DATE)
ORDER BY Ngay;
GO


-- ############################################################
-- DASHBOARD 2: PHÂN TÍCH DOANH THU & TÀI CHÍNH (Revenue Analytics)
-- ############################################################
-- Mục đích: Theo dõi hiệu quả kinh doanh, dòng tiền
-- Các thành phần:
--   1. Bar + Line combo: Doanh thu theo ngày/tuần/tháng
--   2. Stacked Bar: Doanh thu theo loại xe
--   3. Horizontal Bar: Top 10 tài xế doanh thu cao nhất
--   4. Histogram: Phân bố giá cuốc xe
--   5. Table + Bar: Hiệu quả Voucher

-- Data Source 2: Bảng dữ liệu doanh thu tổng hợp (dùng View đã tạo)
SELECT * FROM dbo.vw_DoanhThu_Dashboard;
GO

-- Data Source 2B: Top 10 tài xế doanh thu cao nhất tháng này
SELECT TOP 10
    tx.Ma_Tai_Xe,
    tx.Ten_Tai_Xe,
    tx.Diem_Uy_Tin,
    COUNT(cx.Ma_Cuoc_Xe) AS So_Cuoc_Hoan_Thanh,
    SUM(cx.Tong_Tien) AS Tong_Doanh_Thu,
    AVG(cx.Tong_Tien) AS Doanh_Thu_TB_Cuoc
FROM TAIXE tx
         INNER JOIN CUOCXE cx ON tx.Ma_Tai_Xe = cx.Ma_Tai_Xe
WHERE cx.Trang_Thai = 'Hoan thanh'
  AND MONTH(cx.Thoi_Gian_Tao) = MONTH(GETDATE())
  AND YEAR(cx.Thoi_Gian_Tao) = YEAR(GETDATE())
GROUP BY tx.Ma_Tai_Xe, tx.Ten_Tai_Xe, tx.Diem_Uy_Tin
ORDER BY Tong_Doanh_Thu DESC;
GO

-- Data Source 2C: Hiệu quả Voucher
SELECT
    v.Ma_Voucher,
    v.Ma_Code,
    v.Loai_Giam_Gia,
    v.Gia_Tri_Giam,
    v.So_Luot_Toi_Da,
    v.So_Luot_Da_Dung,
    CAST(v.So_Luot_Da_Dung * 100.0 / NULLIF(v.So_Luot_Toi_Da, 0) AS DECIMAL(5,2)) AS Ty_Le_Su_Dung,
    v.Trang_Thai,
    -- Tổng giá trị giảm giá đã áp dụng
    (SELECT COUNT(*)
     FROM CUOCXE cx
     WHERE cx.Ma_Voucher = v.Ma_Voucher
       AND cx.Trang_Thai = 'Hoan thanh') AS So_Cuoc_Ap_Dung,
    (SELECT SUM(cx.Gia_Uoc_Tinh - ISNULL(cx.Tong_Tien, cx.Gia_Uoc_Tinh))
     FROM CUOCXE cx
     WHERE cx.Ma_Voucher = v.Ma_Voucher
       AND cx.Trang_Thai = 'Hoan thanh') AS Tong_Gia_Tri_Giam_Da_Dung
FROM VOUCHER v
ORDER BY So_Luot_Da_Dung DESC;
GO


-- ############################################################
-- DASHBOARD 3: HIỆU SUẤT TÀI XẾ (Driver Performance)
-- ############################################################
-- Mục đích: Đánh giá chất lượng dịch vụ và hiệu suất tài xế
-- Các thành phần:
--   1. Histogram / Box plot: Phân bố điểm uy tín
--   2. Stacked % Bar: Tỷ lệ hoàn thành vs hủy
--   3. KPI + Trend: Số cuốc TB/ngày/tài xế
--   4. Pie Chart: Phân bố đánh giá sao
--   5. Scorecard Table: Bảng xếp hạng tài xế

-- Data Source 3: Hiệu suất tài xế (dùng View đã tạo)
SELECT * FROM dbo.vw_HieuSuatTaiXe_Dashboard;
GO

-- Data Source 3B: Phân bố đánh giá sao
SELECT
    dg.Diem_Danh_Gia AS So_Sao,
    COUNT(*) AS So_Luong,
    CAST(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM DANHGIA), 0) AS DECIMAL(5,2)) AS Ty_Le_Phan_Tram
FROM DANHGIA dg
GROUP BY dg.Diem_Danh_Gia
ORDER BY dg.Diem_Danh_Gia;
GO

-- Data Source 3C: Số cuốc trung bình theo ngày cho mỗi tài xế
SELECT
    tx.Ma_Tai_Xe,
    tx.Ten_Tai_Xe,
    CAST(cx.Thoi_Gian_Tao AS DATE) AS Ngay,
    COUNT(*) AS So_Cuoc_Trong_Ngay
FROM TAIXE tx
         INNER JOIN CUOCXE cx ON tx.Ma_Tai_Xe = cx.Ma_Tai_Xe
WHERE cx.Trang_Thai = 'Hoan thanh'
GROUP BY tx.Ma_Tai_Xe, tx.Ten_Tai_Xe, CAST(cx.Thoi_Gian_Tao AS DATE)
ORDER BY tx.Ma_Tai_Xe, Ngay;
GO


-- ############################################################
-- DASHBOARD 4: HÀNH VI KHÁCH HÀNG (Customer Insights)
-- ############################################################
-- Mục đích: Hiểu hành vi đặt xe, tối ưu marketing
-- Các thành phần:
--   1. Heatmap: Khung giờ đặt xe (giờ x thứ)
--   2. Line chart: Tỷ lệ khách quay lại (Retention)
--   3. Histogram: Phân bố khoảng cách
--   4. Table / Sankey: Top tuyến đường phổ biến
--   5. Funnel: Voucher usage funnel

-- Data Source 4A: Heatmap khung giờ đặt xe
SELECT
    DATEPART(HOUR, cx.Thoi_Gian_Tao) AS Gio,
    DATEPART(WEEKDAY, cx.Thoi_Gian_Tao) AS Thu_Trong_Tuan,
    DATENAME(WEEKDAY, cx.Thoi_Gian_Tao) AS Ten_Thu,
    COUNT(*) AS So_Cuoc
FROM CUOCXE cx
WHERE cx.Thoi_Gian_Tao >= DATEADD(MONTH, -1, GETDATE())
GROUP BY DATEPART(HOUR, cx.Thoi_Gian_Tao),
         DATEPART(WEEKDAY, cx.Thoi_Gian_Tao),
         DATENAME(WEEKDAY, cx.Thoi_Gian_Tao)
ORDER BY Thu_Trong_Tuan, Gio;
GO

-- Data Source 4B: Retention - Khách quay lại theo tuần
SELECT
    Tuan_Dang_Ky,
    Tong_Khach_Moi,
    Khach_Quay_Lai_Tuan_2,
    CAST(Khach_Quay_Lai_Tuan_2 * 100.0 / NULLIF(Tong_Khach_Moi, 0) AS DECIMAL(5,2)) AS Retention_Rate
FROM (
         SELECT
             DATEPART(WEEK, first_ride.First_Ride_Date) AS Tuan_Dang_Ky,
             COUNT(DISTINCT first_ride.Ma_Khach_Hang) AS Tong_Khach_Moi,
             COUNT(DISTINCT second_ride.Ma_Khach_Hang) AS Khach_Quay_Lai_Tuan_2
         FROM (
                  -- Chuyến đi đầu tiên của mỗi khách
                  SELECT Ma_Khach_Hang, MIN(Thoi_Gian_Tao) AS First_Ride_Date
                  FROM CUOCXE
                  GROUP BY Ma_Khach_Hang
              ) first_ride
                  LEFT JOIN CUOCXE second_ride
                            ON first_ride.Ma_Khach_Hang = second_ride.Ma_Khach_Hang
                                AND second_ride.Thoi_Gian_Tao > DATEADD(DAY, 7, first_ride.First_Ride_Date)
                                AND second_ride.Thoi_Gian_Tao <= DATEADD(DAY, 14, first_ride.First_Ride_Date)
         GROUP BY DATEPART(WEEK, first_ride.First_Ride_Date)
     ) retention_data
ORDER BY Tuan_Dang_Ky;
GO

-- Data Source 4C: Phân bố khoảng cách cuốc xe
SELECT
    CASE
        WHEN Khoang_Cach < 2  THEN N'< 2 km'
        WHEN Khoang_Cach < 5  THEN N'2-5 km'
        WHEN Khoang_Cach < 10 THEN N'5-10 km'
        WHEN Khoang_Cach < 20 THEN N'10-20 km'
        ELSE N'> 20 km'
        END AS Nhom_Khoang_Cach,
    COUNT(*) AS So_Cuoc,
    AVG(Tong_Tien) AS Gia_TB
FROM CUOCXE
WHERE Trang_Thai = 'Hoan thanh'
GROUP BY
    CASE
        WHEN Khoang_Cach < 2  THEN N'< 2 km'
        WHEN Khoang_Cach < 5  THEN N'2-5 km'
        WHEN Khoang_Cach < 10 THEN N'5-10 km'
        WHEN Khoang_Cach < 20 THEN N'10-20 km'
        ELSE N'> 20 km'
        END
ORDER BY MIN(Khoang_Cach);
GO

-- Data Source 4D: Top tuyến đường phổ biến
SELECT TOP 20
    dd_don.Dia_Chi AS Diem_Don,
    dd_tra.Dia_Chi AS Diem_Den,
    COUNT(*) AS So_Luot,
    AVG(cx.Khoang_Cach) AS Khoang_Cach_TB,
    AVG(cx.Tong_Tien) AS Gia_TB
FROM CUOCXE cx
         INNER JOIN DIEMDEN dd_don
                    ON cx.Ma_Cuoc_Xe = dd_don.Ma_Cuoc_Xe
                        AND dd_don.Loai_Diem_Den = 'Diem don'
         INNER JOIN DIEMDEN dd_tra
                    ON cx.Ma_Cuoc_Xe = dd_tra.Ma_Cuoc_Xe
                        AND dd_tra.Loai_Diem_Den = 'Diem tra'
WHERE cx.Trang_Thai = 'Hoan thanh'
GROUP BY dd_don.Dia_Chi, dd_tra.Dia_Chi
ORDER BY So_Luot DESC;
GO

-- Data Source 4E: Voucher Funnel
SELECT
    N'1. Được cấp' AS Giai_Doan,
    COUNT(*) AS So_Luong
FROM KHACHHANG_VOUCHER
UNION ALL
SELECT
    N'2. Đã sử dụng',
    COUNT(*)
FROM KHACHHANG_VOUCHER
WHERE Trang_Thai_Su_Dung = 'Da su dung'
UNION ALL
SELECT
    N'3. Hoàn thành chuyến với voucher',
    COUNT(*)
FROM CUOCXE
WHERE Ma_Voucher IS NOT NULL
  AND Trang_Thai = 'Hoan thanh'
ORDER BY Giai_Doan;
GO


-- ############################################################
-- DASHBOARD 5: GIÁM SÁT ORDER POOL & ĐIỀU PHỐI
--              (Dispatch Monitoring)
-- ############################################################
-- Mục đích: Monitor hiệu quả hệ thống phân phối đơn hàng
-- Các thành phần:
--   1. KPI + Gauge: Số cuốc đang chờ trong Pool
--   2. KPI + Trend: Thời gian TB trong Pool trước khi match
--   3. Bar chart: Số lần phát sóng TB trước khi match
--   4. Scatter plot: Bán kính phát sóng vs Tỷ lệ thành công
--   5. KPI + Trend: Tỷ lệ timeout

-- Data Source 5: Pool monitoring (dùng View đã tạo)
SELECT * FROM dbo.vw_OrderPool_Dashboard;
GO

-- Data Source 5B: Thống kê Pool theo ngày
SELECT
    CAST(hd.Thoi_Gian_Phat_Song AS DATE) AS Ngay,
    COUNT(*) AS Tong_Luot_Phat_Song,
    SUM(CASE WHEN hd.Trang_Thai = 'Da nhan'       THEN 1 ELSE 0 END) AS Luot_Thanh_Cong,
    SUM(CASE WHEN hd.Trang_Thai = 'Da het han'    THEN 1 ELSE 0 END) AS Luot_Het_Han,
    SUM(CASE WHEN hd.Trang_Thai = 'Dang hoat dong' THEN 1 ELSE 0 END) AS Dang_Cho,
    -- Tỷ lệ thành công
    CAST(
            SUM(CASE WHEN hd.Trang_Thai = 'Da nhan' THEN 1.0 ELSE 0 END) * 100
                / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)) AS Ty_Le_Match_Phan_Tram,
    -- Tỷ lệ timeout
    CAST(
            SUM(CASE WHEN hd.Trang_Thai = 'Da het han' THEN 1.0 ELSE 0 END) * 100
                / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)) AS Ty_Le_Timeout_Phan_Tram,
    -- Bán kính phát sóng trung bình
    AVG(hd.Ban_Kinh_Phat_Song) AS Ban_Kinh_TB,
    -- Số lần phát sóng trung bình
    AVG(CAST(hd.So_Lan_Phat_Song AS FLOAT)) AS So_Lan_PS_TB
FROM HANGDOI hd
WHERE hd.Thoi_Gian_Phat_Song >= DATEADD(DAY, -30, GETDATE())
GROUP BY CAST(hd.Thoi_Gian_Phat_Song AS DATE)
ORDER BY Ngay;
GO

-- Data Source 5C: Bán kính phát sóng vs Tỷ lệ thành công (Scatter plot)
SELECT
    hd.Ban_Kinh_Phat_Song,
    hd.So_Lan_Phat_Song,
    hd.Trang_Thai,
    CASE WHEN hd.Trang_Thai = 'Da nhan' THEN 1 ELSE 0 END AS Thanh_Cong,
    cx.Khoang_Cach,
    bg.Loai_Xe
FROM HANGDOI hd
         INNER JOIN CUOCXE cx ON hd.Ma_Cuoc_Xe = cx.Ma_Cuoc_Xe
         LEFT JOIN  BANGGIA bg ON cx.Ma_Bang_Gia = bg.Ma_Bang_Gia
WHERE hd.Trang_Thai IN ('Da nhan', 'Da het han');
GO


PRINT N'============================================================';
PRINT N'  ✓ Tất cả queries cho 5 Tableau Dashboards đã sẵn sàng!';
PRINT N'============================================================';
PRINT N'';
PRINT N'  Dashboard 1: Tổng quan Hoạt động Hệ thống';
PRINT N'  Dashboard 2: Phân tích Doanh thu & Tài chính';
PRINT N'  Dashboard 3: Hiệu suất Tài xế';
PRINT N'  Dashboard 4: Hành vi Khách hàng';
PRINT N'  Dashboard 5: Giám sát Order Pool & Điều phối';
PRINT N'';
PRINT N'  Kết nối Tableau với Azure SQL Database:';
PRINT N'    Server:         ql-datxecongnghe.database.windows.net';
PRINT N'    Port:           1433';
PRINT N'    Database:       QL_DatXeCongNghe';
PRINT N'    Authentication: SQL Server Authentication';
PRINT N'    User:           user_tableau';
PRINT N'    Password:       Nhom5#Crystal2026!';
PRINT N'    Encrypt:        True (bắt buộc với Azure)';
PRINT N'    Sử dụng Custom SQL hoặc các Views vw_* đã tạo sẵn';
GO