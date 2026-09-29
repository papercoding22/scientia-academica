-- 02. HAM (muc 4.1.3, Bang 4.3). Can: 01.
-- fn_DanhSachPhongTrong o Bang 4.3 thay bang sp_TraCuuPhongTrong (06) vi MySQL
-- khong co ham tra ve bang.

USE QuanLyKhachSan;

DROP FUNCTION IF EXISTS fn_SoDem;
DROP FUNCTION IF EXISTS fn_DonGiaPhongTheoNgay;
DROP FUNCTION IF EXISTS fn_SoPhongKhaDung;
DROP FUNCTION IF EXISTS fn_TienPhong;
DROP FUNCTION IF EXISTS fn_TienDichVu;
DROP FUNCTION IF EXISTS fn_DonGiaTrungBinh;

DELIMITER $$

CREATE FUNCTION fn_SoDem (p_CheckIn DATE, p_CheckOut DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    IF p_CheckIn IS NULL OR p_CheckOut IS NULL THEN
        RETURN 0;
    END IF;

    RETURN GREATEST(DATEDIFF(p_CheckOut, p_CheckIn), 0);
END$$

CREATE FUNCTION fn_DonGiaPhongTheoNgay (p_MaLoaiPhong CHAR(10), p_Ngay DATE)
RETURNS DECIMAL(18,2)
READS SQL DATA
SQL SECURITY DEFINER
BEGIN
    DECLARE v_Gia DECIMAL(18,2) DEFAULT NULL;

    SELECT bg.DonGia
    INTO   v_Gia
    FROM   BANG_GIA_PHONG bg
    WHERE  bg.MaLoaiPhong = p_MaLoaiPhong
      AND  p_Ngay BETWEEN bg.ApDungTuNgay AND bg.DenNgay
    ORDER  BY bg.ApDungTuNgay DESC
    LIMIT  1;

    IF v_Gia IS NULL THEN
        SELECT DonGiaNgay
        INTO   v_Gia
        FROM   LOAI_PHONG
        WHERE  MaLoaiPhong = p_MaLoaiPhong;
    END IF;

    RETURN COALESCE(v_Gia, 0);
END$$

-- RB-06. Don gia mot dem cua phieu: trung binh fn_DonGiaPhongTheoNgay cua tung
-- dem [p_CheckIn, p_CheckOut), lam tron 2 chu so. sp_DatPhong,
-- sp_TraCuuPhongTrong va trg_CTDP_TinhThanhTien_BI cung dung ham nay.
CREATE FUNCTION fn_DonGiaTrungBinh (
    p_MaLoaiPhong CHAR(10),
    p_CheckIn     DATE,
    p_CheckOut    DATE
)
RETURNS DECIMAL(18,2)
READS SQL DATA
SQL SECURITY DEFINER
BEGIN
    DECLARE v_Ngay  DATE;
    DECLARE v_Tong  DECIMAL(24,2) DEFAULT 0;
    DECLARE v_SoDem INT           DEFAULT 0;

    IF p_CheckIn IS NULL OR p_CheckOut IS NULL OR p_CheckOut <= p_CheckIn THEN
        RETURN NULL;
    END IF;

    SET v_Ngay = p_CheckIn;

    WHILE v_Ngay < p_CheckOut DO
        SET v_Tong  = v_Tong + fn_DonGiaPhongTheoNgay(p_MaLoaiPhong, v_Ngay);
        SET v_SoDem = v_SoDem + 1;
        SET v_Ngay  = v_Ngay + INTERVAL 1 DAY;
    END WHILE;

    RETURN ROUND(v_Tong / v_SoDem, 2);
END$$

-- p_MaLoaiPhong = NULL: moi loai phong.
CREATE FUNCTION fn_SoPhongKhaDung (
    p_MaLoaiPhong  CHAR(10),
    p_NgayCheckIn  DATE,
    p_NgayCheckOut DATE
)
RETURNS INT
READS SQL DATA
SQL SECURITY DEFINER
BEGIN
    DECLARE v_So INT DEFAULT 0;

    IF p_NgayCheckIn IS NULL OR p_NgayCheckOut IS NULL
       OR p_NgayCheckOut <= p_NgayCheckIn THEN
        RETURN 0;
    END IF;

    SELECT COUNT(*)
    INTO   v_So
    FROM   PHONG p
    WHERE  (p_MaLoaiPhong IS NULL OR p.MaLoaiPhong = p_MaLoaiPhong)
      AND  p.TrangThai NOT IN ('BaoTri', 'DangDon')
      AND  NOT EXISTS (
               SELECT 1
               FROM   CHI_TIET_DAT_PHONG ct
               JOIN   PHIEU_DAT_PHONG    pd ON pd.MaDatPhong = ct.MaDatPhong
               WHERE  ct.MaPhong      =  p.MaPhong
                 AND  pd.TrangThai    IN ('DaDat', 'DangO')
                 AND  pd.NgayCheckIn  <  p_NgayCheckOut
                 AND  p_NgayCheckIn   <  pd.NgayCheckOut
           );

    RETURN v_So;
END$$

CREATE FUNCTION fn_TienPhong (p_MaDatPhong CHAR(10))
RETURNS DECIMAL(18,2)
READS SQL DATA
SQL SECURITY DEFINER
BEGIN
    DECLARE v_Tien DECIMAL(18,2);

    SELECT COALESCE(SUM(ct.ThanhTien), 0)
    INTO   v_Tien
    FROM   CHI_TIET_DAT_PHONG ct
    WHERE  ct.MaDatPhong = p_MaDatPhong;

    RETURN v_Tien;
END$$

CREATE FUNCTION fn_TienDichVu (p_MaDatPhong CHAR(10))
RETURNS DECIMAL(18,2)
READS SQL DATA
SQL SECURITY DEFINER
BEGIN
    DECLARE v_Tien DECIMAL(18,2);

    SELECT COALESCE(SUM(sd.ThanhTien), 0)
    INTO   v_Tien
    FROM   SU_DUNG_DICH_VU sd
    WHERE  sd.MaDatPhong = p_MaDatPhong;

    RETURN v_Tien;
END$$

DELIMITER ;

-- Mong doi: 6 ham.
SELECT ROUTINE_NAME, DATA_TYPE AS KieuTraVe
FROM   information_schema.ROUTINES
WHERE  ROUTINE_SCHEMA = 'QuanLyKhachSan' AND ROUTINE_TYPE = 'FUNCTION'
ORDER  BY ROUTINE_NAME;
