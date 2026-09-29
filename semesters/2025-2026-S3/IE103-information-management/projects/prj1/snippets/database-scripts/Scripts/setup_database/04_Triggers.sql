-- 04. TRIGGER (muc 4.1.2, Bang 4.2). Can: 01, 02.
-- MySQL khong cho mot trigger nhieu su kien va khong co INSTEAD OF: moi trigger
-- o Bang 4.2 tach theo su kien (_BI / _BU / _AI / _AU / _AD), trg_PDP_ChongXoaVatLy
-- dung BEFORE DELETE + SIGNAL. ThanhTien la cot GENERATED nen hai trigger
-- TinhThanhTien chi chot SoDem va don gia.

USE QuanLyKhachSan;

DROP TRIGGER IF EXISTS trg_CTDP_TinhThanhTien_BI;
DROP TRIGGER IF EXISTS trg_CTDP_TinhThanhTien_BU;
DROP TRIGGER IF EXISTS trg_CTDP_ChongTrungPhong_BI;
DROP TRIGGER IF EXISTS trg_CTDP_ChongTrungPhong_BU;
DROP TRIGGER IF EXISTS trg_SDDV_TinhThanhTien_BI;
DROP TRIGGER IF EXISTS trg_SDDV_TinhThanhTien_BU;
DROP TRIGGER IF EXISTS trg_CTHD_CapNhatTongTien_AI;
DROP TRIGGER IF EXISTS trg_CTHD_CapNhatTongTien_AU;
DROP TRIGGER IF EXISTS trg_CTHD_CapNhatTongTien_AD;
DROP TRIGGER IF EXISTS trg_PDP_KiemSoatVongDoi;
DROP TRIGGER IF EXISTS trg_PDP_ChongXoaVatLy;
DROP TRIGGER IF EXISTS trg_BangGia_KhongGiaoNhau_BI;
DROP TRIGGER IF EXISTS trg_BangGia_KhongGiaoNhau_BU;

DELIMITER $$

-- RB-04. Truyen 0 cho SoDem / GiaThueThoiDiem de trigger tu dien.
CREATE TRIGGER trg_CTDP_TinhThanhTien_BI
BEFORE INSERT ON CHI_TIET_DAT_PHONG
FOR EACH ROW
BEGIN
    DECLARE v_NgayIn      DATE;
    DECLARE v_NgayOut     DATE;
    DECLARE v_MaLoaiPhong CHAR(10);
    DECLARE v_Gia         DECIMAL(18,2);

    SELECT NgayCheckIn, NgayCheckOut
    INTO   v_NgayIn, v_NgayOut
    FROM   PHIEU_DAT_PHONG
    WHERE  MaDatPhong = NEW.MaDatPhong;

    IF v_NgayIn IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phieu dat phong khong ton tai';
    END IF;

    IF NEW.SoDem IS NULL OR NEW.SoDem <= 0 THEN
        SET NEW.SoDem = DATEDIFF(v_NgayOut, v_NgayIn);
    END IF;

    IF NEW.GiaThueThoiDiem IS NULL OR NEW.GiaThueThoiDiem = 0 THEN
        SELECT MaLoaiPhong INTO v_MaLoaiPhong
        FROM   PHONG
        WHERE  MaPhong = NEW.MaPhong;

        IF v_MaLoaiPhong IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phong khong ton tai';
        END IF;

        -- RB-06: trung binh gia tung dem, cung cong thuc voi sp_DatPhong.
        SET v_Gia = fn_DonGiaTrungBinh(v_MaLoaiPhong, v_NgayIn, v_NgayOut);

        SET NEW.GiaThueThoiDiem = COALESCE(v_Gia, 0);
    END IF;
END$$

CREATE TRIGGER trg_CTDP_TinhThanhTien_BU
BEFORE UPDATE ON CHI_TIET_DAT_PHONG
FOR EACH ROW
BEGIN
    DECLARE v_NgayIn  DATE;
    DECLARE v_NgayOut DATE;

    IF NEW.SoDem IS NULL OR NEW.SoDem <= 0 THEN
        SELECT NgayCheckIn, NgayCheckOut
        INTO   v_NgayIn, v_NgayOut
        FROM   PHIEU_DAT_PHONG
        WHERE  MaDatPhong = NEW.MaDatPhong;

        SET NEW.SoDem = DATEDIFF(v_NgayOut, v_NgayIn);
    END IF;

    IF NEW.GiaThueThoiDiem IS NULL OR NEW.GiaThueThoiDiem < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Gia thue tai thoi diem dat khong hop le';
    END IF;
