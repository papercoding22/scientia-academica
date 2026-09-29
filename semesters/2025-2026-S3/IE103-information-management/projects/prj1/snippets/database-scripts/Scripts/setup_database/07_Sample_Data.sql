-- 07. DU LIEU MAU. Can: 01 den 06. Chay lai duoc: TRUNCATE (khong kich hoat
-- trigger) roi nap lai. Ngay tinh theo ngay chay: phan A dich @Lech ngay tu moc
-- 16/09/2026, phan B tinh tu @HomNay. Can so co dinh thi chay truoc:
--     SET timestamp = UNIX_TIMESTAMP('2026-09-23 10:00:00');

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
USE QuanLyKhachSan;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE CHI_TIET_HOA_DON;
TRUNCATE TABLE HOA_DON;
TRUNCATE TABLE SU_DUNG_DICH_VU;
TRUNCATE TABLE DICH_VU;
TRUNCATE TABLE SUA_PHONG;
TRUNCATE TABLE DON_PHONG;
TRUNCATE TABLE CHI_TIET_DAT_PHONG;
TRUNCATE TABLE PHIEU_DAT_PHONG;
TRUNCATE TABLE PHONG;
TRUNCATE TABLE BANG_GIA_PHONG;
TRUNCATE TABLE LOAI_PHONG;
TRUNCATE TABLE KHACH_HANG;
TRUNCATE TABLE TAI_KHOAN;
TRUNCATE TABLE LOAI_TAI_KHOAN;
SET FOREIGN_KEY_CHECKS = 1;

SET @HomNay = CURDATE();
SET @Lech   = DATEDIFF(@HomNay, '2026-09-16');

START TRANSACTION;

-- A. 10 DONG GOC MOI BANG

INSERT INTO LOAI_TAI_KHOAN (MaLoaiTK, TenLoaiTK, MoTa) VALUES
('LTK0000001', 'Quan tri vien',       'Quan tri he thong va tai khoan'),
('LTK0000002', 'Le tan',              'Dat phong, nhan phong va tra phong'),
('LTK0000003', 'Buong phong',         'Don phong va cap nhat tinh trang phong'),
('LTK0000004', 'Ky thuat',            'Sua chua va bao tri co so vat chat'),
('LTK0000005', 'Ke toan',             'Quan ly hoa don va thanh toan'),
('LTK0000006', 'Quan ly khach san',   'Theo doi hoat dong va bao cao'),
('LTK0000007', 'Nha hang',            'Quan ly dich vu an uong'),
('LTK0000008', 'Spa',                 'Quan ly dich vu cham soc suc khoe'),
('LTK0000009', 'Bao ve',              'Dam bao an ninh va kiem soat ra vao'),
('LTK0000010', 'Cham soc khach hang', 'Tiep nhan va xu ly yeu cau cua khach');

-- SHA2 chi de minh hoa; ung dung that nen dung bcrypt.
INSERT INTO TAI_KHOAN
    (MaTK, MaLoaiTK, TenDangNhap, MatKhau, HoTen, TrangThai) VALUES
('TK00000001', 'LTK0000001', 'admin',        SHA2('Admin@123', 256),   'Nguyen Minh Anh', 'DangLamViec'),
('TK00000002', 'LTK0000002', 'letan.lan',    SHA2('LeTan@123', 256),   'Tran Ngoc Lan',    'DangLamViec'),
('TK00000003', 'LTK0000002', 'letan.huy',    SHA2('LeTan@456', 256),   'Le Quang Huy',     'DangLamViec'),
('TK00000004', 'LTK0000003', 'buong.mai',    SHA2('Buong@123', 256),   'Pham Thi Mai',     'DangLamViec'),
('TK00000005', 'LTK0000003', 'buong.thao',   SHA2('Buong@456', 256),   'Vo Thanh Thao',    'DangLamViec'),
('TK00000006', 'LTK0000004', 'kythuat.nam',  SHA2('KyThuat@123', 256), 'Do Hoang Nam',     'DangLamViec'),
('TK00000007', 'LTK0000004', 'kythuat.son',  SHA2('KyThuat@456', 256), 'Bui Minh Son',     'TamNghi'),
('TK00000008', 'LTK0000005', 'ketoan.hoa',   SHA2('KeToan@123', 256),  'Nguyen Thu Hoa',   'DangLamViec'),
('TK00000009', 'LTK0000006', 'quanly.khanh', SHA2('QuanLy@123', 256),  'Dang Gia Khanh',   'DangLamViec'),
('TK00000010', 'LTK0000010', 'cskh.uyen',    SHA2('CSKH@123', 256),    'Hoang Ngoc Uyen',  'NghiViec');

