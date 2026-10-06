-- ============================================================
-- FILE: 01_CreateDatabase.sql
-- MÔ TẢ: Tạo Database và các bảng cho hệ thống Đặt xe công nghệ
-- Đồ án cuối kỳ - Nhóm 5 - IE103.F21.CN1.CNTT
-- ============================================================

USE master;
GO

-- Tạo Database
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QL_DatXeCongNghe')
    DROP DATABASE QL_DatXeCongNghe;
GO

CREATE DATABASE QL_DatXeCongNghe;
GO

USE QL_DatXeCongNghe;
GO

CREATE TABLE KHACHHANG (
                           Ma_Khach_Hang   CHAR(10)        NOT NULL,
                           Ten_Khach_Hang  NVARCHAR(100)   NOT NULL,
                           SDT             VARCHAR(15)     NOT NULL,
                           Email           NVARCHAR(100)   NULL,
                           Trang_Thai      NVARCHAR(20)    NOT NULL DEFAULT 'Hoat dong',
                           CONSTRAINT PK_KhachHang PRIMARY KEY (Ma_Khach_Hang),
                           CONSTRAINT UQ_KH_SDT UNIQUE (SDT),
                           CONSTRAINT UQ_KH_Email UNIQUE (Email),
                           CONSTRAINT CK_KH_TrangThai CHECK (Trang_Thai IN ('Hoat dong', 'Bi khoa'))
);

CREATE TABLE TAIXE (
                       Ma_Tai_Xe       CHAR(10)        NOT NULL,
                       Ten_Tai_Xe      NVARCHAR(100)   NOT NULL,
                       SDT             VARCHAR(15)     NOT NULL,
                       Trang_Thai      NVARCHAR(20)    NOT NULL DEFAULT 'Khong hoat dong',
                       Diem_Uy_Tin     DECIMAL(3,2)    NOT NULL DEFAULT 5.00,
                       CONSTRAINT PK_TaiXe PRIMARY KEY (Ma_Tai_Xe),
                       CONSTRAINT UQ_TX_SDT UNIQUE (SDT),
                       CONSTRAINT CK_TX_TrangThai CHECK (Trang_Thai IN ('Khong hoat dong', 'San sang', 'Dang ban', 'Bi dinh chi')),
                       CONSTRAINT CK_TX_DiemUyTin CHECK (Diem_Uy_Tin >= 1.00 AND Diem_Uy_Tin <= 5.00)
);

CREATE TABLE BANGGIA (
                         Ma_Bang_Gia     CHAR(10)        NOT NULL,
                         Loai_Xe         VARCHAR(20)     NOT NULL,
                         Gia_Co_Ban      DECIMAL(18,2)   NOT NULL,
                         Don_Gia_Km      DECIMAL(18,2)   NOT NULL,
                         Don_Gia_Phut    DECIMAL(18,2)   NOT NULL,
                         Khung_Gio       VARCHAR(50)     NOT NULL,
                         Tu_Ngay         DATE            NOT NULL,
                         Den_Ngay        DATE            NOT NULL,
                         CONSTRAINT PK_BangGia PRIMARY KEY (Ma_Bang_Gia),
                         CONSTRAINT CK_BG_LoaiXe CHECK (Loai_Xe IN ('Xe may', 'O to')),
                         CONSTRAINT CK_BG_GiaCoBan CHECK (Gia_Co_Ban >= 0),
                         CONSTRAINT CK_BG_DonGiaKm CHECK (Don_Gia_Km > 0),
                         CONSTRAINT CK_BG_DonGiaPhut CHECK (Don_Gia_Phut >= 0),
                         CONSTRAINT CK_BG_KhungGio CHECK (Khung_Gio IN ('Binh thuong', 'Cao diem')),
                         CONSTRAINT CK_BG_ThoiGian CHECK (Den_Ngay > Tu_Ngay)
);

