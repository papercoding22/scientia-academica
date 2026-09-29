-- 06. THU TUC NOI TAI (muc 4.1.1, Bang 4.1; bao cao muc 4.3). Can: 01, 02, 04, 05.
-- Moi thao tac ghi di qua cac thu tuc nay; 08 khong cap quyen ghi truc tiep tren bang.

USE QuanLyKhachSan;

DROP PROCEDURE IF EXISTS sp_DangNhap;
DROP PROCEDURE IF EXISTS sp_TraCuuPhongTrong;
DROP PROCEDURE IF EXISTS sp_DatPhong;
DROP PROCEDURE IF EXISTS sp_XacNhanDatCoc;
DROP PROCEDURE IF EXISTS sp_NhanPhong;
DROP PROCEDURE IF EXISTS sp_GhiNhanDichVu;
DROP PROCEDURE IF EXISTS sp_LapHoaDon;
DROP PROCEDURE IF EXISTS sp_ThanhToanHoaDon;
DROP PROCEDURE IF EXISTS sp_TraPhong;
DROP PROCEDURE IF EXISTS sp_GhiNhanDonPhong;
DROP PROCEDURE IF EXISTS sp_GhiNhanSuaPhong;
DROP PROCEDURE IF EXISTS sp_BaoDonPhong;
DROP PROCEDURE IF EXISTS sp_BaoBaoTri;
DROP PROCEDURE IF EXISTS sp_HuyPhieuDat;
DROP PROCEDURE IF EXISTS sp_DatGiaPhong;
DROP PROCEDURE IF EXISTS sp_CapNhatGiaLoaiPhong;
DROP PROCEDURE IF EXISTS sp_ChuanHoaKhachHang;
DROP PROCEDURE IF EXISTS sp_ThemKhachHang;
DROP PROCEDURE IF EXISTS sp_SuaKhachHang;
DROP PROCEDURE IF EXISTS sp_BaoCaoDoanhThu;
DROP PROCEDURE IF EXISTS sp_BaoCaoCongSuat;
DROP PROCEDURE IF EXISTS sp_BaoCaoKhachHang;
DROP PROCEDURE IF EXISTS sp_BaoCaoBuongPhong;
DROP PROCEDURE IF EXISTS sp_BaoCaoCongNo;

DELIMITER $$

-- Sai ten dang nhap hay sai mat khau deu bao cung mot loi de khong lo ten dang nhap.
CREATE PROCEDURE sp_DangNhap (
    IN p_TenDangNhap VARCHAR(50),
    IN p_MatKhau     VARCHAR(255)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_MaTK      CHAR(10)     DEFAULT NULL;
    DECLARE v_MatKhau   VARCHAR(255) DEFAULT NULL;
    DECLARE v_TrangThai VARCHAR(20)  DEFAULT NULL;
    DECLARE v_ThongBao  VARCHAR(128);

    SELECT MaTK, MatKhau, TrangThai
    INTO   v_MaTK, v_MatKhau, v_TrangThai
    FROM   TAI_KHOAN
    WHERE  TenDangNhap = p_TenDangNhap;

    IF v_MaTK IS NULL
       OR LOWER(v_MatKhau) <> SHA2(COALESCE(p_MatKhau, ''), 256) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ten dang nhap hoac mat khau khong dung';
    END IF;

    IF v_TrangThai <> 'DangLamViec' THEN
        SET v_ThongBao = CONCAT('Tai khoan dang o trang thai ', v_TrangThai,
                                ', khong the dang nhap');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ThongBao;
    END IF;

    SELECT tk.MaTK,
           tk.TenDangNhap,
           tk.HoTen,
           tk.MaLoaiTK,
           ltk.TenLoaiTK AS VaiTro
    FROM   TAI_KHOAN      tk
    JOIN   LOAI_TAI_KHOAN ltk ON ltk.MaLoaiTK = tk.MaLoaiTK
    WHERE  tk.MaTK = v_MaTK;
END$$

-- Cung vi tu phong kha dung voi sp_DatPhong va fn_SoPhongKhaDung; don gia la
-- fn_DonGiaTrungBinh, dung so sp_DatPhong se chot.
CREATE PROCEDURE sp_TraCuuPhongTrong (
    IN p_NgayCheckIn  DATE,
    IN p_NgayCheckOut DATE,
    IN p_MaLoaiPhong  CHAR(10)      -- NULL = tat ca cac loai phong
)
SQL SECURITY DEFINER
BEGIN
    IF p_NgayCheckIn IS NULL OR p_NgayCheckOut IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phai nhap ngay nhan va ngay tra phong';
    END IF;

    IF p_NgayCheckOut <= p_NgayCheckIn THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ngay tra phong phai sau ngay nhan phong';
    END IF;

    IF p_MaLoaiPhong IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM LOAI_PHONG WHERE MaLoaiPhong = p_MaLoaiPhong) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loai phong khong ton tai';
    END IF;

    SELECT p.MaPhong,
           p.SoPhong,
           p.Tang,
           p.MaLoaiPhong,
           lp.TenLoaiPhong,
           fn_DonGiaTrungBinh(p.MaLoaiPhong, p_NgayCheckIn, p_NgayCheckOut) AS DonGiaMotDem,
           fn_SoDem(p_NgayCheckIn, p_NgayCheckOut)                          AS SoDem,
           fn_DonGiaTrungBinh(p.MaLoaiPhong, p_NgayCheckIn, p_NgayCheckOut)
               * fn_SoDem(p_NgayCheckIn, p_NgayCheckOut)                    AS TamTinh,
           p.TrangThai
    FROM   PHONG      p
    JOIN   LOAI_PHONG lp ON lp.MaLoaiPhong = p.MaLoaiPhong
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
           )
    ORDER  BY lp.DonGiaNgay, p.SoPhong;
END$$