END$$

-- RB-01
CREATE TRIGGER trg_CTDP_ChongTrungPhong_BI
BEFORE INSERT ON CHI_TIET_DAT_PHONG
FOR EACH ROW
FOLLOWS trg_CTDP_TinhThanhTien_BI
BEGIN
    DECLARE v_NgayIn     DATE;
    DECLARE v_NgayOut    DATE;
    DECLARE v_TrangThai  VARCHAR(20);
    DECLARE v_PhieuTrung CHAR(10) DEFAULT NULL;
    DECLARE v_ThongBao   VARCHAR(128);

    SELECT NgayCheckIn, NgayCheckOut, TrangThai
    INTO   v_NgayIn, v_NgayOut, v_TrangThai
    FROM   PHIEU_DAT_PHONG
    WHERE  MaDatPhong = NEW.MaDatPhong;

    IF v_TrangThai IN ('DaDat', 'DangO') THEN
        SELECT ct.MaDatPhong
        INTO   v_PhieuTrung
        FROM   CHI_TIET_DAT_PHONG ct
        JOIN   PHIEU_DAT_PHONG    pd ON pd.MaDatPhong = ct.MaDatPhong
        WHERE  ct.MaPhong     =  NEW.MaPhong
          AND  ct.MaDatPhong  <> NEW.MaDatPhong
          AND  pd.TrangThai   IN ('DaDat', 'DangO')
          AND  pd.NgayCheckIn <  v_NgayOut
          AND  v_NgayIn       <  pd.NgayCheckOut
        LIMIT  1;

        IF v_PhieuTrung IS NOT NULL THEN
            SET v_ThongBao = CONCAT('Trung phong: phong ', NEW.MaPhong,
                                    ' da duoc giu boi phieu ', v_PhieuTrung,
                                    ' trong khoang ngay nay');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ThongBao;
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_CTDP_ChongTrungPhong_BU
BEFORE UPDATE ON CHI_TIET_DAT_PHONG
FOR EACH ROW
FOLLOWS trg_CTDP_TinhThanhTien_BU
BEGIN
    DECLARE v_NgayIn     DATE;
    DECLARE v_NgayOut    DATE;
    DECLARE v_TrangThai  VARCHAR(20);
    DECLARE v_PhieuTrung CHAR(10) DEFAULT NULL;
    DECLARE v_ThongBao   VARCHAR(128);

    IF NEW.MaPhong <> OLD.MaPhong OR NEW.MaDatPhong <> OLD.MaDatPhong THEN
        SELECT NgayCheckIn, NgayCheckOut, TrangThai
        INTO   v_NgayIn, v_NgayOut, v_TrangThai
        FROM   PHIEU_DAT_PHONG
        WHERE  MaDatPhong = NEW.MaDatPhong;

        IF v_TrangThai IN ('DaDat', 'DangO') THEN
            SELECT ct.MaDatPhong
            INTO   v_PhieuTrung
            FROM   CHI_TIET_DAT_PHONG ct
            JOIN   PHIEU_DAT_PHONG    pd ON pd.MaDatPhong = ct.MaDatPhong
            WHERE  ct.MaPhong     =  NEW.MaPhong
              AND  ct.MaDatPhong  <> NEW.MaDatPhong
              AND  pd.TrangThai   IN ('DaDat', 'DangO')
              AND  pd.NgayCheckIn <  v_NgayOut
              AND  v_NgayIn       <  pd.NgayCheckOut
            LIMIT  1;

            IF v_PhieuTrung IS NOT NULL THEN
                SET v_ThongBao = CONCAT('Trung phong: phong ', NEW.MaPhong,
                                        ' da duoc giu boi phieu ', v_PhieuTrung,
                                        ' trong khoang ngay nay');
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ThongBao;
            END IF;
        END IF;
    END IF;
END$$

