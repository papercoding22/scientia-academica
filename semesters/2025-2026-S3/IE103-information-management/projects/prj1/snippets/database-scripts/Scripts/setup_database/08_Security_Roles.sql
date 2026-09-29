-- 08. XAC THUC VA PHAN QUYEN. Can: 01 den 07. Chay lai duoc.

USE QuanLyKhachSan;

-- A. CHINH SACH XAC THUC

SELECT component_urn FROM mysql.component;

-- Chua co component_validate_password thi bo chu thich khoi duoi, chay MOT LAN.
/*
INSTALL COMPONENT 'file://component_validate_password';

SET GLOBAL validate_password.policy             = MEDIUM;
SET GLOBAL validate_password.length             = 8;
SET GLOBAL validate_password.mixed_case_count   = 1;
SET GLOBAL validate_password.number_count       = 1;
SET GLOBAL validate_password.special_char_count = 1;
*/

SHOW VARIABLES LIKE 'validate_password%';

-- Mat khau chua bam SHA-256. Mong doi: 0 dong.
SELECT MaTK, TenDangNhap
FROM   TAI_KHOAN
WHERE  CHAR_LENGTH(MatKhau) <> 64;

-- B. ROLE (tam tac nhan o Bang 1.1) VA QUYEN DOC

CREATE ROLE IF NOT EXISTS
    r_khachhang, r_letan, r_buongphong, r_giamsatbuongphong,
    r_kythuat, r_ketoan, r_quanly, r_quantri;

GRANT SELECT ON QuanLyKhachSan.LOAI_PHONG   TO r_khachhang;
GRANT SELECT ON QuanLyKhachSan.DICH_VU      TO r_khachhang;
GRANT SELECT (MaPhong, MaLoaiPhong, SoPhong, Tang, TrangThai)
      ON QuanLyKhachSan.PHONG               TO r_khachhang;

GRANT SELECT ON QuanLyKhachSan.KHACH_HANG         TO r_letan;
GRANT SELECT ON QuanLyKhachSan.PHONG              TO r_letan;
GRANT SELECT ON QuanLyKhachSan.LOAI_PHONG         TO r_letan;
GRANT SELECT ON QuanLyKhachSan.BANG_GIA_PHONG     TO r_letan;
GRANT SELECT ON QuanLyKhachSan.PHIEU_DAT_PHONG    TO r_letan;
GRANT SELECT ON QuanLyKhachSan.CHI_TIET_DAT_PHONG TO r_letan;
GRANT SELECT ON QuanLyKhachSan.DICH_VU            TO r_letan;
GRANT SELECT ON QuanLyKhachSan.SU_DUNG_DICH_VU    TO r_letan;
GRANT SELECT ON QuanLyKhachSan.HOA_DON            TO r_letan;
GRANT SELECT ON QuanLyKhachSan.CHI_TIET_HOA_DON   TO r_letan;

GRANT SELECT ON QuanLyKhachSan.PHONG      TO r_buongphong;
GRANT SELECT ON QuanLyKhachSan.LOAI_PHONG TO r_buongphong;
GRANT SELECT ON QuanLyKhachSan.DON_PHONG  TO r_buongphong;

GRANT SELECT ON QuanLyKhachSan.PHONG      TO r_giamsatbuongphong;
GRANT SELECT ON QuanLyKhachSan.LOAI_PHONG TO r_giamsatbuongphong;
GRANT SELECT ON QuanLyKhachSan.DON_PHONG  TO r_giamsatbuongphong;
GRANT SELECT ON QuanLyKhachSan.SUA_PHONG  TO r_giamsatbuongphong;
GRANT SELECT (MaTK, MaLoaiTK, TenDangNhap, HoTen, TrangThai)
      ON QuanLyKhachSan.TAI_KHOAN         TO r_giamsatbuongphong;

GRANT SELECT ON QuanLyKhachSan.PHONG     TO r_kythuat;
GRANT SELECT ON QuanLyKhachSan.SUA_PHONG TO r_kythuat;