CREATE TABLE VOUCHER (
                         Ma_Voucher      CHAR(10)        NOT NULL,
                         Ma_Code         VARCHAR(50)     NOT NULL,
                         Loai_Giam_Gia   VARCHAR(20)     NOT NULL,
                         Gia_Tri_Giam    DECIMAL(18,2)   NOT NULL,
                         So_Luot_Toi_Da  INT             NOT NULL,
                         So_Luot_Da_Dung INT             NOT NULL DEFAULT 0,
                         Han_Su_Dung     DATETIME        NOT NULL,
                         Trang_Thai      NVARCHAR(20)    NOT NULL DEFAULT 'Dang hoat dong',
                         CONSTRAINT PK_Voucher PRIMARY KEY (Ma_Voucher),
                         CONSTRAINT UQ_VC_Code UNIQUE (Ma_Code),
                         CONSTRAINT CK_VC_LoaiGiam CHECK (Loai_Giam_Gia IN ('Giam co dinh', 'Giam theo phan tram')),
                         CONSTRAINT CK_VC_GiaTri CHECK (Gia_Tri_Giam > 0),
                         CONSTRAINT CK_VC_SoLuotMax CHECK (So_Luot_Toi_Da > 0),
                         CONSTRAINT CK_VC_SoLuotDaDung CHECK (So_Luot_Da_Dung >= 0 AND So_Luot_Da_Dung <= So_Luot_Toi_Da),
                         CONSTRAINT CK_VC_TrangThai CHECK (Trang_Thai IN ('Dang hoat dong', 'Da het han', 'Da huy'))
);

CREATE TABLE CUOCXE (
                        Ma_Cuoc_Xe      CHAR(10)        NOT NULL,
                        Ma_Khach_Hang   CHAR(10)        NOT NULL,
                        Ma_Tai_Xe       CHAR(10)        NULL,
                        Ma_Bang_Gia     CHAR(10)        NOT NULL,
                        Ma_Voucher      CHAR(10)        NULL,
                        Khoang_Cach     FLOAT           NOT NULL,
                        Gia_Uoc_Tinh    DECIMAL(18,2)   NOT NULL,
                        Tong_Tien       DECIMAL(18,2)   NULL,
                        Trang_Thai      NVARCHAR(20)    NOT NULL DEFAULT 'Cho nhan',
                        Thoi_Gian_Tao   DATETIME        NOT NULL DEFAULT GETDATE(),
                        CONSTRAINT PK_CuocXe PRIMARY KEY (Ma_Cuoc_Xe),
                        CONSTRAINT FK_CX_KhachHang FOREIGN KEY (Ma_Khach_Hang) REFERENCES KHACHHANG(Ma_Khach_Hang),
                        CONSTRAINT FK_CX_TaiXe FOREIGN KEY (Ma_Tai_Xe) REFERENCES TAIXE(Ma_Tai_Xe),
                        CONSTRAINT FK_CX_BangGia FOREIGN KEY (Ma_Bang_Gia) REFERENCES BANGGIA(Ma_Bang_Gia),
                        CONSTRAINT FK_CX_Voucher FOREIGN KEY (Ma_Voucher) REFERENCES VOUCHER(Ma_Voucher),
                        CONSTRAINT CK_CX_KhoangCach CHECK (Khoang_Cach >= 0),
                        CONSTRAINT CK_CX_GiaUocTinh CHECK (Gia_Uoc_Tinh >= 0),
                        CONSTRAINT CK_CX_TongTien CHECK (Tong_Tien >= 0),
                        CONSTRAINT CK_CX_TrangThai CHECK (Trang_Thai IN ('Cho nhan', 'Da nhan', 'Dang chay', 'Hoan thanh', 'Da huy'))
);

CREATE TABLE DIEMDEN (
                         Ma_Diem_Den     CHAR(10)        NOT NULL,
                         Ma_Cuoc_Xe      CHAR(10)        NOT NULL,
                         Thu_Tu_Dung     INT             NOT NULL,
                         Loai_Diem_Den   NVARCHAR(20)    NOT NULL,
                         Dia_Chi         NVARCHAR(255)   NOT NULL,
                         Vi_Do           DECIMAL(10,6)   NOT NULL,
                         Kinh_Do         DECIMAL(10,6)   NOT NULL,
                         CONSTRAINT PK_DiemDen PRIMARY KEY (Ma_Diem_Den),
                         CONSTRAINT FK_DD_CuocXe FOREIGN KEY (Ma_Cuoc_Xe) REFERENCES CUOCXE(Ma_Cuoc_Xe),
                         CONSTRAINT CK_DD_ThuTu CHECK (Thu_Tu_Dung > 0),
                         CONSTRAINT CK_DD_Loai CHECK (Loai_Diem_Den IN ('Diem don', 'Diem tra', 'Tram dung'))
);