INSERT INTO KHACH_HANG (MaKH, HoTen, CCCD, SDT, Email) VALUES
('KH00000001', 'Nguyen Hoang Long', '079201000001', '0901234501', 'long.nguyen@example.com'),
('KH00000002', 'Tran Thi Bao Chau', '079202000002', '0901234502', 'chau.tran@example.com'),
('KH00000003', 'Le Minh Tuan',      '079203000003', '0901234503', 'tuan.le@example.com'),
('KH00000004', 'Pham Ngoc Ha',      '079204000004', '0901234504', 'ha.pham@example.com'),
('KH00000005', 'Vo Quoc Bao',       '079205000005', '0901234505', 'bao.vo@example.com'),
('KH00000006', 'Dang Thuy Linh',    '079206000006', '0901234506', 'linh.dang@example.com'),
('KH00000007', 'Bui Gia Han',       '079207000007', '0901234507', 'han.bui@example.com'),
('KH00000008', 'Hoang Anh Khoa',    '079208000008', '0901234508', 'khoa.hoang@example.com'),
('KH00000009', 'Do My Duyen',       '079209000009', '0901234509', 'duyen.do@example.com'),
('KH00000010', 'Truong Duc Phuc',   '079210000010', '0901234510', 'phuc.truong@example.com');

INSERT INTO LOAI_PHONG (MaLoaiPhong, TenLoaiPhong, DonGiaNgay) VALUES
('LP00000001', 'Standard Single',      600000.00),
('LP00000002', 'Standard Double',      800000.00),
('LP00000003', 'Superior Twin',       1000000.00),
('LP00000004', 'Superior Double',     1150000.00),
('LP00000005', 'Deluxe King',         1500000.00),
('LP00000006', 'Deluxe Twin',         1600000.00),
('LP00000007', 'Junior Suite',        2200000.00),
('LP00000008', 'Executive Suite',     3200000.00),
('LP00000009', 'Family Room',         2600000.00),
('LP00000010', 'Presidential Suite',  6000000.00);

INSERT INTO BANG_GIA_PHONG
    (MaBangGia, MaLoaiPhong, HeSo, ApDungTuNgay, DenNgay, DonGia) VALUES
('BG00000001', 'LP00000001', 1.00, '2026-01-01' + INTERVAL @Lech DAY, '2026-12-31' + INTERVAL @Lech DAY,  600000.00),
('BG00000002', 'LP00000002', 1.10, '2026-01-01' + INTERVAL @Lech DAY, '2026-12-31' + INTERVAL @Lech DAY,  880000.00),
('BG00000003', 'LP00000003', 1.00, '2026-01-01' + INTERVAL @Lech DAY, '2026-12-31' + INTERVAL @Lech DAY, 1000000.00),
('BG00000004', 'LP00000004', 1.20, '2026-01-01' + INTERVAL @Lech DAY, '2026-12-31' + INTERVAL @Lech DAY, 1380000.00),
('BG00000005', 'LP00000005', 1.00, '2026-01-01' + INTERVAL @Lech DAY, '2026-12-31' + INTERVAL @Lech DAY, 1500000.00),
('BG00000006', 'LP00000006', 1.15, '2026-01-01' + INTERVAL @Lech DAY, '2026-12-31' + INTERVAL @Lech DAY, 1840000.00),
('BG00000007', 'LP00000007', 1.00, '2026-01-01' + INTERVAL @Lech DAY, '2026-12-31' + INTERVAL @Lech DAY, 2200000.00),
('BG00000008', 'LP00000008', 1.25, '2026-01-01' + INTERVAL @Lech DAY, '2026-12-31' + INTERVAL @Lech DAY, 4000000.00),
('BG00000009', 'LP00000009', 1.10, '2026-01-01' + INTERVAL @Lech DAY, '2026-12-31' + INTERVAL @Lech DAY, 2860000.00),
('BG00000010', 'LP00000010', 1.30, '2026-01-01' + INTERVAL @Lech DAY, '2026-12-31' + INTERVAL @Lech DAY, 7800000.00);

INSERT INTO PHONG (MaPhong, MaLoaiPhong, SoPhong, Tang, TrangThai) VALUES
('PH00000001', 'LP00000001', '101',      1, 'Trong'),
('PH00000002', 'LP00000002', '102',      1, 'Trong'),
('PH00000003', 'LP00000003', '201',      2, 'Trong'),
('PH00000004', 'LP00000004', '202',      2, 'BaoTri'),
('PH00000005', 'LP00000005', '301',      3, 'DangDon'),
('PH00000006', 'LP00000006', '302',      3, 'DangSuDung'),
('PH00000007', 'LP00000007', '401',      4, 'DaDat'),
('PH00000008', 'LP00000008', '402',      4, 'DaDat'),
('PH00000009', 'LP00000009', '501',      5, 'DaDat'),
('PH00000010', 'LP00000010', 'PRES-01',  6, 'BaoTri');