-- RB-04
CREATE TRIGGER trg_SDDV_TinhThanhTien_BI
BEFORE INSERT ON SU_DUNG_DICH_VU
FOR EACH ROW
BEGIN
    DECLARE v_TrangThaiPhieu VARCHAR(20);
    DECLARE v_TrangThaiHD    VARCHAR(20);
    DECLARE v_GiaDV          DECIMAL(18,2);

    SELECT TrangThai INTO v_TrangThaiPhieu
    FROM   PHIEU_DAT_PHONG
    WHERE  MaDatPhong = NEW.MaDatPhong;

    IF v_TrangThaiPhieu IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phieu dat phong khong ton tai';
    END IF;

    IF v_TrangThaiPhieu IN ('DaDat', 'DaHuy') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Chi ghi nhan dich vu cho phieu dang o hoac da hoan tat';
    END IF;

    SELECT TrangThai INTO v_TrangThaiHD
    FROM   HOA_DON
    WHERE  MaDatPhong = NEW.MaDatPhong;

    IF v_TrangThaiHD IN ('DaThanhToan', 'DaHuy') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hoa don da thanh toan hoac da huy, khong the them dich vu';
    END IF;

    IF NEW.DonGiaThoiDiem IS NULL OR NEW.DonGiaThoiDiem = 0 THEN
        SELECT GiaDV INTO v_GiaDV
        FROM   DICH_VU
        WHERE  MaDV = NEW.MaDV;

        IF v_GiaDV IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Dich vu khong ton tai';
        END IF;

        SET NEW.DonGiaThoiDiem = v_GiaDV;
    END IF;
END$$

CREATE TRIGGER trg_SDDV_TinhThanhTien_BU
BEFORE UPDATE ON SU_DUNG_DICH_VU
FOR EACH ROW
BEGIN
    DECLARE v_TrangThaiHD VARCHAR(20);
    DECLARE v_GiaDV       DECIMAL(18,2);

    SELECT TrangThai INTO v_TrangThaiHD
    FROM   HOA_DON
    WHERE  MaDatPhong = OLD.MaDatPhong;

    IF v_TrangThaiHD IN ('DaThanhToan', 'DaHuy') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hoa don da thanh toan hoac da huy, khong the sua dich vu';
    END IF;

    IF NEW.MaDV <> OLD.MaDV AND NEW.DonGiaThoiDiem = OLD.DonGiaThoiDiem THEN
        SELECT GiaDV INTO v_GiaDV
        FROM   DICH_VU
        WHERE  MaDV = NEW.MaDV;

        IF v_GiaDV IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Dich vu khong ton tai';
        END IF;

        SET NEW.DonGiaThoiDiem = v_GiaDV;
    END IF;
END$$

-- RB-05. Tong am (coc lon hon hoa don) thi ghi 0.
CREATE TRIGGER trg_CTHD_CapNhatTongTien_AI
AFTER INSERT ON CHI_TIET_HOA_DON
FOR EACH ROW
BEGIN
    UPDATE HOA_DON
    SET    TongTien = GREATEST(
               (SELECT COALESCE(SUM(SoTien), 0)
                FROM   CHI_TIET_HOA_DON
                WHERE  MaHoaDon = NEW.MaHoaDon), 0)
    WHERE  MaHoaDon = NEW.MaHoaDon;
END$$

CREATE TRIGGER trg_CTHD_CapNhatTongTien_AU
AFTER UPDATE ON CHI_TIET_HOA_DON
FOR EACH ROW
BEGIN
    UPDATE HOA_DON
    SET    TongTien = GREATEST(
               (SELECT COALESCE(SUM(SoTien), 0)
                FROM   CHI_TIET_HOA_DON
                WHERE  MaHoaDon = NEW.MaHoaDon), 0)
    WHERE  MaHoaDon = NEW.MaHoaDon;

    IF OLD.MaHoaDon <> NEW.MaHoaDon THEN
        UPDATE HOA_DON
        SET    TongTien = GREATEST(
                   (SELECT COALESCE(SUM(SoTien), 0)
                    FROM   CHI_TIET_HOA_DON
                    WHERE  MaHoaDon = OLD.MaHoaDon), 0)
        WHERE  MaHoaDon = OLD.MaHoaDon;
    END IF;
END$$

