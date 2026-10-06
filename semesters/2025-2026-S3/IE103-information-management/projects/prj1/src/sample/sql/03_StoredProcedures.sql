-- ============================================================
-- FILE: 04_StoredProcedures.sql
-- MÔ TẢ: 5 Stored Procedures cho hệ thống Đặt xe công nghệ
-- ============================================================

USE QL_DatXeCongNghe;
GO

-- ============================================================
-- HELPER: Sequence generator cho mã tự động
-- ============================================================
IF OBJECT_ID('dbo.fn_SinhMa', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_SinhMa;
GO

CREATE FUNCTION dbo.fn_SinhMa(
    @Prefix VARCHAR(5),
    @TableName NVARCHAR(50),
    @ColumnName NVARCHAR(50)
)
    RETURNS CHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    DECLARE @NewID CHAR(10);

    -- Đếm dựa trên prefix length và lấy max number
    DECLARE @PrefixLen INT = LEN(@Prefix);

    IF @TableName = 'CUOCXE'
        SELECT @MaxID = ISNULL(MAX(CAST(SUBSTRING(Ma_Cuoc_Xe, @PrefixLen + 1, 10 - @PrefixLen) AS INT)), 0) FROM CUOCXE;
    ELSE IF @TableName = 'LICHSUGIAODICH'
        SELECT @MaxID = ISNULL(MAX(CAST(SUBSTRING(Ma_Giao_Dich, @PrefixLen + 1, 10 - @PrefixLen) AS INT)), 0) FROM LICHSUGIAODICH;
    ELSE IF @TableName = 'HANGDOI'
        SELECT @MaxID = ISNULL(MAX(CAST(SUBSTRING(Ma_Hang_Doi, @PrefixLen + 1, 10 - @PrefixLen) AS INT)), 0) FROM HANGDOI;
    ELSE IF @TableName = 'DIEMDEN'
        SELECT @MaxID = ISNULL(MAX(CAST(SUBSTRING(Ma_Diem_Den, @PrefixLen + 1, 10 - @PrefixLen) AS INT)), 0) FROM DIEMDEN;
    ELSE IF @TableName = 'THONGBAO'
        SELECT @MaxID = ISNULL(MAX(CAST(SUBSTRING(Ma_Thong_Bao, @PrefixLen + 1, 10 - @PrefixLen) AS INT)), 0) FROM THONGBAO;
    ELSE IF @TableName = 'DANHGIA'
        SELECT @MaxID = ISNULL(MAX(CAST(SUBSTRING(Ma_Danh_Gia, @PrefixLen + 1, 10 - @PrefixLen) AS INT)), 0) FROM DANHGIA;
    ELSE
        SET @MaxID = 0;

    SET @NewID = @Prefix + RIGHT('0000000' + CAST(@MaxID + 1 AS VARCHAR), 10 - @PrefixLen);
    RETURN @NewID;
END;
GO


-- ============================================================
-- STORED PROCEDURE 1: sp_DatXe
-- ============================================================
IF OBJECT_ID('dbo.sp_DatXe', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DatXe;
GO

CREATE OR ALTER PROCEDURE sp_DatXe
    @Ma_Khach_Hang CHAR(10),
    @Ma_Bang_Gia CHAR(10),
    @Khoang_Cach DECIMAL(10,2),
    @Gia_Uoc_Tinh DECIMAL(18,2),
    @Ma_Cuoc_Xe_Out CHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Tạo mã cuốc xe mới
        DECLARE @Ma_Cuoc_Xe CHAR(10) = 'CX' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8);
        SET @Ma_Cuoc_Xe_Out = @Ma_Cuoc_Xe;

        -- Lấy mã ví điện tử của Khách hàng
        DECLARE @Ma_Vi CHAR(10);
        SELECT @Ma_Vi = Ma_Vi FROM VIDIENTU
        WHERE Ma_Chu_So_Huu = @Ma_Khach_Hang AND Loai_Chu_So_Huu = 'Khach hang';

        -- Trừ tiền tạm giữ trong ví để đảm bảo khả năng thanh toán
        UPDATE VIDIENTU
        SET So_Du = So_Du - @Gia_Uoc_Tinh
        WHERE Ma_Vi = @Ma_Vi;

        -- Tạo bản ghi cuốc xe trước (LICHSUGIAODICH có FK tới CUOCXE)
        INSERT INTO CUOCXE (Ma_Cuoc_Xe, Ma_Khach_Hang, Ma_Bang_Gia, Trang_Thai, Khoang_Cach, Gia_Uoc_Tinh)
        VALUES (@Ma_Cuoc_Xe, @Ma_Khach_Hang, @Ma_Bang_Gia, 'Cho nhan', @Khoang_Cach, @Gia_Uoc_Tinh);

        -- Ghi nhận lịch sử giao dịch (Trừ tiền)
        INSERT INTO LICHSUGIAODICH (Ma_Giao_Dich, Ma_Vi, Ma_Cuoc_Xe, Loai_Giao_Dich, So_Tien, Noi_Dung)
        VALUES ('GD' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8), @Ma_Vi, @Ma_Cuoc_Xe, 'Tru tien', @Gia_Uoc_Tinh, N'Tạm giữ cước phí đặt xe');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT N'✓ sp_DatXe đã tạo thành công';