INSERT INTO PHIEU_DAT_PHONG
    (MaDatPhong, MaKH, MaTK, NgayLap, NgayCheckIn, NgayCheckOut, TienCoc, TrangThai) VALUES
('DP00000001', 'KH00000001', 'TK00000002', '2026-01-02 09:10:00' + INTERVAL @Lech DAY, '2026-01-10' + INTERVAL @Lech DAY, '2026-01-12' + INTERVAL @Lech DAY,  600000.00, 'HoanTat'),
('DP00000002', 'KH00000002', 'TK00000003', '2026-04-12 14:20:00' + INTERVAL @Lech DAY, '2026-04-20' + INTERVAL @Lech DAY, '2026-04-23' + INTERVAL @Lech DAY, 1320000.00, 'HoanTat'),
('DP00000003', 'KH00000003', 'TK00000002', '2026-08-01 10:00:00' + INTERVAL @Lech DAY, '2026-08-14' + INTERVAL @Lech DAY, '2026-08-16' + INTERVAL @Lech DAY, 1000000.00, 'HoanTat'),
('DP00000004', 'KH00000004', 'TK00000003', '2026-09-01 16:30:00' + INTERVAL @Lech DAY, '2026-09-10' + INTERVAL @Lech DAY, '2026-09-12' + INTERVAL @Lech DAY, 1380000.00, 'HoanTat'),
('DP00000005', 'KH00000005', 'TK00000002', '2026-09-05 08:45:00' + INTERVAL @Lech DAY, '2026-09-14' + INTERVAL @Lech DAY, '2026-09-16' + INTERVAL @Lech DAY, 1500000.00, 'HoanTat'),
('DP00000006', 'KH00000006', 'TK00000003', '2026-09-10 11:15:00' + INTERVAL @Lech DAY, '2026-09-15' + INTERVAL @Lech DAY, '2026-09-18' + INTERVAL @Lech DAY, 2760000.00, 'DangO'),
('DP00000007', 'KH00000007', 'TK00000002', '2026-09-12 13:40:00' + INTERVAL @Lech DAY, '2026-10-05' + INTERVAL @Lech DAY, '2026-10-08' + INTERVAL @Lech DAY, 3300000.00, 'DaDat'),
('DP00000008', 'KH00000008', 'TK00000003', '2026-09-13 15:05:00' + INTERVAL @Lech DAY, '2026-11-20' + INTERVAL @Lech DAY, '2026-11-22' + INTERVAL @Lech DAY, 6860000.00, 'DaDat'),
('DP00000009', 'KH00000009', 'TK00000002', '2026-09-01 09:30:00' + INTERVAL @Lech DAY, '2026-09-20' + INTERVAL @Lech DAY, '2026-09-22' + INTERVAL @Lech DAY,       0.00, 'DaHuy'),
('DP00000010', 'KH00000010', 'TK00000003', '2026-09-10 17:00:00' + INTERVAL @Lech DAY, '2026-12-01' + INTERVAL @Lech DAY, '2026-12-03' + INTERVAL @Lech DAY,       0.00, 'DaHuy');

INSERT INTO CHI_TIET_DAT_PHONG
    (MaDatPhong, MaPhong, GiaThueThoiDiem, SoDem) VALUES
('DP00000001', 'PH00000001',  600000.00, 2),
('DP00000002', 'PH00000002',  880000.00, 3),
('DP00000003', 'PH00000003', 1000000.00, 2),
('DP00000004', 'PH00000004', 1380000.00, 2),
('DP00000005', 'PH00000005', 1500000.00, 2),
('DP00000006', 'PH00000006', 1840000.00, 3),
('DP00000007', 'PH00000007', 2200000.00, 3),
('DP00000008', 'PH00000008', 4000000.00, 2),
('DP00000008', 'PH00000009', 2860000.00, 2),
('DP00000009', 'PH00000009', 2860000.00, 2);

