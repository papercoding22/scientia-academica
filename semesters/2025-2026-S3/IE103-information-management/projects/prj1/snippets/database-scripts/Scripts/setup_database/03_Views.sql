-- 03. KHUNG NHIN (muc 4.1.5, Bang 4.5). Can: 01.

USE QuanLyKhachSan;

CREATE OR REPLACE VIEW v_PhongKhaDung AS
SELECT p.MaPhong,
       p.SoPhong,
       p.Tang,
       p.MaLoaiPhong,
       lp.TenLoaiPhong,
       lp.DonGiaNgay,
       p.TrangThai
FROM   PHONG      p
JOIN   LOAI_PHONG lp ON lp.MaLoaiPhong = p.MaLoaiPhong
WHERE  p.TrangThai NOT IN ('DangDon', 'BaoTri');

-- RB-01 bao dam moi phong co toi da mot phieu phu len hom nay.
CREATE OR REPLACE VIEW v_TinhTrangPhongHomNay AS
SELECT p.MaPhong,
       p.SoPhong,
       p.Tang,
       lp.TenLoaiPhong,
       p.TrangThai,
       hn.MaDatPhong,
       kh.HoTen       AS KhachLuuTru,
       hn.NgayCheckIn,
       hn.NgayCheckOut
FROM   PHONG      p
JOIN   LOAI_PHONG lp ON lp.MaLoaiPhong = p.MaLoaiPhong
LEFT   JOIN (
           SELECT ct.MaPhong,
                  pd.MaDatPhong,
                  pd.MaKH,
                  pd.NgayCheckIn,
                  pd.NgayCheckOut
           FROM   CHI_TIET_DAT_PHONG ct
           JOIN   PHIEU_DAT_PHONG    pd ON pd.MaDatPhong = ct.MaDatPhong
           WHERE  pd.TrangThai IN ('DaDat', 'DangO')
             AND  CURDATE() >= pd.NgayCheckIn
             AND  CURDATE() <  pd.NgayCheckOut
       ) hn ON hn.MaPhong = p.MaPhong
LEFT   JOIN KHACH_HANG kh ON kh.MaKH = hn.MaKH;

CREATE OR REPLACE VIEW v_PhieuDatDangHieuLuc AS
SELECT pd.MaDatPhong,
       pd.MaKH,
       kh.HoTen        AS TenKhachHang,
       kh.SDT,
       pd.MaTK,
       pd.NgayLap,
       pd.NgayCheckIn,
       pd.NgayCheckOut,
       DATEDIFF(pd.NgayCheckOut, pd.NgayCheckIn) AS SoDem,
       pd.TienCoc,
       pd.TrangThai,
       COUNT(ct.MaPhong)                          AS SoPhongGiu,
       GROUP_CONCAT(p.SoPhong ORDER BY p.SoPhong SEPARATOR ', ') AS DanhSachPhong
FROM   PHIEU_DAT_PHONG         pd
JOIN   KHACH_HANG              kh ON kh.MaKH    = pd.MaKH
LEFT   JOIN CHI_TIET_DAT_PHONG ct ON ct.MaDatPhong = pd.MaDatPhong
LEFT   JOIN PHONG              p  ON p.MaPhong     = ct.MaPhong
WHERE  pd.TrangThai IN ('DaDat', 'DangO')
GROUP  BY pd.MaDatPhong, pd.MaKH, kh.HoTen, kh.SDT, pd.MaTK, pd.NgayLap,
         pd.NgayCheckIn, pd.NgayCheckOut, pd.TienCoc, pd.TrangThai;

-- Mong doi: 3 khung nhin.
SELECT TABLE_NAME
FROM   information_schema.VIEWS
WHERE  TABLE_SCHEMA = 'QuanLyKhachSan'
ORDER  BY TABLE_NAME;