GRANT SELECT ON QuanLyKhachSan.HOA_DON            TO r_ketoan;
GRANT SELECT ON QuanLyKhachSan.CHI_TIET_HOA_DON   TO r_ketoan;
GRANT SELECT ON QuanLyKhachSan.PHIEU_DAT_PHONG    TO r_ketoan;
GRANT SELECT ON QuanLyKhachSan.CHI_TIET_DAT_PHONG TO r_ketoan;
GRANT SELECT ON QuanLyKhachSan.SU_DUNG_DICH_VU    TO r_ketoan;
GRANT SELECT ON QuanLyKhachSan.DICH_VU            TO r_ketoan;
GRANT SELECT ON QuanLyKhachSan.KHACH_HANG         TO r_ketoan;

GRANT SELECT ON QuanLyKhachSan.* TO r_quanly;

GRANT SELECT                 ON QuanLyKhachSan.*              TO r_quantri;
GRANT INSERT, UPDATE, DELETE ON QuanLyKhachSan.TAI_KHOAN      TO r_quantri;
GRANT INSERT, UPDATE, DELETE ON QuanLyKhachSan.LOAI_TAI_KHOAN TO r_quantri;
GRANT CREATE USER, RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT
      ON *.* TO r_quantri;
GRANT SELECT ON QuanLyKhachSan.* TO r_quantri WITH GRANT OPTION;

-- Man Buong phong / Bao tri: ten nguoi bao, nguoi lam; ky thuat xem phong co
-- khach nhan hom nay.
GRANT SELECT (MaTK, HoTen) ON QuanLyKhachSan.TAI_KHOAN TO r_buongphong, r_kythuat;
GRANT SELECT ON QuanLyKhachSan.v_TinhTrangPhongHomNay   TO r_kythuat;

-- So do phong va Tong quan (le tan): nhat ky don / sua kem ten nhan vien, phieu
-- bao tri dang mo.
GRANT SELECT ON QuanLyKhachSan.DON_PHONG               TO r_letan;
GRANT SELECT ON QuanLyKhachSan.SUA_PHONG               TO r_letan;
GRANT SELECT (MaTK, HoTen) ON QuanLyKhachSan.TAI_KHOAN TO r_letan;

-- C. QUYEN GHI CHI QUA THU TUC (khong cap INSERT / UPDATE / DELETE truc tiep)

GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_TraCuuPhongTrong TO r_khachhang;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_DatPhong         TO r_khachhang;

GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_TraCuuPhongTrong TO r_letan;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_DatPhong         TO r_letan;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_XacNhanDatCoc    TO r_letan;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_NhanPhong        TO r_letan;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_GhiNhanDichVu    TO r_letan;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_LapHoaDon        TO r_letan;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_ThanhToanHoaDon  TO r_letan;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_TraPhong         TO r_letan;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_HuyPhieuDat      TO r_letan;

GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_GhiNhanDonPhong  TO r_buongphong;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_GhiNhanDonPhong
      TO r_giamsatbuongphong;

GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_GhiNhanSuaPhong  TO r_kythuat;

GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_ThanhToanHoaDon  TO r_ketoan;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_HuyPhieuDat      TO r_ketoan;

-- Them / sua ho so khach (sp_ChuanHoaKhachHang la noi bo, khong cap).
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_ThemKhachHang TO r_letan;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_SuaKhachHang  TO r_letan;

-- Bao don / bao bao tri (sua xong va don xong van la sp_GhiNhanSuaPhong /
-- sp_GhiNhanDonPhong o tren).
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_BaoDonPhong
      TO r_letan, r_giamsatbuongphong;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_BaoBaoTri
      TO r_letan, r_buongphong, r_giamsatbuongphong;

-- Form dat phong va man Bang gia goi thang hai ham gia khi doc.
GRANT EXECUTE ON FUNCTION QuanLyKhachSan.fn_DonGiaTrungBinh
      TO r_khachhang, r_letan, r_quanly;