INSERT INTO DON_PHONG (MaDon, MaPhong, MaTK, ThoiGian, GhiChu) VALUES
('DON0000001', 'PH00000001', 'TK00000004', '2026-01-12 12:30:00' + INTERVAL @Lech DAY, 'Don sau khi khach tra phong'),
('DON0000002', 'PH00000002', 'TK00000005', '2026-04-23 11:45:00' + INTERVAL @Lech DAY, 'Thay ga giuong va bo sung nuoc'),
('DON0000003', 'PH00000003', 'TK00000004', '2026-08-16 12:10:00' + INTERVAL @Lech DAY, 'Don phong va kiem tra minibar'),
('DON0000004', 'PH00000004', 'TK00000005', '2026-09-12 11:30:00' + INTERVAL @Lech DAY, 'Ve sinh phong tam'),
('DON0000005', 'PH00000005', 'TK00000004', '2026-09-16 12:00:00' + INTERVAL @Lech DAY, 'Dang don tong quat sau check-out'),
('DON0000006', 'PH00000006', 'TK00000005', '2026-09-14 15:20:00' + INTERVAL @Lech DAY, 'Chuan bi phong truoc check-in'),
('DON0000007', 'PH00000007', 'TK00000004', '2026-09-15 09:00:00' + INTERVAL @Lech DAY, 'Ve sinh dinh ky phong Junior Suite'),
('DON0000008', 'PH00000008', 'TK00000005', '2026-09-15 09:30:00' + INTERVAL @Lech DAY, 'Ve sinh dinh ky phong Executive Suite'),
('DON0000009', 'PH00000009', 'TK00000004', '2026-09-15 10:00:00' + INTERVAL @Lech DAY, 'Ve sinh dinh ky phong gia dinh'),
('DON0000010', 'PH00000010', 'TK00000005', '2026-09-01 10:30:00' + INTERVAL @Lech DAY, 'Ve sinh truoc dot bao tri');

INSERT INTO SUA_PHONG (MaSua, MaPhong, MaTK, ThoiGian, ChiPhi, MoTaLoi) VALUES
('SUA0000001', 'PH00000001', 'TK00000006', '2025-12-15 09:00:00' + INTERVAL @Lech DAY,  250000.00, 'Thay khoa cua phong'),
('SUA0000002', 'PH00000002', 'TK00000007', '2026-03-05 10:30:00' + INTERVAL @Lech DAY,  180000.00, 'Sua voi nuoc bi ri'),
('SUA0000003', 'PH00000003', 'TK00000006', '2026-07-01 13:00:00' + INTERVAL @Lech DAY,  450000.00, 'Bao tri may lanh'),
('SUA0000004', 'PH00000004', 'TK00000007', '2026-09-13 15:20:00' + INTERVAL @Lech DAY,  900000.00, 'Sua he thong nuoc nong'),
('SUA0000005', 'PH00000005', 'TK00000006', '2026-08-20 08:45:00' + INTERVAL @Lech DAY,  120000.00, 'Thay bong den phong tam'),
('SUA0000006', 'PH00000006', 'TK00000007', '2026-08-25 14:10:00' + INTERVAL @Lech DAY,  350000.00, 'Bao tri tivi'),
('SUA0000007', 'PH00000007', 'TK00000006', '2026-09-02 10:00:00' + INTERVAL @Lech DAY,  600000.00, 'Thay rem cua so'),
('SUA0000008', 'PH00000008', 'TK00000007', '2026-09-03 11:30:00' + INTERVAL @Lech DAY,  750000.00, 'Sua may pha ca phe'),
('SUA0000009', 'PH00000009', 'TK00000006', '2026-09-04 16:00:00' + INTERVAL @Lech DAY,  500000.00, 'Bao tri tu lanh'),
('SUA0000010', 'PH00000010', 'TK00000007', '2026-09-15 09:40:00' + INTERVAL @Lech DAY, 1500000.00, 'Bao tri he thong am thanh');

INSERT INTO DICH_VU (MaDV, TenDV, DonViTinh, GiaDV) VALUES
('DV00000001', 'Giat ui',             'Kg',       80000.00),
('DV00000002', 'Buffet sang',         'Suat',    250000.00),
('DV00000003', 'Dua don san bay',     'Chuyen',  500000.00),
('DV00000004', 'Spa 60 phut',         'Luot',    700000.00),
('DV00000005', 'Minibar',             'SanPham', 100000.00),
('DV00000006', 'An tai phong',        'Suat',    350000.00),
('DV00000007', 'Thue xe may',         'Ngay',    200000.00),
('DV00000008', 'Phong hoi nghi',      'Gio',    1000000.00),
('DV00000009', 'Giuong phu',          'Dem',     400000.00),
('DV00000010', 'Trang tri sinh nhat', 'Goi',    1500000.00);

-- Nap truoc HOA_DON vi trg_SDDV_TinhThanhTien chan ghi vao hoa don da dong.
INSERT INTO SU_DUNG_DICH_VU
    (MaSuDungDV, MaDatPhong, MaDV, NgaySuDung, SoLuong, DonGiaThoiDiem) VALUES