-- RB-01, RB-06. p_DanhSachPhong: cac MaPhong cach nhau dau phay.
-- Khoa PHONG bang FOR UPDATE; READ COMMITTED de thay phieu vua ghi sau khi cho khoa.
-- Don gia = fn_DonGiaTrungBinh (trung binh gia tung dem), chot vao GiaThueThoiDiem.
CREATE PROCEDURE sp_DatPhong (
    IN  p_MaKH          CHAR(10),
    IN  p_MaTK          CHAR(10),
    IN  p_NgayCheckIn   DATE,
    IN  p_NgayCheckOut  DATE,
    IN  p_DanhSachPhong VARCHAR(1000),
    IN  p_TienCoc       DECIMAL(18,2),
    OUT p_MaDatPhong    CHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_SoDem    INT;
    DECLARE v_SoPhong  INT DEFAULT 0;
    DECLARE v_SoTonTai INT DEFAULT 0;
    DECLARE v_Next     INT;
    DECLARE v_PhongLoi VARCHAR(500) DEFAULT NULL;
    DECLARE v_ThongBao VARCHAR(128);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        DROP TEMPORARY TABLE IF EXISTS tmp_PhongDat;
        RESIGNAL;
    END;

    SET p_MaDatPhong = NULL;
    SET p_TienCoc    = COALESCE(p_TienCoc, 0);

    IF p_NgayCheckIn IS NULL OR p_NgayCheckOut IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phai nhap ngay nhan va ngay tra phong';
    END IF;

    IF p_NgayCheckOut <= p_NgayCheckIn THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ngay tra phong phai sau ngay nhan phong';
    END IF;

    IF p_NgayCheckIn < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Khong the dat phong cho ngay da qua';
    END IF;

    IF p_TienCoc < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tien coc khong duoc am';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM KHACH_HANG WHERE MaKH = p_MaKH) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khach hang khong ton tai';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM TAI_KHOAN
                   WHERE MaTK = p_MaTK AND TrangThai = 'DangLamViec') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tai khoan lap phieu khong ton tai hoac khong con lam viec';
    END IF;

    SET v_SoDem = DATEDIFF(p_NgayCheckOut, p_NgayCheckIn);

    DROP TEMPORARY TABLE IF EXISTS tmp_PhongDat;
    CREATE TEMPORARY TABLE tmp_PhongDat (MaPhong CHAR(10) PRIMARY KEY);

    INSERT IGNORE INTO tmp_PhongDat (MaPhong)
    SELECT jt.MaPhong
    FROM   JSON_TABLE(
               CONCAT('["',
                      REPLACE(TRIM(BOTH ',' FROM REPLACE(p_DanhSachPhong, ' ', '')),
                              ',', '","'),
                      '"]'),
               '$[*]' COLUMNS (MaPhong CHAR(10) PATH '$')
           ) AS jt
    WHERE  jt.MaPhong IS NOT NULL AND jt.MaPhong <> '';

    SELECT COUNT(*) INTO v_SoPhong FROM tmp_PhongDat;

    IF v_SoPhong = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phai chon it nhat mot phong';
    END IF;

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;

    -- Khoa theo thu tu MaPhong de tranh deadlock.
    SELECT COUNT(*) INTO v_SoTonTai
    FROM   PHONG
    WHERE  MaPhong IN (SELECT MaPhong FROM tmp_PhongDat)
    FOR    UPDATE;

    IF v_SoTonTai <> v_SoPhong THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Co ma phong khong ton tai trong danh sach';
    END IF;

    SELECT GROUP_CONCAT(p.SoPhong ORDER BY p.SoPhong SEPARATOR ', ')
    INTO   v_PhongLoi
    FROM   PHONG p
    WHERE  p.MaPhong IN (SELECT MaPhong FROM tmp_PhongDat)
      AND  p.TrangThai IN ('BaoTri', 'DangDon');

    IF v_PhongLoi IS NOT NULL THEN
        SET v_ThongBao = LEFT(CONCAT('Phong dang bao tri hoac cho don: ',
                                     v_PhongLoi), 128);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ThongBao;
    END IF;

    SELECT GROUP_CONCAT(DISTINCT p.SoPhong ORDER BY p.SoPhong SEPARATOR ', ')
    INTO   v_PhongLoi
    FROM   CHI_TIET_DAT_PHONG ct
    JOIN   PHIEU_DAT_PHONG    pd ON pd.MaDatPhong = ct.MaDatPhong
    JOIN   PHONG              p  ON p.MaPhong     = ct.MaPhong
    WHERE  ct.MaPhong IN (SELECT MaPhong FROM tmp_PhongDat)
      AND  pd.TrangThai   IN ('DaDat', 'DangO')
      AND  pd.NgayCheckIn <  p_NgayCheckOut
      AND  p_NgayCheckIn  <  pd.NgayCheckOut;

    IF v_PhongLoi IS NOT NULL THEN
        SET v_ThongBao = LEFT(CONCAT('Phong da co nguoi dat trong khoang ngay nay: ',
                                     v_PhongLoi), 128);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ThongBao;
    END IF;

    SELECT COALESCE(MAX(CAST(SUBSTRING(MaDatPhong, 3) AS UNSIGNED)), 0) + 1
    INTO   v_Next
    FROM   PHIEU_DAT_PHONG;

    SET p_MaDatPhong = CONCAT('DP', LPAD(v_Next, 8, '0'));

    INSERT INTO PHIEU_DAT_PHONG
        (MaDatPhong, MaKH, MaTK, NgayLap, NgayCheckIn, NgayCheckOut,
         TienCoc, TrangThai)
    VALUES
        (p_MaDatPhong, p_MaKH, p_MaTK, NOW(), p_NgayCheckIn, p_NgayCheckOut,
         p_TienCoc, 'DaDat');

    INSERT INTO CHI_TIET_DAT_PHONG
        (MaDatPhong, MaPhong, GiaThueThoiDiem, SoDem)
    SELECT p_MaDatPhong,
           ph.MaPhong,
           fn_DonGiaTrungBinh(ph.MaLoaiPhong, p_NgayCheckIn, p_NgayCheckOut),
           v_SoDem
    FROM   PHONG        ph
    JOIN   tmp_PhongDat t ON t.MaPhong = ph.MaPhong;

    UPDATE PHONG
    SET    TrangThai = 'DaDat'
    WHERE  MaPhong IN (SELECT MaPhong FROM tmp_PhongDat)
      AND  TrangThai = 'Trong';

    COMMIT;
    DROP TEMPORARY TABLE IF EXISTS tmp_PhongDat;

    SELECT pd.MaDatPhong, pd.MaKH, pd.NgayCheckIn, pd.NgayCheckOut,
           pd.TienCoc, pd.TrangThai,
           p.SoPhong, ct.GiaThueThoiDiem, ct.SoDem, ct.ThanhTien
    FROM   PHIEU_DAT_PHONG    pd
    JOIN   CHI_TIET_DAT_PHONG ct ON ct.MaDatPhong = pd.MaDatPhong
    JOIN   PHONG              p  ON p.MaPhong     = ct.MaPhong
    WHERE  pd.MaDatPhong = p_MaDatPhong
    ORDER  BY p.SoPhong;
END$$