CREATE TABLE HANGDOI (
                         Ma_Hang_Doi         CHAR(10)        NOT NULL,
                         Ma_Cuoc_Xe          CHAR(10)        NOT NULL,
                         Ban_Kinh_Phat_Song  FLOAT           NOT NULL,
                         So_Lan_Phat_Song    INT             NOT NULL DEFAULT 1,
                         Thoi_Gian_Phat_Song DATETIME        NOT NULL DEFAULT GETDATE(),
                         Trang_Thai          NVARCHAR(20)    NOT NULL DEFAULT 'Dang hoat dong',
                         CONSTRAINT PK_HangDoi PRIMARY KEY (Ma_Hang_Doi),
                         CONSTRAINT FK_HD_CuocXe FOREIGN KEY (Ma_Cuoc_Xe) REFERENCES CUOCXE(Ma_Cuoc_Xe),
                         CONSTRAINT CK_HD_BanKinh CHECK (Ban_Kinh_Phat_Song > 0),
                         CONSTRAINT CK_HD_SoLan CHECK (So_Lan_Phat_Song > 0),
                         CONSTRAINT CK_HD_TrangThai CHECK (Trang_Thai IN ('Dang hoat dong', 'Da het han', 'Da nhan'))
);

CREATE TABLE VIDIENTU (
                          Ma_Vi           CHAR(10)        NOT NULL,
                          Loai_Chu_So_Huu VARCHAR(20)     NOT NULL,
                          Ma_Chu_So_Huu   CHAR(10)        NOT NULL,
                          So_Du           DECIMAL(18,2)   NOT NULL DEFAULT 0,
                          Don_Vi_Tien_Te  VARCHAR(10)     NOT NULL DEFAULT 'VND',
                          CONSTRAINT PK_ViDienTu PRIMARY KEY (Ma_Vi),
                          CONSTRAINT CK_VDT_Loai CHECK (Loai_Chu_So_Huu IN ('Khach hang', 'Tai xe')),
                          CONSTRAINT CK_VDT_SoDu CHECK (So_Du >= 0)
);

CREATE TABLE LICHSUGIAODICH (
                                Ma_Giao_Dich        CHAR(10)        NOT NULL,
                                Ma_Vi               CHAR(10)        NOT NULL,
                                Ma_Cuoc_Xe          CHAR(10)        NULL,
                                Loai_Giao_Dich      VARCHAR(20)     NOT NULL,
                                So_Tien             DECIMAL(18,2)   NOT NULL,
                                Noi_Dung            NVARCHAR(MAX)   NULL,
                                Thoi_Gian_Giao_Dich DATETIME        NOT NULL DEFAULT GETDATE(),
                                CONSTRAINT PK_LichSuGD PRIMARY KEY (Ma_Giao_Dich),
                                CONSTRAINT FK_LSGD_Vi FOREIGN KEY (Ma_Vi) REFERENCES VIDIENTU(Ma_Vi),
                                CONSTRAINT FK_LSGD_CuocXe FOREIGN KEY (Ma_Cuoc_Xe) REFERENCES CUOCXE(Ma_Cuoc_Xe),
                                CONSTRAINT CK_LSGD_Loai CHECK (Loai_Giao_Dich IN ('Cong tien', 'Tru tien')),
                                CONSTRAINT CK_LSGD_SoTien CHECK (So_Tien > 0)
);

CREATE TABLE PHUONGTIEN (
                            Ma_Phuong_Tien  CHAR(10)        NOT NULL,
                            Ma_Tai_Xe       CHAR(10)        NOT NULL,
                            Loai_Phuong_Tien VARCHAR(20)    NOT NULL,
                            Nhan_Hieu       NVARCHAR(50)    NOT NULL,
                            Bien_So_Xe      VARCHAR(20)     NOT NULL,
                            Trang_Thai      NVARCHAR(20)    NOT NULL DEFAULT 'Hoat dong',
                            Thoi_Gian_Tao   DATETIME        NOT NULL DEFAULT GETDATE(),
                            CONSTRAINT PK_PhuongTien PRIMARY KEY (Ma_Phuong_Tien),
                            CONSTRAINT FK_PT_TaiXe FOREIGN KEY (Ma_Tai_Xe) REFERENCES TAIXE(Ma_Tai_Xe),
                            CONSTRAINT UQ_PT_BienSo UNIQUE (Bien_So_Xe),
                            CONSTRAINT CK_PT_Loai CHECK (Loai_Phuong_Tien IN ('Xe may', 'O to')),
                            CONSTRAINT CK_PT_TrangThai CHECK (Trang_Thai IN ('Hoat dong', 'Khong hoat dong'))
);