GO


-- ============================================================
-- STORED PROCEDURE 2: sp_NhanCuocXe
-- ============================================================
IF OBJECT_ID('dbo.sp_NhanCuocXe', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_NhanCuocXe;
GO

CREATE OR ALTER PROCEDURE sp_NhanCuocXe
    @Ma_Cuoc_Xe CHAR(10),
    @Ma_Tai_Xe CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Trang_Thai_CX NVARCHAR(20);

        -- Áp dụng UPDLOCK để xử lý Concurrency Control (Race Condition)
        SELECT @Trang_Thai_CX = Trang_Thai
        FROM CUOCXE WITH (UPDLOCK)
        WHERE Ma_Cuoc_Xe = @Ma_Cuoc_Xe;

        IF @Trang_Thai_CX = 'Cho nhan'
            BEGIN
                -- Gán cuốc xe cho tài xế
                UPDATE CUOCXE
                SET Ma_Tai_Xe = @Ma_Tai_Xe,
                    Trang_Thai = 'Da nhan'
                WHERE Ma_Cuoc_Xe = @Ma_Cuoc_Xe;

                -- Cập nhật trạng thái tài xế sang Đang bận
                UPDATE TAIXE
                SET Trang_Thai = 'Dang ban'
                WHERE Ma_Tai_Xe = @Ma_Tai_Xe;
            END
        ELSE
            BEGIN
                THROW 50001, N'Cuốc xe đã được nhận hoặc không còn khả dụng.', 1;
            END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT N'✓ sp_NhanCuocXe đã tạo thành công';
GO

-- ============================================================
-- STORED PROCEDURE 3: sp_HoanThanhChuyen
-- ============================================================
IF OBJECT_ID('dbo.sp_HoanThanhChuyen', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_HoanThanhChuyen;
GO

CREATE OR ALTER PROCEDURE sp_HoanThanhChuyen
@Ma_Cuoc_Xe CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Ma_Tai_Xe CHAR(10), @Gia_Cuoi_Cung DECIMAL(18,2), @Trang_Thai NVARCHAR(20);

        -- Lấy thông tin chuyến đi
        SELECT @Ma_Tai_Xe = Ma_Tai_Xe, @Gia_Cuoi_Cung = Gia_Uoc_Tinh, @Trang_Thai = Trang_Thai
        FROM CUOCXE
        WHERE Ma_Cuoc_Xe = @Ma_Cuoc_Xe;

        IF @Trang_Thai IN ('Dang chay', 'Da nhan')
            BEGIN
                -- Cập nhật cuốc xe hoàn thành
                UPDATE CUOCXE
                SET Trang_Thai = 'Hoan thanh',
                    Tong_Tien = @Gia_Cuoi_Cung
                WHERE Ma_Cuoc_Xe = @Ma_Cuoc_Xe;

                -- Cập nhật trạng thái tài xế
                UPDATE TAIXE
                SET Trang_Thai = 'San sang'
                WHERE Ma_Tai_Xe = @Ma_Tai_Xe;

                -- Cộng tiền doanh thu vào ví Tài xế
                DECLARE @Ma_Vi_TX CHAR(10);
                SELECT @Ma_Vi_TX = Ma_Vi FROM VIDIENTU
                WHERE Ma_Chu_So_Huu = @Ma_Tai_Xe AND Loai_Chu_So_Huu = 'Tai xe';

                UPDATE VIDIENTU
                SET So_Du = So_Du + @Gia_Cuoi_Cung
                WHERE Ma_Vi = @Ma_Vi_TX;

                -- Ghi nhận lịch sử giao dịch (Cộng tiền)
                INSERT INTO LICHSUGIAODICH (Ma_Giao_Dich, Ma_Vi, Ma_Cuoc_Xe, Loai_Giao_Dich, So_Tien, Noi_Dung)
                VALUES ('GD' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8), @Ma_Vi_TX, @Ma_Cuoc_Xe, 'Cong tien', @Gia_Cuoi_Cung, N'Doanh thu hoàn thành cuốc xe');
            END
        ELSE
            BEGIN
                THROW 50002, N'Trạng thái cuốc xe không hợp lệ để hoàn thành.', 1;
            END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT N'✓ sp_HoanThanhChuyen đã tạo thành công';
GO

-- ============================================================
-- STORED PROCEDURE 4: sp_HuyChuyen
-- ============================================================
IF OBJECT_ID('dbo.sp_HuyChuyen', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_HuyChuyen;
GO

CREATE OR ALTER PROCEDURE sp_HuyChuyen
@Ma_Cuoc_Xe CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Ma_Khach_Hang CHAR(10), @Ma_Tai_Xe CHAR(10), @Gia_Uoc_Tinh DECIMAL(18,2), @Trang_Thai NVARCHAR(20);

        -- Khóa Row để ngăn chặn thay đổi trạng thái song song
        SELECT @Ma_Khach_Hang = Ma_Khach_Hang, @Ma_Tai_Xe = Ma_Tai_Xe, @Gia_Uoc_Tinh = Gia_Uoc_Tinh, @Trang_Thai = Trang_Thai
        FROM CUOCXE WITH (UPDLOCK)
        WHERE Ma_Cuoc_Xe = @Ma_Cuoc_Xe;

        IF @Trang_Thai IN ('Cho nhan', 'Da nhan')
            BEGIN
                -- Hủy cuốc xe
                UPDATE CUOCXE
                SET Trang_Thai = 'Da huy'
                WHERE Ma_Cuoc_Xe = @Ma_Cuoc_Xe;

                -- Giải phóng trạng thái tài xế nếu đã có người nhận
                IF @Ma_Tai_Xe IS NOT NULL
                    BEGIN
                        UPDATE TAIXE
                        SET Trang_Thai = 'San sang'
                        WHERE Ma_Tai_Xe = @Ma_Tai_Xe;
                    END

                -- Hoàn trả số tiền tạm giữ lại cho ví Khách hàng
                DECLARE @Ma_Vi_KH CHAR(10);
                SELECT @Ma_Vi_KH = Ma_Vi FROM VIDIENTU
                WHERE Ma_Chu_So_Huu = @Ma_Khach_Hang AND Loai_Chu_So_Huu = 'Khach hang';

                UPDATE VIDIENTU
                SET So_Du = So_Du + @Gia_Uoc_Tinh
                WHERE Ma_Vi = @Ma_Vi_KH;

                -- Ghi nhận lịch sử giao dịch (Hoàn tiền → Cong tien)
                INSERT INTO LICHSUGIAODICH (Ma_Giao_Dich, Ma_Vi, Ma_Cuoc_Xe, Loai_Giao_Dich, So_Tien, Noi_Dung)
                VALUES ('GD' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8), @Ma_Vi_KH, @Ma_Cuoc_Xe, 'Cong tien', @Gia_Uoc_Tinh, N'Hoàn tiền cước do hủy chuyến');
            END
        ELSE
            BEGIN
                THROW 50003, N'Không thể hủy chuyến đi ở trạng thái hiện tại.', 1;
            END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT N'✓ sp_HuyChuyen đã tạo thành công';
GO


-- ============================================================
-- STORED PROCEDURE 5: sp_NapTienVi
-- ============================================================
IF OBJECT_ID('dbo.sp_NapTienVi', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_NapTienVi;
GO

CREATE OR ALTER PROCEDURE sp_NapTienVi
    @Ma_Chu_So_Huu CHAR(10),
    @Loai_Chu_So_Huu NVARCHAR(20), -- 'Khách hàng' hoặc 'Tài xế'
    @So_Tien DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Ma_Vi CHAR(10);

        SELECT @Ma_Vi = Ma_Vi
        FROM VIDIENTU
        WHERE Ma_Chu_So_Huu = @Ma_Chu_So_Huu AND Loai_Chu_So_Huu = @Loai_Chu_So_Huu;

        IF @Ma_Vi IS NOT NULL AND @So_Tien > 0
            BEGIN
                -- Cập nhật số dư
                UPDATE VIDIENTU
                SET So_Du = So_Du + @So_Tien
                WHERE Ma_Vi = @Ma_Vi;

                -- Ghi nhận biến động số dư
                INSERT INTO LICHSUGIAODICH (Ma_Giao_Dich, Ma_Vi, Loai_Giao_Dich, So_Tien, Noi_Dung)
                VALUES ('GD' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8), @Ma_Vi, 'Cong tien', @So_Tien, N'Nạp tiền vào ví điện tử');
            END
        ELSE
            BEGIN
                THROW 50004, N'Thông tin ví không hợp lệ hoặc số tiền nạp ≤ 0.', 1;
            END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT N'✓ sp_NapTienVi đã tạo thành công';
GO