CREATE TRIGGER trg_CTHD_CapNhatTongTien_AD
AFTER DELETE ON CHI_TIET_HOA_DON
FOR EACH ROW
BEGIN
    UPDATE HOA_DON
    SET    TongTien = GREATEST(
               (SELECT COALESCE(SUM(SoTien), 0)
                FROM   CHI_TIET_HOA_DON
                WHERE  MaHoaDon = OLD.MaHoaDon), 0)
    WHERE  MaHoaDon = OLD.MaHoaDon;
END$$

-- RB-10
CREATE TRIGGER trg_PDP_KiemSoatVongDoi
BEFORE UPDATE ON PHIEU_DAT_PHONG
FOR EACH ROW
BEGIN
    IF OLD.TrangThai <> NEW.TrangThai THEN
        IF OLD.TrangThai = 'DaDat' AND NEW.TrangThai NOT IN ('DangO', 'DaHuy') THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Loi nghiep vu: Phieu DaDat chi co the chuyen sang DangO hoac DaHuy!';
        END IF;

        IF OLD.TrangThai = 'DangO' AND NEW.TrangThai <> 'HoanTat' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Loi nghiep vu: Phieu DangO chi co the chuyen sang HoanTat (khong duoc phep huy)!';
        END IF;

        IF OLD.TrangThai IN ('HoanTat', 'DaHuy') THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Loi nghiep vu: Khong the thay doi trang thai cua phieu dat phong da dong!';
        END IF;
    END IF;
END$$

-- RB-11
CREATE TRIGGER trg_PDP_ChongXoaVatLy
BEFORE DELETE ON PHIEU_DAT_PHONG
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nghiep vu: Khong duoc phep xoa vat ly phieu dat phong! Vui long cap nhat TrangThai sang DaHuy.';
END$$

-- RB-12
CREATE TRIGGER trg_BangGia_KhongGiaoNhau_BI
BEFORE INSERT ON BANG_GIA_PHONG
FOR EACH ROW
BEGIN
    DECLARE v_MaTrung  CHAR(10) DEFAULT NULL;
    DECLARE v_ThongBao VARCHAR(128);

    SELECT bg.MaBangGia
    INTO   v_MaTrung
    FROM   BANG_GIA_PHONG bg
    WHERE  bg.MaLoaiPhong    =  NEW.MaLoaiPhong
      AND  NEW.ApDungTuNgay  <= bg.DenNgay
      AND  NEW.DenNgay       >= bg.ApDungTuNgay
    LIMIT  1;

    IF v_MaTrung IS NOT NULL THEN
        SET v_ThongBao = LEFT(CONCAT('Khoang ngay ap dung gia bi chong voi bang gia ',
                                     v_MaTrung), 128);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ThongBao;
    END IF;
END$$

CREATE TRIGGER trg_BangGia_KhongGiaoNhau_BU
BEFORE UPDATE ON BANG_GIA_PHONG
FOR EACH ROW
BEGIN
    DECLARE v_MaTrung  CHAR(10) DEFAULT NULL;
    DECLARE v_ThongBao VARCHAR(128);

    SELECT bg.MaBangGia
    INTO   v_MaTrung
    FROM   BANG_GIA_PHONG bg
    WHERE  bg.MaLoaiPhong    =  NEW.MaLoaiPhong
      AND  bg.MaBangGia      <> OLD.MaBangGia
      AND  NEW.ApDungTuNgay  <= bg.DenNgay
      AND  NEW.DenNgay       >= bg.ApDungTuNgay
    LIMIT  1;

    IF v_MaTrung IS NOT NULL THEN
        SET v_ThongBao = LEFT(CONCAT('Khoang ngay ap dung gia bi chong voi bang gia ',
                                     v_MaTrung), 128);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ThongBao;
    END IF;
END$$

DELIMITER ;

-- Mong doi: 13 trigger tren 5 bang.
SELECT EVENT_OBJECT_TABLE AS Bang, TRIGGER_NAME,
       ACTION_TIMING AS Luc, EVENT_MANIPULATION AS SuKien
FROM   information_schema.TRIGGERS
WHERE  TRIGGER_SCHEMA = 'QuanLyKhachSan'
ORDER  BY EVENT_OBJECT_TABLE, TRIGGER_NAME;