('SD00000001', 'DP00000001', 'DV00000002', '2026-01-11 07:30:00' + INTERVAL @Lech DAY, 2,  250000.00),
('SD00000002', 'DP00000001', 'DV00000001', '2026-01-11 09:00:00' + INTERVAL @Lech DAY, 2,   80000.00),
('SD00000003', 'DP00000001', 'DV00000005', '2026-01-11 20:00:00' + INTERVAL @Lech DAY, 1,  100000.00),
('SD00000004', 'DP00000002', 'DV00000002', '2026-04-21 07:30:00' + INTERVAL @Lech DAY, 4,  250000.00),
('SD00000005', 'DP00000002', 'DV00000003', '2026-04-20 12:00:00' + INTERVAL @Lech DAY, 1,  500000.00),
('SD00000006', 'DP00000002', 'DV00000004', '2026-04-22 15:00:00' + INTERVAL @Lech DAY, 1,  700000.00),
('SD00000007', 'DP00000003', 'DV00000006', '2026-08-14 19:30:00' + INTERVAL @Lech DAY, 2,  350000.00),
('SD00000008', 'DP00000003', 'DV00000007', '2026-08-15 08:00:00' + INTERVAL @Lech DAY, 2,  200000.00),
('SD00000009', 'DP00000004', 'DV00000008', '2026-09-11 09:00:00' + INTERVAL @Lech DAY, 2, 1000000.00),
('SD00000010', 'DP00000004', 'DV00000009', '2026-09-10 18:00:00' + INTERVAL @Lech DAY, 2,  400000.00);

-- TongTien duoc trg_CTHD_CapNhatTongTien tinh lai khi nap chi tiet ben duoi.
INSERT INTO HOA_DON
    (MaHoaDon, MaDatPhong, NgayLap, TongTien, LoaiThanhToan, TrangThai) VALUES
('HD00000001', 'DP00000001', '2026-01-12 11:00:00' + INTERVAL @Lech DAY, 1360000.00, 'The',          'DaThanhToan'),
('HD00000002', 'DP00000002', '2026-04-23 10:30:00' + INTERVAL @Lech DAY, 3620000.00, 'ChuyenKhoan', 'DaThanhToan'),
('HD00000003', 'DP00000003', '2026-08-16 11:00:00' + INTERVAL @Lech DAY, 2100000.00, 'TienMat',      'DaThanhToan'),
('HD00000004', 'DP00000004', '2026-09-12 10:45:00' + INTERVAL @Lech DAY, 4180000.00, 'The',          'DaThanhToan'),
('HD00000005', 'DP00000005', '2026-09-16 11:15:00' + INTERVAL @Lech DAY, 1500000.00, 'TienMat',      'DaThanhToan'),
('HD00000006', 'DP00000006', '2026-09-15 14:00:00' + INTERVAL @Lech DAY, 2760000.00, NULL,           'ChuaThanhToan'),
('HD00000007', 'DP00000007', '2026-09-12 13:45:00' + INTERVAL @Lech DAY,       0.00, NULL,           'ChuaThanhToan'),
('HD00000008', 'DP00000008', '2026-09-13 15:10:00' + INTERVAL @Lech DAY,       0.00, NULL,           'ChuaThanhToan'),
('HD00000009', 'DP00000009', '2026-09-05 10:00:00' + INTERVAL @Lech DAY,       0.00, NULL,           'DaHuy'),
('HD00000010', 'DP00000010', '2026-09-12 09:00:00' + INTERVAL @Lech DAY,       0.00, NULL,           'DaHuy');

INSERT INTO CHI_TIET_HOA_DON
    (MaCTHD, MaHoaDon, LoaiKhoanMuc, SoTien, GhiChu) VALUES
('CT00000001', 'HD00000001', 'TienPhong', 1200000.00, 'Phong 101: 600.000 x 2 dem'),
('CT00000002', 'HD00000001', 'DichVu',     760000.00, 'Buffet, giat ui va minibar'),
('CT00000003', 'HD00000002', 'TienPhong', 2640000.00, 'Phong 102: 880.000 x 3 dem'),
('CT00000004', 'HD00000002', 'DichVu',    2200000.00, 'Buffet, dua don san bay va spa'),
('CT00000005', 'HD00000003', 'TienPhong', 2000000.00, 'Phong 201: 1.000.000 x 2 dem'),
('CT00000006', 'HD00000003', 'DichVu',    1100000.00, 'An tai phong va thue xe may'),
('CT00000007', 'HD00000004', 'TienPhong', 2760000.00, 'Phong 202: 1.380.000 x 2 dem'),
('CT00000008', 'HD00000004', 'DichVu',    2800000.00, 'Phong hoi nghi va giuong phu'),
('CT00000009', 'HD00000005', 'TienPhong', 3000000.00, 'Phong 301: 1.500.000 x 2 dem'),
('CT00000010', 'HD00000006', 'TienPhong', 5520000.00, 'Phong 302: 1.840.000 x 3 dem'),
('CT00000011', 'HD00000001', 'PhuThu',      100000.00, 'Phu thu nhan phong som'),
('CT00000012', 'HD00000002', 'PhuThu',      300000.00, 'Phu thu tra phong muon'),
('CT00000013', 'HD00000001', 'GiamGia',    -100000.00, 'Giam gia khach hang thanh vien'),
('CT00000014', 'HD00000002', 'GiamGia',    -200000.00, 'Giam gia theo chuong trinh khuyen mai'),
('CT00000015', 'HD00000001', 'GiamTru',    -600000.00, 'Tru tien coc cua phieu DP00000001'),
('CT00000016', 'HD00000002', 'GiamTru',   -1320000.00, 'Tru tien coc cua phieu DP00000002'),
('CT00000017', 'HD00000003', 'GiamTru',   -1000000.00, 'Tru tien coc cua phieu DP00000003'),
('CT00000018', 'HD00000004', 'GiamTru',   -1380000.00, 'Tru tien coc cua phieu DP00000004'),
('CT00000019', 'HD00000005', 'GiamTru',   -1500000.00, 'Tru tien coc cua phieu DP00000005'),
('CT00000020', 'HD00000006', 'GiamTru',   -2760000.00, 'Tru tien coc cua phieu DP00000006');

