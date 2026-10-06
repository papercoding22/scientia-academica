-- ============================================================
-- FILE: 03_Functions.sql
-- MÔ TẢ: 3 Functions cho hệ thống Đặt xe công nghệ
-- ============================================================

USE QL_DatXeCongNghe;
GO

-- ============================================================
-- FUNCTION 1: fn_TinhCuocPhi
-- Business: Khi khách đặt xe, hệ thống cần hiển thị giá dự kiến
--           trước khi xác nhận. Function tính cước phí dựa trên
--           bảng giá, khoảng cách và voucher (nếu có).
-- Logic:    Giá = Gia_Co_Ban + Don_Gia_Km * Khoang_Cach
--           Nếu voucher "Giảm cố định" → Giá = Giá - Gia_Tri_Giam
--           Nếu voucher "Giảm theo %" → Giá = Giá * (1 - %/100)
--           Trả về MAX(Giá, 0) để không âm
-- Loại:     Scalar Function
-- ============================================================
IF OBJECT_ID('dbo.fn_TinhCuocPhi', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_TinhCuocPhi;
GO

CREATE FUNCTION dbo.fn_TinhCuocPhi(
    @Ma_Bang_Gia    CHAR(10),
    @Khoang_Cach    FLOAT,
    @Ma_Voucher     CHAR(10) = NULL
)
    RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Gia_Co_Ban     DECIMAL(18,2);
    DECLARE @Don_Gia_Km     DECIMAL(18,2);
    DECLARE @Gia_Uoc_Tinh   DECIMAL(18,2);
    DECLARE @Loai_Giam      VARCHAR(20);
    DECLARE @Gia_Tri_Giam   DECIMAL(18,2);

    -- Lấy thông tin bảng giá
    SELECT @Gia_Co_Ban = Gia_Co_Ban,
           @Don_Gia_Km = Don_Gia_Km
    FROM BANGGIA
    WHERE Ma_Bang_Gia = @Ma_Bang_Gia;

    -- Nếu không tìm thấy bảng giá
    IF @Gia_Co_Ban IS NULL
        RETURN -1;

    -- Tính giá ước tính cơ bản
    SET @Gia_Uoc_Tinh = @Gia_Co_Ban + (@Don_Gia_Km * @Khoang_Cach);

    -- Áp dụng voucher nếu có
    IF @Ma_Voucher IS NOT NULL
        BEGIN
            SELECT @Loai_Giam = Loai_Giam_Gia,
                   @Gia_Tri_Giam = Gia_Tri_Giam
            FROM VOUCHER
            WHERE Ma_Voucher = @Ma_Voucher
              AND Trang_Thai = 'Dang hoat dong'
              AND Han_Su_Dung > GETDATE()
              AND So_Luot_Da_Dung < So_Luot_Toi_Da;

            IF @Loai_Giam IS NOT NULL
                BEGIN
                    IF @Loai_Giam = 'Giam co dinh'
                        SET @Gia_Uoc_Tinh = @Gia_Uoc_Tinh - @Gia_Tri_Giam;
                    ELSE IF @Loai_Giam = 'Giam theo phan tram'
                        SET @Gia_Uoc_Tinh = @Gia_Uoc_Tinh * (1 - @Gia_Tri_Giam / 100.0);
                END
        END

    -- Đảm bảo giá không âm
    IF @Gia_Uoc_Tinh < 0
        SET @Gia_Uoc_Tinh = 0;

    RETURN @Gia_Uoc_Tinh;
END;
GO

PRINT N'✓ fn_TinhCuocPhi đã tạo thành công';
GO

-- ============================================================
-- Test fn_TinhCuocPhi
-- ============================================================
-- VD1: Xe máy bình thường, 5km, không voucher
-- Kỳ vọng: 5000 + 4000*5 = 25000
SELECT dbo.fn_TinhCuocPhi('BG001', 5.0, NULL) AS Gia_Khong_Voucher;

-- VD2: Xe máy bình thường, 5km, voucher giảm 20K
-- Kỳ vọng: 25000 - 20000 = 5000
SELECT dbo.fn_TinhCuocPhi('BG001', 5.0, 'VC001') AS Gia_Co_Voucher;

-- VD3: Ô tô cao điểm, 10km, voucher giảm 10%
-- Kỳ vọng: (15000 + 12000*10) * 0.9 = 135000 * 0.9 = 121500
SELECT dbo.fn_TinhCuocPhi('BG004', 10.0, 'VC002') AS Gia_OTo_CaoDiem;
GO


-- ============================================================
-- FUNCTION 2: fn_DoanhThuTheoThang
-- Business: Tài xế xem thống kê thu nhập theo tháng trên app.
--           Trả về bảng chi tiết từng giao dịch cộng tiền.
-- Logic:    SELECT từ LICHSUGIAODICH JOIN VIDIENTU
--           WHERE Tài xế + tháng/năm + Loại = "Cộng tiền"
-- Loại:     Table-Valued Function (Inline)
-- ============================================================
IF OBJECT_ID('dbo.fn_DoanhThuTheoThang', 'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_DoanhThuTheoThang;
GO

CREATE FUNCTION dbo.fn_DoanhThuTheoThang(
    @Ma_Tai_Xe  CHAR(10),
    @Thang      INT,
    @Nam        INT
)
    RETURNS TABLE
        AS
        RETURN
        (
        SELECT
            ls.Ma_Giao_Dich,
            ls.Ma_Cuoc_Xe,
            ls.So_Tien,
            ls.Noi_Dung,
            ls.Thoi_Gian_Giao_Dich,
            -- Tổng lũy kế trong tháng
            SUM(ls.So_Tien) OVER (ORDER BY ls.Thoi_Gian_Giao_Dich
                ROWS UNBOUNDED PRECEDING) AS Luy_Ke
        FROM LICHSUGIAODICH ls
                 INNER JOIN VIDIENTU v ON ls.Ma_Vi = v.Ma_Vi
        WHERE v.Loai_Chu_So_Huu = 'Tai xe'
          AND v.Ma_Chu_So_Huu = @Ma_Tai_Xe
          AND ls.Loai_Giao_Dich = 'Cong tien'
          AND ls.Ma_Cuoc_Xe IS NOT NULL    -- Chỉ lấy doanh thu từ cuốc xe
          AND MONTH(ls.Thoi_Gian_Giao_Dich) = @Thang
          AND YEAR(ls.Thoi_Gian_Giao_Dich) = @Nam
        );
GO

PRINT N'✓ fn_DoanhThuTheoThang đã tạo thành công';
GO

-- ============================================================
-- Test fn_DoanhThuTheoThang
-- ============================================================
-- Xem doanh thu tài xế TX001 tháng 5/2026
SELECT * FROM dbo.fn_DoanhThuTheoThang('TX001', 5, 2026);

-- Xem doanh thu tài xế TX002 tháng 5/2026
SELECT * FROM dbo.fn_DoanhThuTheoThang('TX002', 5, 2026);

-- Tổng doanh thu tháng
SELECT
    COUNT(*) AS So_Cuoc,
    SUM(So_Tien) AS Tong_Doanh_Thu
FROM dbo.fn_DoanhThuTheoThang('TX001', 5, 2026);
GO

-- ============================================================
-- FUNCTION 3: fn_KiemTraVoucher
-- Business: Trước khi khách áp dụng mã giảm giá, hệ thống phải
--           kiểm tra voucher còn hiệu lực không, khách đã dùng 
--           chưa, còn lượt không.
-- Logic:    Kiểm tra 4 điều kiện:
--           1. Voucher trạng thái "Đang hoạt động"
--           2. Chưa hết hạn sử dụng
--           3. Còn lượt dùng (So_Luot_Da_Dung < So_Luot_Toi_Da)
--           4. Khách chưa sử dụng voucher này (KHACHHANG_VOUCHER)
-- Loại:     Scalar Function → RETURN BIT
-- ============================================================
IF OBJECT_ID('dbo.fn_KiemTraVoucher', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_KiemTraVoucher;
GO

CREATE FUNCTION dbo.fn_KiemTraVoucher(
    @Ma_Voucher     CHAR(10),
    @Ma_Khach_Hang  CHAR(10)
)
    RETURNS BIT
AS
BEGIN
    DECLARE @KetQua BIT = 0;

    -- Kiểm tra voucher tồn tại, còn hoạt động, chưa hết hạn, còn lượt
    IF EXISTS (
        SELECT 1
        FROM VOUCHER
        WHERE Ma_Voucher = @Ma_Voucher
          AND Trang_Thai = 'Dang hoat dong'
          AND Han_Su_Dung > GETDATE()
          AND So_Luot_Da_Dung < So_Luot_Toi_Da
    )
        BEGIN
            -- Kiểm tra khách hàng có voucher này và chưa sử dụng
            -- Trường hợp 1: Khách có voucher trong ví và chưa dùng
            IF EXISTS (
                SELECT 1
                FROM KHACHHANG_VOUCHER
                WHERE Ma_Khach_Hang = @Ma_Khach_Hang
                  AND Ma_Voucher = @Ma_Voucher
                  AND Trang_Thai_Su_Dung = 'Chua su dung'
            )
                BEGIN
                    SET @KetQua = 1;
                END
                -- Trường hợp 2: Voucher công khai, khách chưa có trong ví
                -- (Cho phép dùng nếu voucher vẫn hợp lệ)
            ELSE IF NOT EXISTS (
                SELECT 1
                FROM KHACHHANG_VOUCHER
                WHERE Ma_Khach_Hang = @Ma_Khach_Hang
                  AND Ma_Voucher = @Ma_Voucher
            )
                BEGIN
                    SET @KetQua = 1;
                END
        END

    RETURN @KetQua;
END;
GO

PRINT N'✓ fn_KiemTraVoucher đã tạo thành công';
GO


-- ============================================================
-- Test fn_KiemTraVoucher
-- ============================================================
-- KH001 có VC001 chưa dùng → 1
SELECT dbo.fn_KiemTraVoucher('VC001', 'KH001') AS KH001_VC001;

-- KH002 đã dùng VC001 → 0
SELECT dbo.fn_KiemTraVoucher('VC001', 'KH002') AS KH002_VC001_DaDung;

-- VC003 đã hết hạn → 0
SELECT dbo.fn_KiemTraVoucher('VC003', 'KH001') AS VC003_HetHan;

-- KH004 chưa có VC004 trong ví nhưng voucher hợp lệ → 1
SELECT dbo.fn_KiemTraVoucher('VC004', 'KH004') AS KH004_VC004_CongKhai;
GO

DROP FUNCTION dbo.fn_TinhCuocPhi;
DROP FUNCTION dbo.fn_DoanhThuTheoThang;
DROP FUNCTION dbo.fn_KiemTraVoucher;
GO