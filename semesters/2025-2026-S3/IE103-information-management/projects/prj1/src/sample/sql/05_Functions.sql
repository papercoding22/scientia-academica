-- ============================================================
-- FILE: 03_Functions.sql
-- MÔ TẢ: 3 Functions cho hệ thống Đặt xe công nghệ
-- ============================================================

USE QL_DatXeCongNghe;
GO

-- ============================================================
-- FUNCTION 1: fn_TinhCuocPhi
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
-- FUNCTION 2: fn_DoanhThuTheoThang
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
-- FUNCTION 3: fn_KiemTraVoucher
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

GO