-- B. DU LIEU DEMO THEO @HomNay

INSERT INTO KHACH_HANG (MaKH, HoTen, CCCD, SDT, Email)
WITH RECURSIVE so (n) AS (
    SELECT 11 UNION ALL SELECT n + 1 FROM so WHERE n < 60
)
SELECT CONCAT('KH', LPAD(n, 8, '0')),
       CONCAT_WS(' ',
           ELT((n - 11)     MOD 10 + 1, 'Nguyen', 'Tran', 'Le', 'Pham', 'Hoang',
                                        'Vo', 'Dang', 'Bui', 'Do', 'Ho'),
           ELT((n - 11) * 3 MOD 10 + 1, 'Thi', 'Van', 'Minh', 'Ngoc', 'Gia',
                                        'Quoc', 'Thanh', 'Hai', 'Anh', 'Kim'),
           ELT((n - 11) * 7 MOD 10 + 1, 'An', 'Binh', 'Chi', 'Dung', 'Giang',
                                        'Ha', 'Khanh', 'Linh', 'Mai', 'Nam')),
       CONCAT('0793', LPAD(n, 8, '0')),
       CONCAT('09', 10000000 + n),
       CONCAT('khach', n, '@example.com')
FROM   so;

INSERT INTO PHONG (MaPhong, MaLoaiPhong, SoPhong, Tang, TrangThai)
WITH RECURSIVE so (n) AS (
    SELECT 11 UNION ALL SELECT n + 1 FROM so WHERE n < 42
)
SELECT CONCAT('PH', LPAD(n, 8, '0')),
       CONCAT('LP', LPAD((n - 11) MOD 10 + 1, 8, '0')),
       CONCAT((n - 11) DIV 8 + 1, LPAD((n - 11) MOD 8 + 3, 2, '0')),
       (n - 11) DIV 8 + 1,
       CASE WHEN n <= 22 THEN 'DaDat'        -- nhom 1: khach nhan hom nay
            WHEN n <= 31 THEN 'DangSuDung'   -- nhom 2: khach tra hom nay
            WHEN n <= 40 THEN 'DangDon'      -- nhom 3: khach vua tra sang nay
            ELSE              'Trong'
       END
FROM   so;

-- Bang tam gom moi phieu demo. So hieu: nhom 1 = 11-22, nhom 2 = 23-31,
-- nhom 3 = 90-98, nhom 4 = 32-79.
DROP TEMPORARY TABLE IF EXISTS tmp_PhieuMau;
CREATE TEMPORARY TABLE tmp_PhieuMau AS
WITH RECURSIVE so (n) AS (
    SELECT 0 UNION ALL SELECT n + 1 FROM so WHERE n < 47
),
phieu AS (
    -- Nhom 1: 12 phieu DaDat nhan phong hom nay.
    SELECT 11 + n AS SoHieu, 11 + n AS SoKH, 11 + n AS SoPhong,
           @HomNay AS NgayIn, 2 + n MOD 3 AS SoDem, 'DaDat' AS TrangThai
    FROM   so WHERE n < 12
    UNION  ALL
    -- Nhom 2: 9 phieu DangO tra phong hom nay.
    SELECT 23 + n, 23 + n, 23 + n,
           @HomNay - INTERVAL (2 + n MOD 3) DAY, 2 + n MOD 3, 'DangO'
    FROM   so WHERE n < 9
    UNION  ALL
    -- Nhom 3: 9 phieu HoanTat, tra phong va thanh toan sang nay.
    SELECT 90 + n, 32 + n, 32 + n,
           @HomNay - INTERVAL 2 DAY, 2, 'HoanTat'
    FROM   so WHERE n < 9
    UNION  ALL
    -- Nhom 4: 48 phieu HoanTat lich su, moi tuan mot phieu; phong lap lai sau
    --         77 ngay nen khong trung ngay.
    SELECT 32 + n, 11 + (32 + n) MOD 50, 32 + (32 + n) MOD 11,
           @HomNay - INTERVAL (10 + 7 * n) DAY, 2, 'HoanTat'
    FROM   so
)
SELECT p.SoHieu,
       CONCAT('DP', LPAD(p.SoHieu, 8, '0'))   AS MaDatPhong,
       CONCAT('KH', LPAD(p.SoKH,   8, '0'))   AS MaKH,
       ph.MaPhong,
       ph.SoPhong,
       p.NgayIn,
       p.NgayIn + INTERVAL p.SoDem DAY         AS NgayOut,
       p.SoDem,
       p.TrangThai,
       lp.DonGiaNgay                           AS DonGia,
       CONCAT('DV', LPAD(p.SoHieu MOD 10 + 1, 8, '0')) AS MaDV,
       1 + p.SoHieu MOD 3                      AS SoLuongDV
