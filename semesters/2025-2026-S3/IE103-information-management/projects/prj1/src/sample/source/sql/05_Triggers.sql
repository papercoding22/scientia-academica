-- ============================================================
-- FILE: 05_Triggers.sql
-- MÔ TẢ: 5 Triggers cho hệ thống Đặt xe công nghệ
-- ============================================================

USE QL_DatXeCongNghe;
GO

-- ============================================================
-- TRIGGER 1: trg_CapNhatDiemUyTin
-- ============================================================
-- Business Flow:
--   Sau khi khách đánh giá chuyến đi → Hệ thống tự động
--   tính lại điểm trung bình uy tín của tài xế liên quan.
--   Cơ chế đánh giá theo ngày: chỉ tính đánh giá trong ngày.
--
-- Technical Logic:
--   - AFTER INSERT trên bảng DANHGIA
--   - Từ bản ghi INSERTED → lấy Ma_Cuoc_Xe → JOIN CUOCXE lấy Ma_Tai_Xe
--   - Tính AVG(Diem_Danh_Gia) của tất cả đánh giá trong NGÀY HÔM NAY
--     liên kết với tài xế đó
--   - UPDATE TAIXE.Diem_Uy_Tin = kết quả AVG
-- ============================================================
IF OBJECT_ID('dbo.trg_CapNhatDiemUyTin', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_CapNhatDiemUyTin;
GO

CREATE OR ALTER TRIGGER trg_CapNhatDiemUyTin
    ON DANHGIA
    AFTER INSERT
    AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem có tài xế nào vừa nhận đánh giá 1 sao đạt mốc >= 3 trong ngày hôm nay
    IF EXISTS (
        SELECT C.Ma_Tai_Xe
        FROM DANHGIA D
                 JOIN CUOCXE C ON D.Ma_Cuoc_Xe = C.Ma_Cuoc_Xe
        WHERE C.Ma_Tai_Xe IN (
            -- Lấy danh sách tài xế từ các đánh giá 1 sao vừa được insert
            SELECT CX.Ma_Tai_Xe
            FROM inserted i
                     JOIN CUOCXE CX ON i.Ma_Cuoc_Xe = CX.Ma_Cuoc_Xe
            WHERE i.Diem_Danh_Gia = 1
        )
          AND D.Diem_Danh_Gia = 1
          AND CAST(D.Thoi_Gian_Danh_Gia AS DATE) = CAST(GETDATE() AS DATE)
        GROUP BY C.Ma_Tai_Xe
        HAVING COUNT(D.Ma_Danh_Gia) >= 3
    )
        BEGIN
            -- Cập nhật trạng thái khóa cho các tài xế vi phạm
            UPDATE TAIXE
            SET Trang_Thai = 'Bi dinh chi'
            WHERE Ma_Tai_Xe IN (
                SELECT C.Ma_Tai_Xe
                FROM DANHGIA D
                         JOIN CUOCXE C ON D.Ma_Cuoc_Xe = C.Ma_Cuoc_Xe
                WHERE D.Diem_Danh_Gia = 1
                  AND CAST(D.Thoi_Gian_Danh_Gia AS DATE) = CAST(GETDATE() AS DATE)
                GROUP BY C.Ma_Tai_Xe
                HAVING COUNT(D.Ma_Danh_Gia) >= 3
            );
        END
END
GO

PRINT N'✓ trg_CapNhatDiemUyTin đã tạo thành công';
GO

-- ============================================================
-- Test trg_CapNhatDiemUyTin
-- ============================================================
-- Xem điểm uy tín TX001 trước
SELECT Ma_Tai_Xe, Ten_Tai_Xe, Diem_Uy_Tin FROM TAIXE WHERE Ma_Tai_Xe = 'TX001';
GO


-- ============================================================
-- TRIGGER 2: trg_KiemTraSoDuTruocGiaoDich
-- ============================================================
-- Business Flow:
--   Trước khi ghi nhận giao dịch "Trừ tiền" → Kiểm tra
--   ví có đủ số dư không → Nếu không đủ, từ chối giao dịch.
--   Đây là lớp bảo vệ cuối cùng ở tầng database.
--
-- Technical Logic:
--   - INSTEAD OF INSERT trên LICHSUGIAODICH
--   - Nếu Loai_Giao_Dich = "Trừ tiền":
--     + SELECT So_Du FROM VIDIENTU
--     + Nếu So_Du < So_Tien → RAISERROR, không INSERT
--   - Nếu đủ tiền hoặc là "Cộng tiền" → INSERT bình thường
-- ============================================================
IF OBJECT_ID('dbo.trg_KiemTraSoDuTruocGiaoDich', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_KiemTraSoDuTruocGiaoDich;
GO

CREATE OR ALTER TRIGGER trg_KiemTraSoDuTruocGiaoDich
    ON CUOCXE
    AFTER UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    -- Chỉ kích hoạt khi trạng thái thay đổi thành "Hoàn thành"
    IF UPDATE(Trang_Thai)
        BEGIN
            INSERT INTO THONGBAO (Ma_Thong_Bao, Loai_Nguoi_Nhan, Ma_Nguoi_Nhan, Tieu_De, Noi_Dung, Trang_Thai_Doc, Thoi_Gian_Gui)
            SELECT
                'TB' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8),
                'Khach hang',
                i.Ma_Khach_Hang,
                N'Cảnh báo số dư ví',
                N'Số dư ví của bạn hiện dưới 10.000 VND. Vui lòng nạp thêm tiền để trải nghiệm dịch vụ không bị gián đoạn.',
                'Chua doc',
                GETDATE()
            FROM inserted i
                     JOIN deleted d ON i.Ma_Cuoc_Xe = d.Ma_Cuoc_Xe
                     JOIN VIDIENTU V ON i.Ma_Khach_Hang = V.Ma_Chu_So_Huu AND V.Loai_Chu_So_Huu = 'Khach hang'
            WHERE i.Trang_Thai = 'Hoan thanh'
              AND d.Trang_Thai <> 'Hoan thanh'
              AND V.So_Du < 10000;
        END
END
GO

PRINT N'✓ trg_KiemTraSoDuTruocGiaoDich đã tạo thành công';
GO


-- ============================================================
-- TRIGGER 3: trg_CapNhatLuotVoucher
-- ============================================================
-- Business Flow:
--   Khi cuốc xe được tạo với voucher → Tự động tăng
--   So_Luot_Da_Dung của voucher đó. Nếu hết lượt → 
--   tự động chuyển trạng thái voucher thành "Đã hết hạn".
--
-- Technical Logic:
--   - AFTER INSERT trên CUOCXE
--   - Nếu Ma_Voucher IS NOT NULL trong INSERTED:
--     + UPDATE VOUCHER SET So_Luot_Da_Dung += 1
--     + CHECK: Nếu So_Luot_Da_Dung >= So_Luot_Toi_Da
--       → UPDATE Trang_Thai = "Đã hết hạn"
-- ============================================================
IF OBJECT_ID('dbo.trg_CapNhatLuotVoucher', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_CapNhatLuotVoucher;
GO

CREATE OR ALTER TRIGGER trg_CapNhatLuotVoucher
    ON CUOCXE
    AFTER UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Trang_Thai)
        BEGIN
            UPDATE V
            SET V.So_Luot_Da_Dung = ISNULL(V.So_Luot_Da_Dung, 0) + 1
            FROM VOUCHER V
                     JOIN inserted i ON V.Ma_Voucher = i.Ma_Voucher
                     JOIN deleted d ON i.Ma_Cuoc_Xe = d.Ma_Cuoc_Xe
            WHERE i.Trang_Thai = 'Hoan thanh'
              AND d.Trang_Thai <> 'Hoan thanh'
              AND i.Ma_Voucher IS NOT NULL;
        END
END
GO

PRINT N'✓ trg_CapNhatLuotVoucher đã tạo thành công';
GO


-- ============================================================
-- TRIGGER 4: trg_NganXoaCuocXe
-- ============================================================
-- Business Flow:
--   Bảo vệ dữ liệu: không cho phép xóa cuốc xe đang trong
--   trạng thái "Đã nhận" hoặc "Đang chạy" vì đang có giao
--   dịch tài chính và hành trình đang diễn ra.
--
-- Technical Logic:
--   - INSTEAD OF DELETE trên CUOCXE
--   - Nếu bản ghi DELETED có Trang_Thai IN ("Đã nhận","Đang chạy")
--     → RAISERROR, không cho xóa
--   - Nếu "Chờ nhận","Hoàn thành","Đã hủy" → cho phép DELETE
-- ============================================================
IF OBJECT_ID('dbo.trg_NganXoaCuocXe', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_NganXoaCuocXe;
GO

CREATE OR ALTER TRIGGER trg_NganXoaCuocXe
    ON CUOCXE
    INSTEAD OF DELETE
    AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem có dòng nào đang ở trạng thái không được phép xóa hay không
    IF EXISTS (
        SELECT 1
        FROM deleted
        WHERE Trang_Thai IN ('Da nhan', 'Dang chay')
    )
        BEGIN
            RAISERROR (N'Loi: Khong the xoa cuoc xe dang trong trang thai "Da nhan" hoac "Dang chay".', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

    -- Nếu tất cả các dòng đều hợp lệ, tiến hành xóa
    DELETE FROM CUOCXE
    WHERE Ma_Cuoc_Xe IN (SELECT Ma_Cuoc_Xe FROM deleted);
END
GO

PRINT N'✓ trg_NganXoaCuocXe đã tạo thành công';
GO

-- ============================================================
-- Test trg_NganXoaCuocXe
-- ============================================================
-- Test xóa cuốc xe "Đã nhận" (CX007) → phải bị chặn
-- DELETE FROM CUOCXE WHERE Ma_Cuoc_Xe = 'CX007';
-- → Kỳ vọng: RAISERROR

-- Test xóa cuốc xe "Đã hủy" (CX010) → cho phép
-- DELETE FROM CUOCXE WHERE Ma_Cuoc_Xe = 'CX010';
-- → Kỳ vọng: Xóa thành công
GO


-- ============================================================
-- TRIGGER 5: trg_ThongBaoTrangThai
-- ============================================================
-- Business Flow:
--   Mỗi khi cuốc xe chuyển trạng thái → Tự động tạo
--   thông báo cho khách hàng. Đảm bảo mọi thay đổi
--   trạng thái đều có notification, không bỏ sót.
--
-- Technical Logic:
--   - AFTER UPDATE trên CUOCXE
--   - So sánh Trang_Thai giữa INSERTED và DELETED
--   - Nếu khác nhau → xác định nội dung thông báo phù hợp
--   - INSERT vào THONGBAO
-- ============================================================
IF OBJECT_ID('dbo.trg_ThongBaoTrangThai', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_ThongBaoTrangThai;
GO

CREATE OR ALTER TRIGGER trg_ThongBaoTrangThai
    ON CUOCXE
    AFTER UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Trang_Thai)
        BEGIN
            INSERT INTO THONGBAO (Ma_Thong_Bao, Loai_Nguoi_Nhan, Ma_Nguoi_Nhan, Tieu_De, Noi_Dung, Trang_Thai_Doc, Thoi_Gian_Gui)
            SELECT
                'TB' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8),
                'Khach hang',
                i.Ma_Khach_Hang,
                N'Cập nhật chuyến đi',
                N'Chuyến đi ' + RTRIM(i.Ma_Cuoc_Xe) + N' của bạn đã chuyển sang trạng thái: ' + i.Trang_Thai,
                'Chua doc',
                GETDATE()
            FROM inserted i
                     JOIN deleted d ON i.Ma_Cuoc_Xe = d.Ma_Cuoc_Xe
            WHERE i.Trang_Thai <> d.Trang_Thai;
        END
END
GO

PRINT N'✓ trg_ThongBaoTrangThai đã tạo thành công';
GO

-- ============================================================
-- Test trg_ThongBaoTrangThai
-- ============================================================
-- Chuyển CX007 từ "Đã nhận" → "Đang chạy"
UPDATE CUOCXE SET Trang_Thai = 'Dang chay' WHERE Ma_Cuoc_Xe = 'CX007';

-- Kiểm tra thông báo mới tạo
SELECT TOP 5 * FROM THONGBAO ORDER BY Thoi_Gian_Gui DESC;
GO


drop trigger trg_CapNhatDiemUyTin;
drop trigger trg_KiemTraSoDuTruocGiaoDich;
drop trigger trg_CapNhatLuotVoucher;
drop trigger trg_NganXoaCuocXe;
drop trigger trg_ThongBaoTrangThai;
GO