CREATE TABLE DANHGIA (
                         Ma_Danh_Gia         CHAR(10)        NOT NULL,
                         Ma_Cuoc_Xe          CHAR(10)        NOT NULL,
                         Diem_Danh_Gia       TINYINT         NOT NULL,
                         Binh_Luan           NVARCHAR(MAX)   NULL,
                         Thoi_Gian_Danh_Gia  DATETIME        NOT NULL DEFAULT GETDATE(),
                         CONSTRAINT PK_DanhGia PRIMARY KEY (Ma_Danh_Gia),
                         CONSTRAINT FK_DG_CuocXe FOREIGN KEY (Ma_Cuoc_Xe) REFERENCES CUOCXE(Ma_Cuoc_Xe),
                         CONSTRAINT CK_DG_Diem CHECK (Diem_Danh_Gia IN (1, 2, 3, 4, 5)),
                         CONSTRAINT UQ_DG_CuocXe UNIQUE (Ma_Cuoc_Xe)
);

CREATE TABLE THONGBAO (
                          Ma_Thong_Bao    CHAR(10)        NOT NULL,
                          Loai_Nguoi_Nhan VARCHAR(20)     NOT NULL,
                          Ma_Nguoi_Nhan   CHAR(10)        NOT NULL,
                          Tieu_De         NVARCHAR(200)   NOT NULL,
                          Noi_Dung        NVARCHAR(MAX)   NULL,
                          Trang_Thai_Doc  NVARCHAR(15)    NOT NULL DEFAULT 'Chua doc',
                          Thoi_Gian_Gui   DATETIME        NOT NULL DEFAULT GETDATE(),
                          CONSTRAINT PK_ThongBao PRIMARY KEY (Ma_Thong_Bao),
                          CONSTRAINT CK_TB_LoaiNguoiNhan CHECK (Loai_Nguoi_Nhan IN ('Khach hang', 'Tai xe')),
                          CONSTRAINT CK_TB_TrangThaiDoc CHECK (Trang_Thai_Doc IN ('Da doc', 'Chua doc'))
);

CREATE TABLE KHACHHANG_VOUCHER (
                                   Ma_Khach_Hang       CHAR(10)        NOT NULL,
                                   Ma_Voucher          CHAR(10)        NOT NULL,
                                   Ngay_Nhan           DATETIME        NOT NULL DEFAULT GETDATE(),
                                   Trang_Thai_Su_Dung  VARCHAR(20)     NOT NULL DEFAULT 'Chua su dung',
                                   CONSTRAINT PK_KH_Voucher PRIMARY KEY (Ma_Khach_Hang, Ma_Voucher),
                                   CONSTRAINT FK_KHV_KhachHang FOREIGN KEY (Ma_Khach_Hang) REFERENCES KHACHHANG(Ma_Khach_Hang),
                                   CONSTRAINT FK_KHV_Voucher FOREIGN KEY (Ma_Voucher) REFERENCES VOUCHER(Ma_Voucher),
                                   CONSTRAINT CK_KHV_TrangThai CHECK (Trang_Thai_Su_Dung IN ('Chua su dung', 'Da su dung'))
);
GO

PRINT N'✓ Tạo database và tất cả bảng thành công!';
GO

DROP TABLE IF EXISTS KHACHHANG_VOUCHER;
DROP TABLE IF EXISTS THONGBAO;
DROP TABLE IF EXISTS DANHGIA;
DROP TABLE IF EXISTS PHUONGTIEN;
DROP TABLE IF EXISTS LICHSUGIAODICH;
DROP TABLE IF EXISTS VIDIENTU;
DROP TABLE IF EXISTS HANGDOI;
DROP TABLE IF EXISTS DIEMDEN;
DROP TABLE IF EXISTS CUOCXE;
DROP TABLE IF EXISTS VOUCHER;
DROP TABLE IF EXISTS BANGGIA;
DROP TABLE IF EXISTS TAIXE;
DROP TABLE IF EXISTS KHACHHANG;
GO