FROM   phieu      p
JOIN   PHONG      ph ON ph.MaPhong     = CONCAT('PH', LPAD(p.SoPhong, 8, '0'))
JOIN   LOAI_PHONG lp ON lp.MaLoaiPhong = ph.MaLoaiPhong;

INSERT INTO PHIEU_DAT_PHONG
    (MaDatPhong, MaKH, MaTK, NgayLap, NgayCheckIn, NgayCheckOut, TienCoc, TrangThai)
SELECT MaDatPhong,
       MaKH,
       IF(SoHieu MOD 2 = 0, 'TK00000002', 'TK00000003'),
       TIMESTAMP(NgayIn - INTERVAL 7 DAY, '09:00:00'),
       NgayIn,
       NgayOut,
       DonGia,
       TrangThai
FROM   tmp_PhieuMau
ORDER  BY SoHieu;

INSERT INTO CHI_TIET_DAT_PHONG (MaDatPhong, MaPhong, GiaThueThoiDiem, SoDem)
SELECT MaDatPhong, MaPhong, DonGia, SoDem
FROM   tmp_PhieuMau
ORDER  BY SoHieu;

-- DonGiaThoiDiem = 0 de trg_SDDV_TinhThanhTien chot gia tu DICH_VU.
INSERT INTO SU_DUNG_DICH_VU
    (MaSuDungDV, MaDatPhong, MaDV, NgaySuDung, SoLuong, DonGiaThoiDiem)
SELECT CONCAT('SD', LPAD(SoHieu, 8, '0')),
       MaDatPhong,
       MaDV,
       TIMESTAMP(NgayIn, '19:00:00'),
       SoLuongDV,
       0
FROM   tmp_PhieuMau
WHERE  TrangThai IN ('DangO', 'HoanTat')
ORDER  BY SoHieu;

INSERT INTO HOA_DON
    (MaHoaDon, MaDatPhong, NgayLap, TongTien, LoaiThanhToan, TrangThai)
SELECT CONCAT('HD', LPAD(SoHieu, 8, '0')),
       MaDatPhong,
       CASE WHEN TrangThai = 'DangO'  THEN TIMESTAMP(@HomNay, '08:00:00')
            WHEN NgayOut   = @HomNay  THEN TIMESTAMP(NgayOut, '09:00:00')
            ELSE                           TIMESTAMP(NgayOut, '11:00:00')
       END,
       0,
       IF(TrangThai = 'HoanTat',
          ELT(SoHieu MOD 3 + 1, 'TienMat', 'ChuyenKhoan', 'The'), NULL),
       IF(TrangThai = 'HoanTat', 'DaThanhToan', 'ChuaThanhToan')
FROM   tmp_PhieuMau
WHERE  TrangThai IN ('DangO', 'HoanTat')
ORDER  BY SoHieu;

INSERT INTO CHI_TIET_HOA_DON (MaCTHD, MaHoaDon, LoaiKhoanMuc, SoTien, GhiChu)
SELECT CONCAT('CT', LPAD(t.SoHieu * 10 + 1, 8, '0')),
       CONCAT('HD', LPAD(t.SoHieu, 8, '0')),
       'TienPhong',
       ct.ThanhTien,
       CONCAT('Phong ', t.SoPhong, ': ', t.SoDem, ' dem')
FROM   tmp_PhieuMau       t
JOIN   CHI_TIET_DAT_PHONG ct ON ct.MaDatPhong = t.MaDatPhong
WHERE  t.TrangThai IN ('DangO', 'HoanTat');