-- TienCoc cong don qua nhieu lan coc. Khong doi TrangThai vi luoc do khong co 'DaXacNhan'.
CREATE PROCEDURE sp_XacNhanDatCoc (
    IN p_MaDatPhong CHAR(10),
    IN p_SoTienCoc  DECIMAL(18,2)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_TyLeCoc       DECIMAL(4,2)  DEFAULT 0.50;
    DECLARE v_TrangThai     VARCHAR(20)   DEFAULT NULL;
    DECLARE v_NgayIn        DATE;
    DECLARE v_TienCocCu     DECIMAL(18,2);
    DECLARE v_TongTienPhong DECIMAL(18,2);
    DECLARE v_CocToiThieu   DECIMAL(18,2);
    DECLARE v_TienCocMoi    DECIMAL(18,2);
    DECLARE v_ThongBao      VARCHAR(128);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_SoTienCoc IS NULL OR p_SoTienCoc <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'So tien coc phai lon hon 0';
    END IF;

    START TRANSACTION;

    SELECT TrangThai, NgayCheckIn, TienCoc
    INTO   v_TrangThai, v_NgayIn, v_TienCocCu
    FROM   PHIEU_DAT_PHONG
    WHERE  MaDatPhong = p_MaDatPhong
    FOR    UPDATE;

    IF v_TrangThai IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phieu dat phong khong ton tai';
    END IF;

    IF v_TrangThai <> 'DaDat' THEN
        SET v_ThongBao = CONCAT('Chi nhan coc cho phieu DaDat. Phieu dang o trang thai: ',
                                v_TrangThai);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ThongBao;
    END IF;

    IF v_NgayIn < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phieu da qua ngay nhan phong, khong nhan coc';
    END IF;

    SELECT COALESCE(SUM(ThanhTien), 0)
    INTO   v_TongTienPhong
    FROM   CHI_TIET_DAT_PHONG
    WHERE  MaDatPhong = p_MaDatPhong;

    IF v_TongTienPhong = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phieu dat chua co phong nao';
    END IF;

    SET v_TienCocMoi  = COALESCE(v_TienCocCu, 0) + p_SoTienCoc;
    SET v_CocToiThieu = ROUND(v_TongTienPhong * v_TyLeCoc, 2);

    IF v_TienCocMoi > v_TongTienPhong THEN
        SET v_ThongBao = CONCAT('Tong tien coc (', v_TienCocMoi,
                                ') vuot tong tien phong (', v_TongTienPhong, ')');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ThongBao;
    END IF;

    UPDATE PHIEU_DAT_PHONG
    SET    TienCoc = v_TienCocMoi
    WHERE  MaDatPhong = p_MaDatPhong;

    COMMIT;

    SELECT MaDatPhong,
           TrangThai,
           TienCoc,
           v_TongTienPhong                      AS TongTienPhong,
           v_CocToiThieu                        AS CocToiThieu,
           GREATEST(v_CocToiThieu - TienCoc, 0) AS ConThieu,
           CASE WHEN TienCoc >= v_CocToiThieu THEN 'Da du coc'
                ELSE 'Chua du coc' END          AS KetLuan
    FROM   PHIEU_DAT_PHONG
    WHERE  MaDatPhong = p_MaDatPhong;
END$$

CREATE PROCEDURE sp_NhanPhong (
    IN p_MaDatPhong CHAR(10),
    IN p_MaTK       CHAR(10)
)
proc_label: BEGIN
    DECLARE v_TrangThaiPDP VARCHAR(20);
    DECLARE v_CountPhongKhongHopLe INT DEFAULT 0;

    SELECT TrangThai INTO v_TrangThaiPDP
    FROM PHIEU_DAT_PHONG
    WHERE MaDatPhong = p_MaDatPhong;

    IF v_TrangThaiPDP IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi: Khong tim thay ma phieu dat phong!';
    END IF;

    IF v_TrangThaiPDP <> 'DaDat' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi: Phieu dat phong phai o trang thai DaDat moi duoc nhan phong!';
    END IF;

    -- Phong phai Trong, hoac DaDat vi sp_DatPhong (buoc 3f) giu phong cho phieu
    -- bang cach chuyen sang DaDat. trg_CTDP_ChongTrungPhong bao dam khong co
    -- phieu hieu luc nao khac giu phong trong khoang ngay cua phieu nay.
    SELECT COUNT(*) INTO v_CountPhongKhongHopLe
    FROM CHI_TIET_DAT_PHONG ctdp
    JOIN PHONG p ON ctdp.MaPhong = p.MaPhong
    WHERE ctdp.MaDatPhong = p_MaDatPhong
      AND p.TrangThai NOT IN ('Trong', 'DaDat');

    IF v_CountPhongKhongHopLe > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi: Co phong chua san sang (phong phai Trong hoac DaDat)!';
    END IF;

    UPDATE PHONG
    SET TrangThai = 'DangSuDung'
    WHERE MaPhong IN (
        SELECT MaPhong 
        FROM CHI_TIET_DAT_PHONG 
        WHERE MaDatPhong = p_MaDatPhong
    );

    UPDATE PHIEU_DAT_PHONG
    SET TrangThai = 'DangO'
    WHERE MaDatPhong = p_MaDatPhong;

    SELECT CONCAT('Nhan phong thanh cong cho phieu dat: ', p_MaDatPhong) AS KetQua;
END$$

-- Hoa don nhap da co thi tinh lai ngay trong giao dich nay (nhu sp_LapHoaDon
-- khi lap lai), de sp_ThanhToanHoaDon khong tu choi vi lech fn_TienDichVu.
CREATE PROCEDURE sp_GhiNhanDichVu (
    IN  p_MaDatPhong  CHAR(10),
    IN  p_MaDV        CHAR(10),
    IN  p_SoLuong     INT,
    IN  p_NgaySuDung  DATETIME,     -- NULL = bay gio
    OUT p_MaSuDungDV  CHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_TrangThai   VARCHAR(20);
    DECLARE v_NgayCheckIn DATE;
    DECLARE v_TrangThaiHD VARCHAR(20);
    DECLARE v_MaHoaDon    CHAR(10);
    DECLARE v_GiaDV       DECIMAL(18,2);
    DECLARE v_Next        INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_SoLuong IS NULL OR p_SoLuong <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'So luong phai lon hon 0';
    END IF;

    SET p_NgaySuDung = COALESCE(p_NgaySuDung, NOW());

    START TRANSACTION;

    -- Khoa phieu de khong ghi song song voi sp_LapHoaDon.
    SELECT TrangThai, NgayCheckIn
    INTO   v_TrangThai, v_NgayCheckIn
    FROM   PHIEU_DAT_PHONG
    WHERE  MaDatPhong = p_MaDatPhong
    FOR UPDATE;

    IF v_TrangThai IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phieu dat phong khong ton tai';
    END IF;

    IF v_TrangThai <> 'DangO' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Chi ghi nhan dich vu cho phieu dang o (DangO)';
    END IF;

    IF DATE(p_NgaySuDung) < v_NgayCheckIn THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ngay su dung dich vu truoc ngay check-in';
    END IF;

    SELECT MaHoaDon, TrangThai INTO v_MaHoaDon, v_TrangThaiHD
    FROM   HOA_DON
    WHERE  MaDatPhong = p_MaDatPhong;

    IF v_TrangThaiHD IS NOT NULL AND v_TrangThaiHD <> 'ChuaThanhToan' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hoa don da thanh toan hoac da huy';
    END IF;

    SELECT GiaDV INTO v_GiaDV
    FROM   DICH_VU
    WHERE  MaDV = p_MaDV;

    IF v_GiaDV IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dich vu khong ton tai';
    END IF;

    SELECT COALESCE(MAX(CAST(SUBSTRING(MaSuDungDV, 3) AS UNSIGNED)), 0) + 1
    INTO   v_Next
    FROM   SU_DUNG_DICH_VU;

    SET p_MaSuDungDV = CONCAT('SD', LPAD(v_Next, 8, '0'));

    INSERT INTO SU_DUNG_DICH_VU
        (MaSuDungDV, MaDatPhong, MaDV, NgaySuDung, SoLuong, DonGiaThoiDiem)
    VALUES
        (p_MaSuDungDV, p_MaDatPhong, p_MaDV, p_NgaySuDung, p_SoLuong, v_GiaDV);

    -- Hoa don nhap da lap: xoa cac dong tu sinh roi sinh lai (PhuThu / GiamGia
    -- nhap tay giu nguyen), cung cach sp_LapHoaDon lap lai. Khong CALL
    -- sp_LapHoaDon vi thu tuc do tu mo giao dich va tra them hai result set.
    IF v_TrangThaiHD = 'ChuaThanhToan' THEN
        DELETE FROM CHI_TIET_HOA_DON
        WHERE  MaHoaDon = v_MaHoaDon
          AND  LoaiKhoanMuc IN ('TienPhong', 'DichVu', 'GiamTru');

        CALL sp_LapChiTietHoaDon(v_MaHoaDon);
    END IF;

    COMMIT;

    SELECT MaSuDungDV, MaDatPhong, MaDV, NgaySuDung, SoLuong,
           DonGiaThoiDiem, ThanhTien
    FROM   SU_DUNG_DICH_VU
    WHERE  MaSuDungDV = p_MaSuDungDV;
END$$

-- Goi lai nhieu lan van cho cung ket qua: xoa dong tu sinh roi tinh lai, giu
-- PhuThu / GiamGia nhap tay. Phieu DaDat chi co hoa don nhap (TongTien = 0).
CREATE PROCEDURE sp_LapHoaDon (
    IN  p_MaDatPhong CHAR(10),
    OUT p_MaHoaDon   CHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_TrangThaiPhieu VARCHAR(20);
    DECLARE v_TrangThaiHD    VARCHAR(20);
    DECLARE v_Next           INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT TrangThai INTO v_TrangThaiPhieu
    FROM   PHIEU_DAT_PHONG
    WHERE  MaDatPhong = p_MaDatPhong
    FOR UPDATE;

    IF v_TrangThaiPhieu IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phieu dat phong khong ton tai';
    END IF;

    IF v_TrangThaiPhieu = 'DaHuy' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phieu dat phong da huy';
    END IF;

    IF v_TrangThaiPhieu IN ('DangO', 'HoanTat')
       AND NOT EXISTS (SELECT 1 FROM CHI_TIET_DAT_PHONG
                       WHERE MaDatPhong = p_MaDatPhong) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phieu chua duoc gan phong';
    END IF;

    SELECT MaHoaDon, TrangThai
    INTO   p_MaHoaDon, v_TrangThaiHD
    FROM   HOA_DON
    WHERE  MaDatPhong = p_MaDatPhong
    FOR UPDATE;

    IF p_MaHoaDon IS NOT NULL THEN
        IF v_TrangThaiHD <> 'ChuaThanhToan' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Hoa don da thanh toan hoac da huy, khong the lap lai';
        END IF;

        DELETE FROM CHI_TIET_HOA_DON
        WHERE  MaHoaDon = p_MaHoaDon
          AND  LoaiKhoanMuc IN ('TienPhong', 'DichVu', 'GiamTru');

        UPDATE HOA_DON SET NgayLap = NOW() WHERE MaHoaDon = p_MaHoaDon;
    ELSE
        SELECT COALESCE(MAX(CAST(SUBSTRING(MaHoaDon, 3) AS UNSIGNED)), 0) + 1
        INTO   v_Next
        FROM   HOA_DON;

        SET p_MaHoaDon = CONCAT('HD', LPAD(v_Next, 8, '0'));

        INSERT INTO HOA_DON
            (MaHoaDon, MaDatPhong, NgayLap, TongTien, LoaiThanhToan, TrangThai)
        VALUES
            (p_MaHoaDon, p_MaDatPhong, NOW(), 0, NULL, 'ChuaThanhToan');
    END IF;

    IF v_TrangThaiPhieu IN ('DangO', 'HoanTat') THEN
        CALL sp_LapChiTietHoaDon(p_MaHoaDon);
    END IF;

    COMMIT;

    SELECT hd.MaHoaDon, hd.MaDatPhong, hd.NgayLap, hd.TongTien, hd.TrangThai
    FROM   HOA_DON hd
    WHERE  hd.MaHoaDon = p_MaHoaDon;

    SELECT ct.MaCTHD, ct.LoaiKhoanMuc, ct.SoTien, ct.GhiChu
    FROM   CHI_TIET_HOA_DON ct
    WHERE  ct.MaHoaDon = p_MaHoaDon
    ORDER  BY ct.MaCTHD;
END$$

CREATE PROCEDURE sp_ThanhToanHoaDon (
    IN p_MaHoaDon      CHAR(10),
    IN p_LoaiThanhToan VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_MaDatPhong CHAR(10);
    DECLARE v_TrangThai  VARCHAR(20);
    DECLARE v_TienPhongHD DECIMAL(18,2);
    DECLARE v_TienDVHD    DECIMAL(18,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_LoaiThanhToan IS NULL
       OR p_LoaiThanhToan NOT IN ('TienMat', 'ChuyenKhoan', 'The') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loai thanh toan phai la TienMat, ChuyenKhoan hoac The';
    END IF;

    START TRANSACTION;

    SELECT MaDatPhong, TrangThai
    INTO   v_MaDatPhong, v_TrangThai
    FROM   HOA_DON
    WHERE  MaHoaDon = p_MaHoaDon
    FOR UPDATE;

    IF v_MaDatPhong IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hoa don khong ton tai';
    END IF;

    IF v_TrangThai = 'DaThanhToan' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hoa don da duoc thanh toan';
    END IF;

    IF v_TrangThai = 'DaHuy' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hoa don da huy';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM CHI_TIET_HOA_DON WHERE MaHoaDon = p_MaHoaDon) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hoa don nhap chua co chi tiet, hay lap hoa don truoc';
    END IF;

    SELECT COALESCE(SUM(CASE WHEN LoaiKhoanMuc = 'TienPhong' THEN SoTien END), 0),
           COALESCE(SUM(CASE WHEN LoaiKhoanMuc = 'DichVu'    THEN SoTien END), 0)
    INTO   v_TienPhongHD, v_TienDVHD
    FROM   CHI_TIET_HOA_DON
    WHERE  MaHoaDon = p_MaHoaDon;

    IF v_TienPhongHD <> fn_TienPhong(v_MaDatPhong)
       OR v_TienDVHD <> fn_TienDichVu(v_MaDatPhong) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hoa don khong khop tien phong/dich vu hien tai, hay chay lai sp_LapHoaDon';
    END IF;

    UPDATE HOA_DON
    SET    LoaiThanhToan = p_LoaiThanhToan,
           TrangThai     = 'DaThanhToan'
    WHERE  MaHoaDon = p_MaHoaDon;

    COMMIT;

    SELECT MaHoaDon, MaDatPhong, TongTien, LoaiThanhToan, TrangThai
    FROM   HOA_DON
    WHERE  MaHoaDon = p_MaHoaDon;
END$$

CREATE PROCEDURE sp_TraPhong (
    IN p_MaDatPhong CHAR(10)
)
BEGIN
    DECLARE v_TrangThaiPDP VARCHAR(20);
    DECLARE v_TrangThaiHD  VARCHAR(20);

    SELECT TrangThai INTO v_TrangThaiPDP
    FROM PHIEU_DAT_PHONG
    WHERE MaDatPhong = p_MaDatPhong;

    IF v_TrangThaiPDP IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi: Ma phieu dat phong khong ton tai!';
    END IF;

    IF v_TrangThaiPDP <> 'DangO' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi: Phieu dat phong phai o trang thai DangO moi duoc tra phong!';
    END IF;

    SELECT TrangThai INTO v_TrangThaiHD
    FROM HOA_DON
    WHERE MaDatPhong = p_MaDatPhong;

    IF v_TrangThaiHD IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi: Phieu dat phong chua xuat hoa don!';
    END IF;

    IF v_TrangThaiHD <> 'DaThanhToan' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi: Hoa don chua duoc thanh toan, khong the hoan tat tra phong!';
    END IF;

    UPDATE PHIEU_DAT_PHONG
    SET TrangThai = 'HoanTat'
    WHERE MaDatPhong = p_MaDatPhong;

    UPDATE PHONG
    SET TrangThai = 'DangDon'
    WHERE MaPhong IN (
        SELECT MaPhong 
        FROM CHI_TIET_DAT_PHONG 
        WHERE MaDatPhong = p_MaDatPhong
    );

    SELECT CONCAT('Tra phong thanh cong cho phieu dat: ', p_MaDatPhong) AS KetQua;
END$$

-- Vong doi buong phong (spec bo sung nghiep vu muc 4.1):
--   sp_BaoDonPhong      Trong / DaDat            -> DangDon
--   sp_BaoBaoTri        Trong / DaDat / DangDon  -> BaoTri (mo phieu SUA_PHONG 0d)
--   sp_GhiNhanSuaPhong  BaoTri                   -> DangDon (dong phieu dang mo)
--   sp_GhiNhanDonPhong  DangDon                  -> DaDat neu con phieu DaDat giu phong, khong thi Trong
-- Phieu bao tri dang mo cua mot phong BaoTri la dong SUA_PHONG moi nhat cua
-- phong do (ThoiGian DESC, MaSua DESC).

-- Khong co bang luu nguoi bao don, nen khong nhan MaTK.
CREATE PROCEDURE sp_BaoDonPhong (
    IN p_MaPhong CHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_TrangThai VARCHAR(20) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT TrangThai INTO v_TrangThai
    FROM   PHONG
    WHERE  MaPhong = p_MaPhong
    FOR    UPDATE;

    IF v_TrangThai IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phong khong ton tai';
    END IF;

    IF v_TrangThai = 'DangDon' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phong da nam trong danh sach cho don';
    END IF;

    IF v_TrangThai = 'DangSuDung' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phong dang co khach: buong phong ghi nhan don truc tiep';
    END IF;

    IF v_TrangThai = 'BaoTri' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phong dang bao tri, se sang cho don khi ky thuat sua xong';
    END IF;

    UPDATE PHONG
    SET    TrangThai = 'DangDon'
    WHERE  MaPhong = p_MaPhong;

    COMMIT;

    SELECT MaPhong, SoPhong, TrangThai
    FROM   PHONG
    WHERE  MaPhong = p_MaPhong;
END$$

-- Mo phieu bao tri: mot dong SUA_PHONG chi phi 0, MaTK la nguoi bao.
CREATE PROCEDURE sp_BaoBaoTri (
    IN p_MaPhong CHAR(10),
    IN p_MaTK    CHAR(10),
    IN p_MoTa    VARCHAR(200)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_TrangThai VARCHAR(20) DEFAULT NULL;
    DECLARE v_MaSua     CHAR(10);
    DECLARE v_Next      INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET p_MoTa = TRIM(p_MoTa);

    IF p_MoTa IS NULL OR p_MoTa = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phai mo ta su co can bao tri';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM TAI_KHOAN
                   WHERE MaTK = p_MaTK AND TrangThai = 'DangLamViec') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tai khoan bao su co khong ton tai hoac khong con lam viec';
    END IF;

    START TRANSACTION;

    SELECT TrangThai INTO v_TrangThai
    FROM   PHONG
    WHERE  MaPhong = p_MaPhong
    FOR    UPDATE;

    IF v_TrangThai IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phong khong ton tai';
    END IF;

    IF v_TrangThai = 'DangSuDung' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phong dang co khach luu tru, khong the dua vao bao tri';
    END IF;

    IF v_TrangThai = 'BaoTri' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phong dang bao tri, da co phieu dang mo';
    END IF;

    SELECT IFNULL(MAX(CAST(SUBSTRING(MaSua, 4) AS UNSIGNED)), 0) + 1
    INTO   v_Next
    FROM   SUA_PHONG;

    SET v_MaSua = CONCAT('SUA', LPAD(v_Next, 7, '0'));

    INSERT INTO SUA_PHONG (MaSua, MaPhong, MaTK, ThoiGian, ChiPhi, MoTaLoi)
    VALUES (v_MaSua, p_MaPhong, p_MaTK, NOW(), 0, p_MoTa);

    UPDATE PHONG
    SET    TrangThai = 'BaoTri'
    WHERE  MaPhong = p_MaPhong;

    COMMIT;

    SELECT v_MaSua AS MaSua, p_MaPhong AS MaPhong;
END$$

CREATE PROCEDURE sp_GhiNhanDonPhong (
    IN p_MaPhong CHAR(10),
    IN p_MaTK    CHAR(10),
    IN p_GhiChu  VARCHAR(200)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_MaDon   CHAR(10);
    DECLARE v_NextVal INT DEFAULT 1;

    IF NOT EXISTS (SELECT 1 FROM TAI_KHOAN WHERE MaTK = p_MaTK) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi: Ma tai khoan nhan vien khong ton tai!';
    END IF;

    IF EXISTS (SELECT 1 FROM TAI_KHOAN
               WHERE MaTK = p_MaTK AND TrangThai <> 'DangLamViec') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tai khoan nhan vien khong con lam viec';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM PHONG WHERE MaPhong = p_MaPhong) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi: Ma phong khong ton tai!';
    END IF;

    SELECT IFNULL(MAX(CAST(SUBSTRING(MaDon, 4) AS UNSIGNED)), 0) + 1
    INTO   v_NextVal
    FROM   DON_PHONG;

    SET v_MaDon = CONCAT('DON', LPAD(v_NextVal, 7, '0'));

    INSERT INTO DON_PHONG (MaDon, MaPhong, MaTK, ThoiGian, GhiChu)
    VALUES (v_MaDon, p_MaPhong, p_MaTK, NOW(), p_GhiChu);

    -- Chi phong cho don (DangDon) doi trang thai: ve DaDat neu con phieu DaDat
    -- giu phong, khong thi ve Trong. Phong BaoTri phai sua xong truoc
    -- (sp_GhiNhanSuaPhong dua sang DangDon); phong co khach, dang giu hay dang
    -- trong chi ghi nhat ky.
    UPDATE PHONG p
    SET    p.TrangThai = IF(EXISTS (SELECT 1
                                    FROM   CHI_TIET_DAT_PHONG ct
                                    JOIN   PHIEU_DAT_PHONG    pd ON pd.MaDatPhong = ct.MaDatPhong
                                    WHERE  ct.MaPhong   = p.MaPhong
                                      AND  pd.TrangThai = 'DaDat'),
                            'DaDat', 'Trong')
    WHERE  p.MaPhong   = p_MaPhong
      AND  p.TrangThai = 'DangDon';

    SELECT CONCAT('Da ghi nhan don phong thanh cong. Ma don: ', v_MaDon) AS KetQua;
END$$

-- Ky thuat ghi nhan da sua xong: cap nhat phieu dang mo (chi phi, nguoi sua,
-- gio sua xong; mo ta rong thi giu mo ta cu) roi dua phong BaoTri -> DangDon.
-- Moi su co mot dong, nen sp_BaoCaoBuongPhong khong dem doi.
CREATE PROCEDURE sp_GhiNhanSuaPhong (
    IN p_MaPhong CHAR(10),
    IN p_MaTK    CHAR(10),
    IN p_ChiPhi  DECIMAL(18,2),
    IN p_MoTaLoi VARCHAR(200)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_TrangThai VARCHAR(20) DEFAULT NULL;
    DECLARE v_MaSua     CHAR(10)    DEFAULT NULL;
    DECLARE v_NextVal   INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_ChiPhi IS NULL OR p_ChiPhi < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chi phi sua chua khong duoc am';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM TAI_KHOAN WHERE MaTK = p_MaTK) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi: Ma tai khoan ky thuat khong ton tai!';
    END IF;

    IF EXISTS (SELECT 1 FROM TAI_KHOAN
               WHERE MaTK = p_MaTK AND TrangThai <> 'DangLamViec') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tai khoan ky thuat khong con lam viec';
    END IF;

    SET p_MoTaLoi = NULLIF(TRIM(p_MoTaLoi), '');

    START TRANSACTION;

    SELECT TrangThai INTO v_TrangThai
    FROM   PHONG
    WHERE  MaPhong = p_MaPhong
    FOR    UPDATE;

    IF v_TrangThai IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loi: Ma phong khong ton tai!';
    END IF;

    IF v_TrangThai <> 'BaoTri' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phong khong o trang thai bao tri, hay bao bao tri truoc';
    END IF;

    SELECT MaSua INTO v_MaSua
    FROM   SUA_PHONG
    WHERE  MaPhong = p_MaPhong
    ORDER  BY ThoiGian DESC, MaSua DESC
    LIMIT  1
    FOR    UPDATE;

    IF v_MaSua IS NULL THEN
        -- Phong BaoTri ma chua co dong nao (chi xay ra khi sua tay CSDL).
        SELECT IFNULL(MAX(CAST(SUBSTRING(MaSua, 4) AS UNSIGNED)), 0) + 1
        INTO   v_NextVal
        FROM   SUA_PHONG;

        SET v_MaSua = CONCAT('SUA', LPAD(v_NextVal, 7, '0'));

        INSERT INTO SUA_PHONG (MaSua, MaPhong, MaTK, ThoiGian, ChiPhi, MoTaLoi)
        VALUES (v_MaSua, p_MaPhong, p_MaTK, NOW(), p_ChiPhi, p_MoTaLoi);
    ELSE
        UPDATE SUA_PHONG
        SET    MaTK     = p_MaTK,
               ThoiGian = NOW(),
               ChiPhi   = p_ChiPhi,
               MoTaLoi  = COALESCE(p_MoTaLoi, MoTaLoi)
        WHERE  MaSua = v_MaSua;
    END IF;

    UPDATE PHONG
    SET    TrangThai = 'DangDon'
    WHERE  MaPhong = p_MaPhong;

    COMMIT;

    SELECT CONCAT('Da ghi nhan sua phong thanh cong. Ma sua: ', v_MaSua) AS KetQua;
END$$

-- RB-10, RB-11. Phong chi ve Trong khi khong con phieu hieu luc nao khac giu.
CREATE PROCEDURE sp_HuyPhieuDat (
    IN p_MaDatPhong CHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_TrangThai VARCHAR(20) DEFAULT NULL;
    DECLARE v_ThongBao  VARCHAR(128);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT TrangThai
    INTO   v_TrangThai
    FROM   PHIEU_DAT_PHONG
    WHERE  MaDatPhong = p_MaDatPhong
    FOR    UPDATE;

    IF v_TrangThai IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phieu dat phong khong ton tai';
    END IF;

    IF v_TrangThai = 'DangO' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phieu dang o, khong duoc huy. Hay dung nghiep vu tra phong';
    END IF;

    IF v_TrangThai <> 'DaDat' THEN
        SET v_ThongBao = CONCAT('Khong the huy phieu o trang thai: ', v_TrangThai);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ThongBao;
    END IF;

    UPDATE PHIEU_DAT_PHONG
    SET    TrangThai = 'DaHuy'
    WHERE  MaDatPhong = p_MaDatPhong;

    UPDATE PHONG p
    SET    p.TrangThai = 'Trong'
    WHERE  p.TrangThai = 'DaDat'
      AND  p.MaPhong IN (SELECT ct.MaPhong
                         FROM   CHI_TIET_DAT_PHONG ct
                         WHERE  ct.MaDatPhong = p_MaDatPhong)
      AND  NOT EXISTS (SELECT 1
                       FROM   CHI_TIET_DAT_PHONG ct2
                       JOIN   PHIEU_DAT_PHONG    pd2 ON pd2.MaDatPhong = ct2.MaDatPhong
                       WHERE  ct2.MaPhong    = p.MaPhong
                         AND  ct2.MaDatPhong <> p_MaDatPhong
                         AND  pd2.TrangThai  IN ('DaDat', 'DangO'));

    -- Hoa don nhap cua phieu (lap tu luc DaDat) huy theo, de khong con bi dem
    -- la hoa don chua thanh toan.
    UPDATE HOA_DON
    SET    TrangThai = 'DaHuy'
    WHERE  MaDatPhong = p_MaDatPhong
      AND  TrangThai  = 'ChuaThanhToan';

    COMMIT;

    SELECT pd.MaDatPhong, pd.TrangThai, pd.TienCoc,
           GROUP_CONCAT(p.SoPhong ORDER BY p.SoPhong SEPARATOR ', ') AS DanhSachPhong,
           GROUP_CONCAT(p.TrangThai ORDER BY p.SoPhong SEPARATOR ', ') AS TrangThaiPhong
    FROM   PHIEU_DAT_PHONG         pd
    LEFT   JOIN CHI_TIET_DAT_PHONG ct ON ct.MaDatPhong = pd.MaDatPhong
    LEFT   JOIN PHONG              p  ON p.MaPhong     = ct.MaPhong
    WHERE  pd.MaDatPhong = p_MaDatPhong
    GROUP  BY pd.MaDatPhong, pd.TrangThai, pd.TienCoc;
END$$

-- Noi bo cua sp_ThemKhachHang / sp_SuaKhachHang: chuan hoa roi kiem mot ho so
-- khach. p_MaKH = NULL khi them moi; khac NULL thi bo qua chinh khach do khi
-- kiem trung. SDT / Email rong thanh NULL: UQ_KHACH_HANG_Email cho nhieu NULL
-- nhung khong cho hai chuoi ''.
CREATE PROCEDURE sp_ChuanHoaKhachHang (
    IN    p_MaKH  CHAR(10),
    INOUT p_HoTen VARCHAR(100),
    INOUT p_CCCD  VARCHAR(20),
    INOUT p_SDT   VARCHAR(20),
    INOUT p_Email VARCHAR(100)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_MaTrung  CHAR(10) DEFAULT NULL;
    DECLARE v_ThongBao VARCHAR(128);

    SET p_HoTen = TRIM(p_HoTen);
    SET p_CCCD  = UPPER(TRIM(p_CCCD));
    SET p_SDT   = NULLIF(REGEXP_REPLACE(COALESCE(p_SDT, ''), '[ .-]', ''), '');
    SET p_Email = NULLIF(LOWER(TRIM(p_Email)), '');

    IF p_HoTen IS NULL OR p_HoTen = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ho ten khach hang khong duoc de trong';
    END IF;

    IF p_CCCD IS NULL OR NOT REGEXP_LIKE(p_CCCD, '^[0-9A-Z]{9,20}$', 'c') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'CCCD / ho chieu phai gom 9-20 chu so hoac chu cai';
    END IF;

    IF p_SDT IS NOT NULL AND NOT REGEXP_LIKE(p_SDT, '^[+]?[0-9]{9,14}$') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'So dien thoai phai gom 9-14 chu so, co the co dau + o dau';
    END IF;

    IF p_Email IS NOT NULL AND NOT REGEXP_LIKE(p_Email, '^[^@ ]+@[^@ ]+[.][^@ ]+$') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email khong dung dinh dang';
    END IF;

    SELECT MaKH INTO v_MaTrung
    FROM   KHACH_HANG
    WHERE  CCCD = p_CCCD
      AND  (p_MaKH IS NULL OR MaKH <> p_MaKH)
    LIMIT  1;

    IF v_MaTrung IS NOT NULL THEN
        SET v_ThongBao = CONCAT('CCCD da co trong ho so ', v_MaTrung);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ThongBao;
    END IF;

    IF p_Email IS NOT NULL THEN
        SELECT MaKH INTO v_MaTrung
        FROM   KHACH_HANG
        WHERE  Email = p_Email
          AND  (p_MaKH IS NULL OR MaKH <> p_MaKH)
        LIMIT  1;

        IF v_MaTrung IS NOT NULL THEN
            SET v_ThongBao = CONCAT('Email da co trong ho so ', v_MaTrung);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ThongBao;
        END IF;
    END IF;
END$$

CREATE PROCEDURE sp_ThemKhachHang (
    IN  p_HoTen VARCHAR(100),
    IN  p_CCCD  VARCHAR(20),
    IN  p_SDT   VARCHAR(20),
    IN  p_Email VARCHAR(100),
    OUT p_MaKH  CHAR(10)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_Next INT;

    SET p_MaKH = NULL;

    CALL sp_ChuanHoaKhachHang(NULL, p_HoTen, p_CCCD, p_SDT, p_Email);

    SELECT COALESCE(MAX(CAST(SUBSTRING(MaKH, 3) AS UNSIGNED)), 0) + 1
    INTO   v_Next
    FROM   KHACH_HANG;

    SET p_MaKH = CONCAT('KH', LPAD(v_Next, 8, '0'));

    INSERT INTO KHACH_HANG (MaKH, HoTen, CCCD, SDT, Email)
    VALUES (p_MaKH, p_HoTen, p_CCCD, p_SDT, p_Email);

    SELECT MaKH, HoTen, CCCD, SDT, Email
    FROM   KHACH_HANG
    WHERE  MaKH = p_MaKH;
END$$

CREATE PROCEDURE sp_SuaKhachHang (
    IN p_MaKH  CHAR(10),
    IN p_HoTen VARCHAR(100),
    IN p_CCCD  VARCHAR(20),
    IN p_SDT   VARCHAR(20),
    IN p_Email VARCHAR(100)
)
SQL SECURITY DEFINER
BEGIN
    IF NOT EXISTS (SELECT 1 FROM KHACH_HANG WHERE MaKH = p_MaKH) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khach hang khong ton tai';
    END IF;

    CALL sp_ChuanHoaKhachHang(p_MaKH, p_HoTen, p_CCCD, p_SDT, p_Email);

    UPDATE KHACH_HANG
    SET    HoTen = p_HoTen,
           CCCD  = p_CCCD,
           SDT   = p_SDT,
           Email = p_Email
    WHERE  MaKH = p_MaKH;

    SELECT MaKH, HoTen, CCCD, SDT, Email
    FROM   KHACH_HANG
    WHERE  MaKH = p_MaKH;
END$$

-- RB-12. Phu gia p_DonGia len doan [p_TuNgay, p_DenNgay] (tinh ca hai dau) cua
-- mot loai phong; p_DonGia = NULL tra doan do ve LOAI_PHONG.DonGiaNgay. Khoang
-- cu bi chong duoc xoa / cat / tach theo thu tu chi thu hep roi moi chen, nen
-- trg_BangGia_KhongGiaoNhau khong bao gio bao chong. Phieu da lap giu gia da
-- chot trong CHI_TIET_DAT_PHONG (QT-06).
CREATE PROCEDURE sp_DatGiaPhong (
    IN p_MaLoaiPhong CHAR(10),
    IN p_TuNgay      DATE,
    IN p_DenNgay     DATE,
    IN p_DonGia      DECIMAL(18,2)      -- NULL = ve gia goc
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_GiaGoc   DECIMAL(18,2) DEFAULT NULL;
    DECLARE v_HeSo     DECIMAL(24,2) DEFAULT NULL;
    DECLARE v_MaTach   CHAR(10)      DEFAULT NULL;
    DECLARE v_TachDen  DATE;
    DECLARE v_TachGia  DECIMAL(18,2);
    DECLARE v_TachHeSo DECIMAL(4,2);
    DECLARE v_Next     INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_TuNgay IS NULL OR p_DenNgay IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phai nhap tu ngay va den ngay';
    END IF;

    IF p_DenNgay < p_TuNgay THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Den ngay phai bang hoac sau tu ngay';
    END IF;

    IF p_TuNgay < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khong sua gia cho ngay da qua';
    END IF;

    IF p_DonGia IS NOT NULL AND p_DonGia <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Don gia phai lon hon 0';
    END IF;

    START TRANSACTION;

    -- Khoa loai phong: cac lan sua gia cua cung mot loai chay lan luot.
    SELECT DonGiaNgay INTO v_GiaGoc
    FROM   LOAI_PHONG
    WHERE  MaLoaiPhong = p_MaLoaiPhong
    FOR    UPDATE;

    IF v_GiaGoc IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loai phong khong ton tai';
    END IF;

    IF p_DonGia IS NOT NULL AND v_GiaGoc > 0 THEN
        SET v_HeSo = ROUND(p_DonGia / v_GiaGoc, 2);

        IF v_HeSo > 99.99 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Don gia vuot 99,99 lan gia goc cua loai phong';
        END IF;
    END IF;

    -- 1. Khoang chua tron doan: nho lai de chen phan duoi o buoc 5.
    SELECT MaBangGia, DenNgay, DonGia, HeSo
    INTO   v_MaTach, v_TachDen, v_TachGia, v_TachHeSo
    FROM   BANG_GIA_PHONG
    WHERE  MaLoaiPhong  = p_MaLoaiPhong
      AND  ApDungTuNgay < p_TuNgay
      AND  DenNgay      > p_DenNgay
    LIMIT  1;

    -- 2. Khoang nam tron trong doan.
    DELETE FROM BANG_GIA_PHONG
    WHERE  MaLoaiPhong  =  p_MaLoaiPhong
      AND  ApDungTuNgay >= p_TuNgay
      AND  DenNgay      <= p_DenNgay;

    -- 3. Khoang lan dau doan (ke ca khoang o buoc 1): ket thuc truoc p_TuNgay.
    UPDATE BANG_GIA_PHONG
    SET    DenNgay = p_TuNgay - INTERVAL 1 DAY
    WHERE  MaLoaiPhong  =  p_MaLoaiPhong
      AND  ApDungTuNgay <  p_TuNgay
      AND  DenNgay      >= p_TuNgay;

    -- 4. Khoang lan cuoi doan: bat dau sau p_DenNgay.
    UPDATE BANG_GIA_PHONG
    SET    ApDungTuNgay = p_DenNgay + INTERVAL 1 DAY
    WHERE  MaLoaiPhong  =  p_MaLoaiPhong
      AND  ApDungTuNgay >= p_TuNgay
      AND  ApDungTuNgay <= p_DenNgay
      AND  DenNgay      >  p_DenNgay;

    SELECT COALESCE(MAX(CAST(SUBSTRING(MaBangGia, 3) AS UNSIGNED)), 0) + 1
    INTO   v_Next
    FROM   BANG_GIA_PHONG;

    -- 5. Phan duoi cua khoang o buoc 1, giu gia va he so cu.
    IF v_MaTach IS NOT NULL THEN
        INSERT INTO BANG_GIA_PHONG
            (MaBangGia, MaLoaiPhong, HeSo, ApDungTuNgay, DenNgay, DonGia)
        VALUES
            (CONCAT('BG', LPAD(v_Next, 8, '0')), p_MaLoaiPhong, v_TachHeSo,
             p_DenNgay + INTERVAL 1 DAY, v_TachDen, v_TachGia);

        SET v_Next = v_Next + 1;
    END IF;

    -- 6. Khoang moi. Gia goc 0 thi khong tinh duoc he so, ghi 1.00.
    IF p_DonGia IS NOT NULL THEN
        INSERT INTO BANG_GIA_PHONG
            (MaBangGia, MaLoaiPhong, HeSo, ApDungTuNgay, DenNgay, DonGia)
        VALUES
            (CONCAT('BG', LPAD(v_Next, 8, '0')), p_MaLoaiPhong,
             GREATEST(COALESCE(v_HeSo, 1.00), 0.01), p_TuNgay, p_DenNgay, p_DonGia);
    END IF;

    COMMIT;

    SELECT MaBangGia, ApDungTuNgay, DenNgay, DonGia, HeSo
    FROM   BANG_GIA_PHONG
    WHERE  MaLoaiPhong = p_MaLoaiPhong
    ORDER  BY ApDungTuNgay;
END$$

-- Sua gia goc cua loai phong. HeSo cua moi khoang tinh lai theo gia goc moi;
-- DonGia giu nguyen nen gia that khong doi ngam.
CREATE PROCEDURE sp_CapNhatGiaLoaiPhong (
    IN p_MaLoaiPhong CHAR(10),
    IN p_DonGiaNgay  DECIMAL(18,2)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_Co      INT DEFAULT 0;
    DECLARE v_HeSoMax DECIMAL(24,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_DonGiaNgay IS NULL OR p_DonGiaNgay <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gia goc phai lon hon 0';
    END IF;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_Co
    FROM   LOAI_PHONG
    WHERE  MaLoaiPhong = p_MaLoaiPhong
    FOR    UPDATE;

    IF v_Co = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loai phong khong ton tai';
    END IF;

    SELECT MAX(ROUND(DonGia / p_DonGiaNgay, 2))
    INTO   v_HeSoMax
    FROM   BANG_GIA_PHONG
    WHERE  MaLoaiPhong = p_MaLoaiPhong;

    IF v_HeSoMax > 99.99 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Co khoang gia vuot 99,99 lan gia goc moi';
    END IF;

    UPDATE LOAI_PHONG
    SET    DonGiaNgay = p_DonGiaNgay
    WHERE  MaLoaiPhong = p_MaLoaiPhong;

    UPDATE BANG_GIA_PHONG
    SET    HeSo = GREATEST(ROUND(DonGia / p_DonGiaNgay, 2), 0.01)
    WHERE  MaLoaiPhong = p_MaLoaiPhong;

    COMMIT;

    SELECT MaLoaiPhong, TenLoaiPhong, DonGiaNgay
    FROM   LOAI_PHONG
    WHERE  MaLoaiPhong = p_MaLoaiPhong;
END$$

-- THU TUC BAO CAO (muc 4.3), chi doc. NULL o p_TuNgay / p_DenNgay la khong gioi
-- han dau do; p_DenNgay tinh tron ngay. Doanh thu khong tru GiamTru vi tien coc
-- van la doanh thu.

CREATE PROCEDURE sp_BaoCaoDoanhThu (
    IN p_TuNgay  DATE,
    IN p_DenNgay DATE
)
SQL SECURITY DEFINER
BEGIN
    IF p_TuNgay > p_DenNgay THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tu ngay phai nho hon hoac bang den ngay';
    END IF;

    SELECT DATE_FORMAT(hd.NgayLap, '%Y-%m')                     AS Thang,
           COUNT(DISTINCT hd.MaHoaDon)                          AS SoHoaDon,
           SUM(IF(ct.LoaiKhoanMuc = 'TienPhong', ct.SoTien, 0)) AS TienPhong,
           SUM(IF(ct.LoaiKhoanMuc = 'DichVu',    ct.SoTien, 0)) AS DichVu,
           SUM(IF(ct.LoaiKhoanMuc = 'PhuThu',    ct.SoTien, 0)) AS PhuThu,
           SUM(IF(ct.LoaiKhoanMuc = 'GiamGia',   ct.SoTien, 0)) AS GiamGia,
           SUM(IF(ct.LoaiKhoanMuc IN ('TienPhong', 'DichVu', 'PhuThu', 'GiamGia'),
                  ct.SoTien, 0))                                AS DoanhThuThuan
    FROM   HOA_DON               hd
    LEFT   JOIN CHI_TIET_HOA_DON ct ON ct.MaHoaDon = hd.MaHoaDon
    WHERE  hd.TrangThai = 'DaThanhToan'
      AND  (p_TuNgay  IS NULL OR hd.NgayLap >= p_TuNgay)
      AND  (p_DenNgay IS NULL OR hd.NgayLap <  p_DenNgay + INTERVAL 1 DAY)
    GROUP  BY Thang
    ORDER  BY Thang;
END$$

-- Phieu vat qua hai thang duoc tach dem ve dung thang. Cong suat = dem ban /
-- dem kha dung; ADR = tien phong / dem ban; RevPAR = tien phong / dem kha dung.
CREATE PROCEDURE sp_BaoCaoCongSuat (
    IN p_TuNgay  DATE,
    IN p_DenNgay DATE
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_TuNgay  DATE;
    DECLARE v_DenNgay DATE;
    DECLARE v_SoPhong INT;

    IF p_TuNgay > p_DenNgay THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tu ngay phai nho hon hoac bang den ngay';
    END IF;

    SELECT COALESCE(p_TuNgay,  CAST(DATE_FORMAT(MIN(NgayCheckIn), '%Y-%m-01') AS DATE)),
           COALESCE(p_DenNgay, LAST_DAY(MAX(NgayCheckOut) - INTERVAL 1 DAY))
    INTO   v_TuNgay, v_DenNgay
    FROM   PHIEU_DAT_PHONG
    WHERE  TrangThai IN ('DangO', 'HoanTat');

    SELECT COUNT(*) INTO v_SoPhong FROM PHONG;

    WITH RECURSIVE thang AS (
        SELECT CAST(DATE_FORMAT(v_TuNgay, '%Y-%m-01') AS DATE) AS DauThang
        FROM   DUAL
        WHERE  v_TuNgay IS NOT NULL AND v_DenNgay IS NOT NULL
        UNION  ALL
        SELECT DauThang + INTERVAL 1 MONTH
        FROM   thang
        WHERE  DauThang + INTERVAL 1 MONTH <= v_DenNgay
    ),
    ky AS (
        SELECT DauThang,
               GREATEST(DauThang, v_TuNgay)         AS BatDau,
               LEAST(LAST_DAY(DauThang), v_DenNgay) AS KetThuc
        FROM   thang
    ),
    dong AS (
        SELECT k.DauThang,
               ct.GiaThueThoiDiem,
               DATEDIFF(LEAST(pd.NgayCheckOut, k.KetThuc + INTERVAL 1 DAY),
                        GREATEST(pd.NgayCheckIn, k.BatDau)) AS SoDem
        FROM   ky                 k
        JOIN   PHIEU_DAT_PHONG    pd ON pd.TrangThai    IN ('DangO', 'HoanTat')
                                    AND pd.NgayCheckIn  <= k.KetThuc
                                    AND pd.NgayCheckOut >  k.BatDau
        JOIN   CHI_TIET_DAT_PHONG ct ON ct.MaDatPhong = pd.MaDatPhong
    ),
    tong AS (
        SELECT k.DauThang,
               DATEDIFF(k.KetThuc, k.BatDau) + 1               AS SoNgay,
               v_SoPhong * (DATEDIFF(k.KetThuc, k.BatDau) + 1) AS DemKhaDung,
               COALESCE(SUM(d.SoDem), 0)                       AS DemBan,
               COALESCE(SUM(d.GiaThueThoiDiem * d.SoDem), 0)   AS DoanhThuPhong
        FROM   ky        k
        LEFT   JOIN dong d ON d.DauThang = k.DauThang
        GROUP  BY k.DauThang, k.BatDau, k.KetThuc
    )
    SELECT DATE_FORMAT(DauThang, '%Y-%m')                  AS Thang,
           SoNgay,
           DemKhaDung,
           DemBan,
           ROUND(DemBan * 100 / NULLIF(DemKhaDung, 0), 2)  AS CongSuatPhanTram,
           DoanhThuPhong,
           ROUND(DoanhThuPhong / NULLIF(DemBan, 0), 2)     AS ADR,
           ROUND(DoanhThuPhong / NULLIF(DemKhaDung, 0), 2) AS RevPAR
    FROM   tong
    ORDER  BY DauThang;
END$$

CREATE PROCEDURE sp_BaoCaoKhachHang (
    IN p_TuNgay  DATE,
    IN p_DenNgay DATE
)
SQL SECURITY DEFINER
BEGIN
    IF p_TuNgay > p_DenNgay THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tu ngay phai nho hon hoac bang den ngay';
    END IF;

    WITH luu_tru AS (
        SELECT MaDatPhong,
               MaKH,
               NgayCheckIn,
               DATEDIFF(NgayCheckOut, NgayCheckIn) AS SoDem
        FROM   PHIEU_DAT_PHONG
        WHERE  TrangThai IN ('DangO', 'HoanTat')
          AND  (p_TuNgay  IS NULL OR NgayCheckIn >= p_TuNgay)
          AND  (p_DenNgay IS NULL OR NgayCheckIn <= p_DenNgay)
    ),
    chi_tieu AS (   -- tach rieng de mot phieu nhieu dong hoa don khong nhan so dem
        SELECT hd.MaDatPhong,
               SUM(ct.SoTien) AS DoanhThu
        FROM   HOA_DON          hd
        JOIN   CHI_TIET_HOA_DON ct ON ct.MaHoaDon = hd.MaHoaDon
        WHERE  hd.TrangThai = 'DaThanhToan'
          AND  ct.LoaiKhoanMuc IN ('TienPhong', 'DichVu', 'PhuThu', 'GiamGia')
        GROUP  BY hd.MaDatPhong
    )
    SELECT kh.MaKH,
           kh.HoTen,
           COUNT(*)                                            AS SoLanLuuTru,
           SUM(lt.SoDem)                                       AS TongSoDem,
           COALESCE(SUM(c.DoanhThu), 0)                        AS TongChiTieu,
           ROUND(COALESCE(SUM(c.DoanhThu), 0) / COUNT(*), 2)   AS ChiTieuTBMoiLan,
           MAX(lt.NgayCheckIn)                                 AS LanGanNhat,
           IF(COUNT(*) >= 2, 1, 0)                             AS KhachQuayLai
    FROM   luu_tru       lt
    JOIN   KHACH_HANG    kh ON kh.MaKH       = lt.MaKH
    LEFT   JOIN chi_tieu c  ON c.MaDatPhong  = lt.MaDatPhong
    GROUP  BY kh.MaKH, kh.HoTen
    ORDER  BY TongChiTieu DESC, kh.MaKH;
END$$

CREATE PROCEDURE sp_BaoCaoBuongPhong (
    IN p_TuNgay  DATE,
    IN p_DenNgay DATE
)
SQL SECURITY DEFINER
BEGIN
    IF p_TuNgay > p_DenNgay THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tu ngay phai nho hon hoac bang den ngay';
    END IF;

    SELECT p.SoPhong,
           p.Tang,
           COALESCE(d.SoLanDon, 0)      AS SoLanDon,
           COALESCE(s.SoLanSua, 0)      AS SoLanSua,
           COALESCE(s.TongChiPhiSua, 0) AS TongChiPhiSua,
           s.LanSuaGanNhat,
           p.TrangThai
    FROM   PHONG p
    LEFT   JOIN (
               SELECT MaPhong, COUNT(*) AS SoLanDon
               FROM   DON_PHONG
               WHERE  (p_TuNgay  IS NULL OR ThoiGian >= p_TuNgay)
                 AND  (p_DenNgay IS NULL OR ThoiGian <  p_DenNgay + INTERVAL 1 DAY)
               GROUP  BY MaPhong
           ) d ON d.MaPhong = p.MaPhong
    LEFT   JOIN (
               SELECT MaPhong,
                      COUNT(*)      AS SoLanSua,
                      SUM(ChiPhi)   AS TongChiPhiSua,
                      MAX(ThoiGian) AS LanSuaGanNhat
               FROM   SUA_PHONG
               WHERE  (p_TuNgay  IS NULL OR ThoiGian >= p_TuNgay)
                 AND  (p_DenNgay IS NULL OR ThoiGian <  p_DenNgay + INTERVAL 1 DAY)
               GROUP  BY MaPhong
           ) s ON s.MaPhong = p.MaPhong
    ORDER  BY TongChiPhiSua DESC, p.SoPhong;
END$$

CREATE PROCEDURE sp_BaoCaoCongNo (
    IN p_TuNgay  DATE,
    IN p_DenNgay DATE
)
SQL SECURITY DEFINER
BEGIN
    IF p_TuNgay > p_DenNgay THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tu ngay phai nho hon hoac bang den ngay';
    END IF;

    SELECT hd.MaHoaDon,
           hd.MaDatPhong,
           kh.MaKH,
           kh.HoTen,
           kh.SDT,
           hd.NgayLap,
           hd.TongTien                                                AS ConPhaiThu,
           COALESCE(-coc.SoTien, 0)                                   AS TienCocDaTru,
           DATEDIFF(COALESCE(p_DenNgay, CURDATE()), DATE(hd.NgayLap)) AS SoNgayTon
    FROM   HOA_DON         hd
    JOIN   PHIEU_DAT_PHONG pd ON pd.MaDatPhong = hd.MaDatPhong
    JOIN   KHACH_HANG      kh ON kh.MaKH       = pd.MaKH
    LEFT   JOIN (
               SELECT MaHoaDon, SUM(SoTien) AS SoTien
               FROM   CHI_TIET_HOA_DON
               WHERE  LoaiKhoanMuc = 'GiamTru'
               GROUP  BY MaHoaDon
           ) coc ON coc.MaHoaDon = hd.MaHoaDon
    WHERE  hd.TrangThai = 'ChuaThanhToan'
      AND  hd.TongTien  > 0
      AND  (p_TuNgay  IS NULL OR hd.NgayLap >= p_TuNgay)
      AND  (p_DenNgay IS NULL OR hd.NgayLap <  p_DenNgay + INTERVAL 1 DAY)
    ORDER  BY SoNgayTon DESC, hd.MaHoaDon;
END$$

DELIMITER ;

-- Mong doi: 12 thu tuc nghiep vu.
SELECT ROUTINE_NAME
FROM   information_schema.ROUTINES
WHERE  ROUTINE_SCHEMA = 'QuanLyKhachSan' AND ROUTINE_TYPE = 'PROCEDURE'
  AND  ROUTINE_NAME IN ('sp_DangNhap', 'sp_TraCuuPhongTrong', 'sp_DatPhong',
                       'sp_XacNhanDatCoc', 'sp_NhanPhong', 'sp_GhiNhanDichVu',
                       'sp_LapHoaDon', 'sp_ThanhToanHoaDon', 'sp_TraPhong',
                       'sp_GhiNhanDonPhong', 'sp_GhiNhanSuaPhong', 'sp_HuyPhieuDat')
ORDER  BY ROUTINE_NAME;

-- Mong doi: thu tuc bo sung (khach hang, buong phong, bang gia).
SELECT ROUTINE_NAME
FROM   information_schema.ROUTINES
WHERE  ROUTINE_SCHEMA = 'QuanLyKhachSan' AND ROUTINE_TYPE = 'PROCEDURE'
  AND  ROUTINE_NAME IN ('sp_ChuanHoaKhachHang', 'sp_ThemKhachHang',
                       'sp_SuaKhachHang', 'sp_BaoDonPhong', 'sp_BaoBaoTri',
                       'sp_DatGiaPhong', 'sp_CapNhatGiaLoaiPhong')
ORDER  BY ROUTINE_NAME;

-- Mong doi: 5 thu tuc bao cao.
SELECT ROUTINE_NAME
FROM   information_schema.ROUTINES
WHERE  ROUTINE_SCHEMA = 'QuanLyKhachSan' AND ROUTINE_TYPE = 'PROCEDURE'
  AND  ROUTINE_NAME IN ('sp_BaoCaoDoanhThu', 'sp_BaoCaoCongSuat',
                       'sp_BaoCaoKhachHang', 'sp_BaoCaoBuongPhong',
                       'sp_BaoCaoCongNo')
ORDER  BY ROUTINE_NAME;

-- So lieu mong doi voi du lieu 07 nap sau SET timestamp = UNIX_TIMESTAMP('2026-09-23 10:00:00'):
--   sp_BaoCaoDoanhThu(NULL, NULL)                  12 thang 2025-10 - 2026-09, T09/2026 = 63.690.000
--   sp_BaoCaoCongSuat('2026-09-01', '2026-09-30')  56 / 1260 dem, cong suat 4,44%
--   sp_BaoCaoKhachHang(NULL, NULL)                 54 khach, 18 khach quay lai, cao nhat KH00000040
--   sp_BaoCaoBuongPhong(NULL, NULL)                42 phong, PRES-01 chi phi sua cao nhat
--   sp_BaoCaoCongNo(NULL, CURDATE())               10 hoa don: HD00000006 va HD00000023 - HD00000031
