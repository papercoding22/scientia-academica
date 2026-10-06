-- ============================================================
-- FILE: 06_Cursors.sql
-- MÔ TẢ: 2 Cursors cho hệ thống Đặt xe công nghệ
-- ============================================================

USE QL_DatXeCongNghe;
GO

CREATE OR ALTER PROCEDURE sp_Cursor_Top50TaiXeDoanhThuNgay
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Ma_Tai_Xe CHAR(10);
    DECLARE @Tong_Doanh_Thu DECIMAL(18,2);
    DECLARE @Noi_Dung_TB NVARCHAR(MAX);

    -- 1. Khai báo Cursor lấy Top 50 tài xế có tổng doanh thu (Tong_Tien) cao nhất trong ngày
    -- Giả định bảng CUOCXE có trường Thoi_Gian_Tao hoặc tương đương để lọc theo ngày
    DECLARE cur_TopTaiXe CURSOR FOR
        SELECT TOP 50
            Ma_Tai_Xe,
            SUM(Tong_Tien) AS Tong_Doanh_Thu
        FROM CUOCXE
        WHERE Trang_Thai = 'Hoan thanh'
        -- AND CAST(Thoi_Gian_Tao AS DATE) = CAST(GETDATE() AS DATE) -- Lọc theo ngày hiện tại
        GROUP BY Ma_Tai_Xe
        ORDER BY Tong_Doanh_Thu DESC;

    -- 2. Mở Cursor
    OPEN cur_TopTaiXe;

    -- 3. Đọc dòng đầu tiên
    FETCH NEXT FROM cur_TopTaiXe INTO @Ma_Tai_Xe, @Tong_Doanh_Thu;

    -- 4. Duyệt vòng lặp
    WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Cá nhân hóa nội dung thông báo cho từng tài xế
            SET @Noi_Dung_TB = N'Chúc mừng! Bạn lọt TOP 50 tài xế xuất sắc nhất hôm nay với tổng doanh thu: '
                + FORMAT(@Tong_Doanh_Thu, 'N0') + ' VND.';

            -- Gửi thông báo
            INSERT INTO THONGBAO (Ma_Thong_Bao, Loai_Nguoi_Nhan, Ma_Nguoi_Nhan, Tieu_De, Noi_Dung, Trang_Thai_Doc, Thoi_Gian_Gui)
            VALUES (
                       'TB' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8),
                       'Tai xe',
                       @Ma_Tai_Xe,
                       N'Tuyên dương Doanh thu',
                       @Noi_Dung_TB,
                       'Chua doc',
                       GETDATE()
                   );

            -- Đọc dòng tiếp theo
            FETCH NEXT FROM cur_TopTaiXe INTO @Ma_Tai_Xe, @Tong_Doanh_Thu;
        END

    -- 5. Đóng và giải phóng Cursor
    CLOSE cur_TopTaiXe;
    DEALLOCATE cur_TopTaiXe;

    PRINT N'Đã hoàn tất việc gửi thông báo cho Top 50 tài xế doanh thu cao nhất ngày.';
END
GO

CREATE OR ALTER PROCEDURE sp_Cursor_ThuongTop3KhachHang
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Ma_Khach_Hang CHAR(10);
    DECLARE @So_Luong_Chuyen INT;
    DECLARE @Ma_Vi CHAR(10);

    -- 1. Khai báo Cursor lấy Top 3 khách hàng
    DECLARE cur_TopKhachHang CURSOR FOR
        SELECT TOP 3
            Ma_Khach_Hang,
            COUNT(Ma_Cuoc_Xe) AS So_Luong_Chuyen
        FROM CUOCXE
        WHERE Trang_Thai = 'Hoan thanh'
        GROUP BY Ma_Khach_Hang
        ORDER BY So_Luong_Chuyen DESC;

    -- 2. Mở Cursor
    OPEN cur_TopKhachHang;

    -- 3. Đọc dòng dữ liệu đầu tiên
    FETCH NEXT FROM cur_TopKhachHang INTO @Ma_Khach_Hang, @So_Luong_Chuyen;

    -- 4. Duyệt vòng lặp
    WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Tìm mã ví điện tử của khách hàng đang được duyệt
            SELECT @Ma_Vi = Ma_Vi
            FROM VIDIENTU
            WHERE Ma_Chu_So_Huu= @Ma_Khach_Hang AND Loai_Chu_So_Huu = 'Khach hang';

            -- Nếu khách hàng đã liên kết ví, tiến hành tặng thưởng
            IF @Ma_Vi IS NOT NULL
                BEGIN
                    -- Cộng 50.000 VND vào ví
                    UPDATE VIDIENTU
                    SET So_Du = So_Du + 50000
                    WHERE Ma_Vi = @Ma_Vi;

                    -- Ghi nhận lịch sử giao dịch nạp tiền thưởng
                    INSERT INTO LICHSUGIAODICH (Ma_Giao_Dich, Ma_Vi, Loai_Giao_Dich, So_Tien, Noi_Dung)
                    VALUES (
                               'GD' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8),
                               @Ma_Vi,
                               'Cong tien',
                               50000,
                               N'Thưởng Top 3 khách hàng thân thiết'
                           );

                    -- Gửi thông báo chúc mừng
                    INSERT INTO THONGBAO (Ma_Thong_Bao, Loai_Nguoi_Nhan, Ma_Nguoi_Nhan, Tieu_De, Noi_Dung, Trang_Thai_Doc, Thoi_Gian_Gui)
                    VALUES (
                               'TB' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8),
                               'Khach hang',
                               @Ma_Khach_Hang,
                               N'Thưởng khách hàng thân thiết',
                               N'Chúc mừng! Bạn được tặng 50.000 VND vì lọt top 3 khách hàng có nhiều chuyến đi nhất (' + CAST(@So_Luong_Chuyen AS VARCHAR) + ' chuyến).',
                               'Chua doc',
                               GETDATE()
                           );
                END

            -- Chuyển sang khách hàng tiếp theo
            FETCH NEXT FROM cur_TopKhachHang INTO @Ma_Khach_Hang, @So_Luong_Chuyen;
        END

    -- 5. Đóng và giải phóng Cursor
    CLOSE cur_TopKhachHang;
    DEALLOCATE cur_TopKhachHang;

    PRINT N'Đã hoàn tất tặng thưởng và gửi thông báo cho Top 3 khách hàng.';
END
GO