INSERT INTO CHI_TIET_HOA_DON (MaCTHD, MaHoaDon, LoaiKhoanMuc, SoTien, GhiChu)
SELECT CONCAT('CT', LPAD(t.SoHieu * 10 + 2, 8, '0')),
       CONCAT('HD', LPAD(t.SoHieu, 8, '0')),
       'DichVu',
       sd.ThanhTien,
       dv.TenDV
FROM   tmp_PhieuMau    t
JOIN   SU_DUNG_DICH_VU sd ON sd.MaSuDungDV = CONCAT('SD', LPAD(t.SoHieu, 8, '0'))
JOIN   DICH_VU         dv ON dv.MaDV       = sd.MaDV;

INSERT INTO CHI_TIET_HOA_DON (MaCTHD, MaHoaDon, LoaiKhoanMuc, SoTien, GhiChu)
SELECT CONCAT('CT', LPAD(t.SoHieu * 10 + 3, 8, '0')),
       CONCAT('HD', LPAD(t.SoHieu, 8, '0')),
       'GiamTru',
       -pd.TienCoc,
       CONCAT('Tru tien coc cua phieu ', t.MaDatPhong)
FROM   tmp_PhieuMau    t
JOIN   PHIEU_DAT_PHONG pd ON pd.MaDatPhong = t.MaDatPhong
WHERE  t.TrangThai IN ('DangO', 'HoanTat');

INSERT INTO DON_PHONG (MaDon, MaPhong, MaTK, ThoiGian, GhiChu) VALUES
('DON0000011', 'PH00000023', 'TK00000004', TIMESTAMP(@HomNay, '09:50:00'),                   'Don phong sau khi khach tra'),
('DON0000012', 'PH00000024', 'TK00000005', TIMESTAMP(@HomNay, '10:15:00'),                   'Thay ga giuong va khan tam'),
('DON0000013', 'PH00000011', 'TK00000004', TIMESTAMP(@HomNay, '08:30:00'),                   'Chuan bi phong don khach trong ngay'),
('DON0000014', 'PH00000012', 'TK00000005', TIMESTAMP(@HomNay, '08:45:00'),                   'Chuan bi phong don khach trong ngay'),
('DON0000015', 'PH00000025', 'TK00000004', TIMESTAMP(@HomNay - INTERVAL 1 DAY, '14:20:00'), 'Ve sinh dinh ky'),
('DON0000016', 'PH00000026', 'TK00000005', TIMESTAMP(@HomNay - INTERVAL 1 DAY, '15:00:00'), 'Bo sung minibar');

INSERT INTO SUA_PHONG (MaSua, MaPhong, MaTK, ThoiGian, ChiPhi, MoTaLoi) VALUES
('SUA0000011', 'PH00000027', 'TK00000006', TIMESTAMP(@HomNay, '08:10:00'),                        0.00, 'May lanh khong chay, dang kiem tra'),
('SUA0000012', 'PH00000028', 'TK00000006', TIMESTAMP(@HomNay - INTERVAL 1 DAY, '16:30:00'), 320000.00, 'Thay voi sen phong tam');

DROP TEMPORARY TABLE tmp_PhieuMau;

COMMIT;

-- TongTien lech tong chi tiet. Mong doi: 0 dong.
SELECT hd.MaHoaDon, hd.TongTien, SUM(ct.SoTien) AS TongChiTiet
FROM   HOA_DON hd
JOIN   CHI_TIET_HOA_DON ct ON ct.MaHoaDon = hd.MaHoaDon
GROUP  BY hd.MaHoaDon, hd.TongTien
HAVING SUM(ct.SoTien) <> hd.TongTien;

-- Mong doi (ngay nao cung vay): 42 | 60 | 12 | 9 | 0 | 0.
SELECT (SELECT COUNT(*) FROM PHONG)                                AS SoPhong,
       (SELECT COUNT(*) FROM KHACH_HANG)                           AS SoKhach,
       (SELECT COUNT(*) FROM PHIEU_DAT_PHONG
        WHERE  TrangThai = 'DaDat'   AND NgayCheckIn  = CURDATE()) AS NhanHomNay,
       (SELECT COUNT(*) FROM PHIEU_DAT_PHONG
        WHERE  TrangThai = 'DangO'   AND NgayCheckOut = CURDATE()) AS TraHomNay,
       (SELECT COUNT(*) FROM PHIEU_DAT_PHONG
        WHERE  TrangThai = 'HoanTat' AND NgayCheckOut > CURDATE()) AS HoanTatTuongLai,
       (SELECT COUNT(*) FROM PHIEU_DAT_PHONG
        WHERE  TrangThai = 'DaDat'   AND NgayCheckIn  < CURDATE()) AS DaDatQuaHan;

-- Mong doi: 1 dong, 10 hoa don, doanh thu thuan 50.530.000.
CALL sp_BaoCaoDoanhThu(CURDATE(), CURDATE());
