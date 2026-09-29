-- 05. CON TRO (muc 4.1.4, Bang 4.4). Can: 01, 02.
-- MySQL chi cho khai bao CURSOR trong thu tuc, nen moi con tro nam trong mot thu tuc.

USE QuanLyKhachSan;

DROP PROCEDURE IF EXISTS sp_LapChiTietHoaDon;
DROP PROCEDURE IF EXISTS cur_XuLyNoShow;

DELIMITER $$

-- cur_LapChiTietHoaDon: moi phong mot dong TienPhong, them dong DichVu va GiamTru
-- (tien coc). Do sp_LapHoaDon goi nen khong tu mo giao dich.
CREATE PROCEDURE sp_LapChiTietHoaDon (
    IN p_MaHoaDon CHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_MaDatPhong CHAR(10);
    DECLARE v_TienCoc    DECIMAL(18,2);
    DECLARE v_Next       INT;
    DECLARE v_Tong       DECIMAL(18,2);
    DECLARE v_TienDV     DECIMAL(18,2);
    DECLARE v_TenDV      VARCHAR(200);

    DECLARE v_SoPhong  VARCHAR(10);
    DECLARE v_Gia      DECIMAL(18,2);
    DECLARE v_SoDem    INT;
    DECLARE v_ThanhTien DECIMAL(18,2);

    DECLARE v_Xong TINYINT DEFAULT 0;

    DECLARE cur_LapChiTietHoaDon CURSOR FOR
        SELECT p.SoPhong, ct.GiaThueThoiDiem, ct.SoDem, ct.ThanhTien
        FROM   CHI_TIET_DAT_PHONG ct
        JOIN   PHONG p ON p.MaPhong = ct.MaPhong
        WHERE  ct.MaDatPhong = v_MaDatPhong
        ORDER  BY p.SoPhong;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_Xong = 1;

    SELECT hd.MaDatPhong, pdp.TienCoc
    INTO   v_MaDatPhong, v_TienCoc
    FROM   HOA_DON hd
    JOIN   PHIEU_DAT_PHONG pdp ON pdp.MaDatPhong = hd.MaDatPhong
    WHERE  hd.MaHoaDon = p_MaHoaDon;

    IF v_MaDatPhong IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hoa don khong ton tai';
    END IF;

    SELECT COALESCE(MAX(CAST(SUBSTRING(MaCTHD, 3) AS UNSIGNED)), 0) + 1
    INTO   v_Next
    FROM   CHI_TIET_HOA_DON;

    OPEN cur_LapChiTietHoaDon;

    lap_phong: LOOP
        FETCH cur_LapChiTietHoaDon
        INTO  v_SoPhong, v_Gia, v_SoDem, v_ThanhTien;

        IF v_Xong = 1 THEN
            LEAVE lap_phong;
        END IF;

        INSERT INTO CHI_TIET_HOA_DON
            (MaCTHD, MaHoaDon, LoaiKhoanMuc, SoTien, GhiChu)
        VALUES
            (CONCAT('CT', LPAD(v_Next, 8, '0')), p_MaHoaDon, 'TienPhong',
             v_ThanhTien,
             CONCAT('Phong ', v_SoPhong, ': ',
                    REPLACE(FORMAT(v_Gia, 0), ',', '.'), ' x ',
                    v_SoDem, ' dem'));

        SET v_Next = v_Next + 1;
    END LOOP lap_phong;

    CLOSE cur_LapChiTietHoaDon;

    SET v_TienDV = fn_TienDichVu(v_MaDatPhong);

    IF v_TienDV > 0 THEN
        SELECT LEFT(GROUP_CONCAT(DISTINCT dv.TenDV ORDER BY dv.TenDV SEPARATOR ', '), 200)
        INTO   v_TenDV
        FROM   SU_DUNG_DICH_VU sd
        JOIN   DICH_VU dv ON dv.MaDV = sd.MaDV
        WHERE  sd.MaDatPhong = v_MaDatPhong;

        INSERT INTO CHI_TIET_HOA_DON
            (MaCTHD, MaHoaDon, LoaiKhoanMuc, SoTien, GhiChu)
        VALUES
            (CONCAT('CT', LPAD(v_Next, 8, '0')), p_MaHoaDon, 'DichVu',
             v_TienDV, v_TenDV);

        SET v_Next = v_Next + 1;
    END IF;

    SELECT COALESCE(SUM(SoTien), 0)
    INTO   v_Tong
    FROM   CHI_TIET_HOA_DON
    WHERE  MaHoaDon = p_MaHoaDon AND LoaiKhoanMuc <> 'GiamTru';

    IF v_TienCoc > 0 AND v_Tong > 0 THEN
        INSERT INTO CHI_TIET_HOA_DON
            (MaCTHD, MaHoaDon, LoaiKhoanMuc, SoTien, GhiChu)
        VALUES
            (CONCAT('CT', LPAD(v_Next, 8, '0')), p_MaHoaDon, 'GiamTru',
             -LEAST(v_TienCoc, v_Tong),
             CONCAT('Tru tien coc cua phieu ', v_MaDatPhong));
    END IF;
END$$

-- cur_XuLyNoShow: chay cuoi ngay; huy phieu DaDat da qua ngay nhan phong va
-- tra phong ve Trong.
CREATE PROCEDURE cur_XuLyNoShow ()
BEGIN
    DECLARE v_Done INT DEFAULT 0;
    DECLARE v_MaDatPhong CHAR(10);

    DECLARE cur_NoShow CURSOR FOR
        SELECT MaDatPhong
        FROM PHIEU_DAT_PHONG
        WHERE TrangThai = 'DaDat'
          AND NgayCheckIn < CURDATE();

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_Done = 1;

    OPEN cur_NoShow;

    read_loop: LOOP
        FETCH cur_NoShow INTO v_MaDatPhong;
        IF v_Done = 1 THEN
            LEAVE read_loop;
        END IF;

        UPDATE PHONG
        SET TrangThai = 'Trong'
        WHERE MaPhong IN (
            SELECT MaPhong
            FROM CHI_TIET_DAT_PHONG
            WHERE MaDatPhong = v_MaDatPhong
        ) AND TrangThai = 'DaDat';

        UPDATE PHIEU_DAT_PHONG
        SET TrangThai = 'DaHuy'
        WHERE MaDatPhong = v_MaDatPhong;

    END LOOP;

    CLOSE cur_NoShow;

    SELECT 'Da hoan tat xu ly No-Show va giai phong phong ve ton kho.' AS KetQua;
END$$

DELIMITER ;

-- Mong doi: 2 thu tuc.
SELECT ROUTINE_NAME
FROM   information_schema.ROUTINES
WHERE  ROUTINE_SCHEMA = 'QuanLyKhachSan'
  AND  ROUTINE_NAME IN ('sp_LapChiTietHoaDon', 'cur_XuLyNoShow')
ORDER  BY ROUTINE_NAME;