GRANT EXECUTE ON FUNCTION QuanLyKhachSan.fn_DonGiaPhongTheoNgay
      TO r_khachhang, r_letan, r_quanly;

-- Man Bang gia: quan ly dat gia theo khoang ngay va sua gia goc.
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_DatGiaPhong         TO r_quanly;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_CapNhatGiaLoaiPhong TO r_quanly;

GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_DangNhap TO
      r_khachhang, r_letan, r_buongphong, r_giamsatbuongphong,
      r_kythuat, r_ketoan, r_quanly, r_quantri;

GRANT SELECT ON QuanLyKhachSan.v_PhongKhaDung        TO r_khachhang, r_letan;
GRANT SELECT ON QuanLyKhachSan.v_TinhTrangPhongHomNay
      TO r_letan, r_buongphong, r_giamsatbuongphong;
GRANT SELECT ON QuanLyKhachSan.v_PhieuDatDangHieuLuc TO r_letan, r_ketoan;

GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_BaoCaoDoanhThu   TO r_quanly;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_BaoCaoCongSuat   TO r_quanly;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_BaoCaoKhachHang  TO r_quanly;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_BaoCaoBuongPhong TO r_quanly;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_BaoCaoCongNo     TO r_quanly;

GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_BaoCaoDoanhThu   TO r_ketoan;
GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_BaoCaoCongNo     TO r_ketoan;

GRANT EXECUTE ON PROCEDURE QuanLyKhachSan.sp_BaoCaoBuongPhong
      TO r_giamsatbuongphong;

-- D. TAI KHOAN MAY CHU. Mat khau chi dung cho moi truong hoc tap.

CREATE USER IF NOT EXISTS 'admin'@'localhost'
    IDENTIFIED BY 'Admin@123'
    PASSWORD EXPIRE INTERVAL 90 DAY PASSWORD HISTORY 5
    FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;

CREATE USER IF NOT EXISTS 'letan.lan'@'localhost'
    IDENTIFIED BY 'LeTan@123'
    PASSWORD EXPIRE INTERVAL 90 DAY PASSWORD HISTORY 5
    FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;

CREATE USER IF NOT EXISTS 'buong.mai'@'localhost'
    IDENTIFIED BY 'Buong@123'
    PASSWORD EXPIRE INTERVAL 90 DAY PASSWORD HISTORY 5
    FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;

CREATE USER IF NOT EXISTS 'kythuat.nam'@'localhost'
    IDENTIFIED BY 'KyThuat@123'
    PASSWORD EXPIRE INTERVAL 90 DAY PASSWORD HISTORY 5
    FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;

CREATE USER IF NOT EXISTS 'ketoan.hoa'@'localhost'
    IDENTIFIED BY 'KeToan@123'
    PASSWORD EXPIRE INTERVAL 90 DAY PASSWORD HISTORY 5
    FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;

CREATE USER IF NOT EXISTS 'quanly.khanh'@'localhost'
    IDENTIFIED BY 'QuanLy@123'
    PASSWORD EXPIRE INTERVAL 90 DAY PASSWORD HISTORY 5
    FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;

GRANT r_quantri    TO 'admin'@'localhost';
GRANT r_letan      TO 'letan.lan'@'localhost';
GRANT r_buongphong TO 'buong.mai'@'localhost';
GRANT r_kythuat    TO 'kythuat.nam'@'localhost';
GRANT r_ketoan     TO 'ketoan.hoa'@'localhost';
GRANT r_quanly     TO 'quanly.khanh'@'localhost';

SET DEFAULT ROLE ALL TO
    'admin'@'localhost',
    'letan.lan'@'localhost',
    'buong.mai'@'localhost',
    'kythuat.nam'@'localhost',
    'ketoan.hoa'@'localhost',
    'quanly.khanh'@'localhost';

FLUSH PRIVILEGES;
