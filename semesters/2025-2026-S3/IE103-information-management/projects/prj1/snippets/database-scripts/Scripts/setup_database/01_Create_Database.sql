-- 01. CO SO DU LIEU VA 14 BANG. Chay lai duoc nhung XOA SACH du lieu dang co.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS QuanLyKhachSan;

CREATE DATABASE QuanLyKhachSan
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE QuanLyKhachSan;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE LOAI_TAI_KHOAN (
    MaLoaiTK  CHAR(10)     NOT NULL,
    TenLoaiTK VARCHAR(50)  NOT NULL,
    MoTa      VARCHAR(200),

    CONSTRAINT PK_LOAI_TAI_KHOAN
        PRIMARY KEY (MaLoaiTK),
    CONSTRAINT UQ_LOAI_TAI_KHOAN_Ten
        UNIQUE (TenLoaiTK)
) ENGINE = InnoDB;

CREATE TABLE TAI_KHOAN (
    MaTK        CHAR(10)     NOT NULL,
    MaLoaiTK    CHAR(10)     NOT NULL,
    TenDangNhap VARCHAR(50)  NOT NULL,
    MatKhau     VARCHAR(255) NOT NULL,
    HoTen       VARCHAR(100) NOT NULL,
    TrangThai   VARCHAR(20)  NOT NULL DEFAULT 'DangLamViec',

    CONSTRAINT PK_TAI_KHOAN
        PRIMARY KEY (MaTK),
    CONSTRAINT UQ_TAI_KHOAN_TenDangNhap
        UNIQUE (TenDangNhap),
    CONSTRAINT CK_TAI_KHOAN_TrangThai
        CHECK (TrangThai IN ('DangLamViec', 'TamNghi', 'NghiViec')),
    CONSTRAINT FK_TAI_KHOAN_LOAI_TAI_KHOAN
        FOREIGN KEY (MaLoaiTK)
        REFERENCES LOAI_TAI_KHOAN (MaLoaiTK)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE KHACH_HANG (
    MaKH  CHAR(10)     NOT NULL,
    HoTen VARCHAR(100) NOT NULL,
    CCCD  VARCHAR(20)  NOT NULL,
    SDT   VARCHAR(15),
    Email VARCHAR(100),

    CONSTRAINT PK_KHACH_HANG
        PRIMARY KEY (MaKH),
    CONSTRAINT UQ_KHACH_HANG_CCCD
        UNIQUE (CCCD),
    CONSTRAINT UQ_KHACH_HANG_Email
        UNIQUE (Email)
) ENGINE = InnoDB;

CREATE TABLE LOAI_PHONG (
    MaLoaiPhong  CHAR(10)      NOT NULL,
    TenLoaiPhong VARCHAR(50)   NOT NULL,
    DonGiaNgay   DECIMAL(18,2) NOT NULL,

    CONSTRAINT PK_LOAI_PHONG
        PRIMARY KEY (MaLoaiPhong),
    CONSTRAINT UQ_LOAI_PHONG_Ten
        UNIQUE (TenLoaiPhong),
    CONSTRAINT CK_LOAI_PHONG_DonGia
        CHECK (DonGiaNgay >= 0)
) ENGINE = InnoDB;

CREATE TABLE BANG_GIA_PHONG (
    MaBangGia    CHAR(10)      NOT NULL,
    MaLoaiPhong  CHAR(10)      NOT NULL,
    HeSo         DECIMAL(4,2)  NOT NULL DEFAULT 1.00,
    ApDungTuNgay DATE          NOT NULL,
    DenNgay      DATE          NOT NULL,
    DonGia       DECIMAL(18,2) NOT NULL,

    CONSTRAINT PK_BANG_GIA_PHONG
        PRIMARY KEY (MaBangGia),
    CONSTRAINT CK_BANG_GIA_PHONG_HeSo
        CHECK (HeSo > 0),
    CONSTRAINT CK_BANG_GIA_PHONG_Ngay
        CHECK (DenNgay >= ApDungTuNgay),
    CONSTRAINT CK_BANG_GIA_PHONG_DonGia
        CHECK (DonGia >= 0),
    CONSTRAINT FK_BANG_GIA_PHONG_LOAI_PHONG
        FOREIGN KEY (MaLoaiPhong)
        REFERENCES LOAI_PHONG (MaLoaiPhong)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE PHONG (
    MaPhong     CHAR(10)    NOT NULL,
    MaLoaiPhong CHAR(10)    NOT NULL,
    SoPhong     VARCHAR(10) NOT NULL,
    Tang        INT         NOT NULL,
    TrangThai   VARCHAR(20) NOT NULL DEFAULT 'Trong',

    CONSTRAINT PK_PHONG
        PRIMARY KEY (MaPhong),
    CONSTRAINT UQ_PHONG_SoPhong
        UNIQUE (SoPhong),
    CONSTRAINT CK_PHONG_Tang
        CHECK (Tang >= 1),
    CONSTRAINT CK_PHONG_TrangThai
        CHECK (TrangThai IN
            ('Trong', 'DaDat', 'DangSuDung', 'DangDon', 'BaoTri')),
    CONSTRAINT FK_PHONG_LOAI_PHONG
        FOREIGN KEY (MaLoaiPhong)
        REFERENCES LOAI_PHONG (MaLoaiPhong)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE PHIEU_DAT_PHONG (
    MaDatPhong   CHAR(10)      NOT NULL,
    MaKH         CHAR(10)      NOT NULL,
    MaTK         CHAR(10)      NOT NULL,
    NgayLap      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    NgayCheckIn  DATE          NOT NULL,
    NgayCheckOut DATE          NOT NULL,
    TienCoc      DECIMAL(18,2) NOT NULL DEFAULT 0,
    TrangThai    VARCHAR(20)   NOT NULL DEFAULT 'DaDat',

    CONSTRAINT PK_PHIEU_DAT_PHONG
        PRIMARY KEY (MaDatPhong),
    CONSTRAINT CK_PHIEU_DAT_PHONG_Ngay
        CHECK (NgayCheckOut > NgayCheckIn),
    CONSTRAINT CK_PHIEU_DAT_PHONG_TienCoc
        CHECK (TienCoc >= 0),
    CONSTRAINT CK_PHIEU_DAT_PHONG_TrangThai
        CHECK (TrangThai IN ('DaDat', 'DangO', 'HoanTat', 'DaHuy')),
    CONSTRAINT FK_PHIEU_DAT_PHONG_KHACH_HANG
        FOREIGN KEY (MaKH)
        REFERENCES KHACH_HANG (MaKH)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT FK_PHIEU_DAT_PHONG_TAI_KHOAN
        FOREIGN KEY (MaTK)
        REFERENCES TAI_KHOAN (MaTK)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE CHI_TIET_DAT_PHONG (
    MaDatPhong      CHAR(10)      NOT NULL,
    MaPhong         CHAR(10)      NOT NULL,
    GiaThueThoiDiem DECIMAL(18,2) NOT NULL,
    SoDem           INT           NOT NULL,
    ThanhTien       DECIMAL(18,2)
        GENERATED ALWAYS AS (GiaThueThoiDiem * SoDem) STORED,

    CONSTRAINT PK_CHI_TIET_DAT_PHONG
        PRIMARY KEY (MaDatPhong, MaPhong),
    CONSTRAINT CK_CHI_TIET_DAT_PHONG_Gia
        CHECK (GiaThueThoiDiem >= 0),
    CONSTRAINT CK_CHI_TIET_DAT_PHONG_SoDem
        CHECK (SoDem > 0),
    CONSTRAINT FK_CHI_TIET_DAT_PHONG_PHIEU_DAT_PHONG
        FOREIGN KEY (MaDatPhong)
        REFERENCES PHIEU_DAT_PHONG (MaDatPhong)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FK_CHI_TIET_DAT_PHONG_PHONG
        FOREIGN KEY (MaPhong)
        REFERENCES PHONG (MaPhong)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE DON_PHONG (
    MaDon    CHAR(10)     NOT NULL,
    MaPhong  CHAR(10)     NOT NULL,
    MaTK     CHAR(10)     NOT NULL,
    ThoiGian DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    GhiChu   VARCHAR(200),

    CONSTRAINT PK_DON_PHONG
        PRIMARY KEY (MaDon),
    CONSTRAINT FK_DON_PHONG_PHONG
        FOREIGN KEY (MaPhong)
        REFERENCES PHONG (MaPhong)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT FK_DON_PHONG_TAI_KHOAN
        FOREIGN KEY (MaTK)
        REFERENCES TAI_KHOAN (MaTK)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE SUA_PHONG (
    MaSua    CHAR(10)      NOT NULL,
    MaPhong  CHAR(10)      NOT NULL,
    MaTK     CHAR(10)      NOT NULL,
    ThoiGian DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ChiPhi   DECIMAL(18,2) NOT NULL DEFAULT 0,
    MoTaLoi  VARCHAR(200),

    CONSTRAINT PK_SUA_PHONG
        PRIMARY KEY (MaSua),
    CONSTRAINT CK_SUA_PHONG_ChiPhi
        CHECK (ChiPhi >= 0),
    CONSTRAINT FK_SUA_PHONG_PHONG
        FOREIGN KEY (MaPhong)
        REFERENCES PHONG (MaPhong)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT FK_SUA_PHONG_TAI_KHOAN
        FOREIGN KEY (MaTK)
        REFERENCES TAI_KHOAN (MaTK)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE DICH_VU (
    MaDV      CHAR(10)      NOT NULL,
    TenDV     VARCHAR(100)  NOT NULL,
    DonViTinh VARCHAR(20),
    GiaDV     DECIMAL(18,2) NOT NULL,

    CONSTRAINT PK_DICH_VU
        PRIMARY KEY (MaDV),
    CONSTRAINT UQ_DICH_VU_Ten
        UNIQUE (TenDV),
    CONSTRAINT CK_DICH_VU_Gia
        CHECK (GiaDV >= 0)
) ENGINE = InnoDB;

CREATE TABLE SU_DUNG_DICH_VU (
    MaSuDungDV     CHAR(10)      NOT NULL,
    MaDatPhong     CHAR(10)      NOT NULL,
    MaDV           CHAR(10)      NOT NULL,
    NgaySuDung     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    SoLuong        INT           NOT NULL,
    DonGiaThoiDiem DECIMAL(18,2) NOT NULL,
    ThanhTien      DECIMAL(18,2)
        GENERATED ALWAYS AS (SoLuong * DonGiaThoiDiem) STORED,

    CONSTRAINT PK_SU_DUNG_DICH_VU
        PRIMARY KEY (MaSuDungDV),
    CONSTRAINT CK_SU_DUNG_DICH_VU_SoLuong
        CHECK (SoLuong > 0),
    CONSTRAINT CK_SU_DUNG_DICH_VU_DonGia
        CHECK (DonGiaThoiDiem >= 0),
    CONSTRAINT FK_SU_DUNG_DICH_VU_PHIEU_DAT_PHONG
        FOREIGN KEY (MaDatPhong)
        REFERENCES PHIEU_DAT_PHONG (MaDatPhong)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FK_SU_DUNG_DICH_VU_DICH_VU
        FOREIGN KEY (MaDV)
        REFERENCES DICH_VU (MaDV)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

-- TongTien: so con phai thu sau khi cong PhuThu, tru GiamGia va TienCoc.
CREATE TABLE HOA_DON (
    MaHoaDon      CHAR(10)      NOT NULL,
    MaDatPhong    CHAR(10)      NOT NULL,
    NgayLap       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TongTien      DECIMAL(18,2) NOT NULL DEFAULT 0,
    LoaiThanhToan VARCHAR(20),
    TrangThai     VARCHAR(20)   NOT NULL DEFAULT 'ChuaThanhToan',

    CONSTRAINT PK_HOA_DON
        PRIMARY KEY (MaHoaDon),
    CONSTRAINT UQ_HOA_DON_MaDatPhong
        UNIQUE (MaDatPhong),
    CONSTRAINT CK_HOA_DON_TongTien
        CHECK (TongTien >= 0),
    CONSTRAINT CK_HOA_DON_LoaiThanhToan
        CHECK (
            LoaiThanhToan IS NULL
            OR LoaiThanhToan IN ('TienMat', 'ChuyenKhoan', 'The')
        ),
    CONSTRAINT CK_HOA_DON_TrangThai
        CHECK (TrangThai IN ('ChuaThanhToan', 'DaThanhToan', 'DaHuy')),
    CONSTRAINT CK_HOA_DON_ThanhToanHopLe
        CHECK (
            TrangThai <> 'DaThanhToan'
            OR LoaiThanhToan IS NOT NULL
        ),
    CONSTRAINT FK_HOA_DON_PHIEU_DAT_PHONG
        FOREIGN KEY (MaDatPhong)
        REFERENCES PHIEU_DAT_PHONG (MaDatPhong)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE CHI_TIET_HOA_DON (
    MaCTHD       CHAR(10)      NOT NULL,
    MaHoaDon     CHAR(10)      NOT NULL,
    LoaiKhoanMuc VARCHAR(20)   NOT NULL,
    SoTien       DECIMAL(18,2) NOT NULL,
    GhiChu       VARCHAR(200),

    CONSTRAINT PK_CHI_TIET_HOA_DON
        PRIMARY KEY (MaCTHD),
    CONSTRAINT CK_CHI_TIET_HOA_DON_LoaiKhoanMuc
        CHECK (LoaiKhoanMuc IN
            ('TienPhong', 'DichVu', 'PhuThu', 'GiamGia', 'GiamTru', 'TongHop')),
    CONSTRAINT CK_CHI_TIET_HOA_DON_SoTienTheoLoai
        CHECK (
            (LoaiKhoanMuc IN ('TienPhong', 'DichVu', 'PhuThu', 'TongHop')
                AND SoTien >= 0)
            OR
            (LoaiKhoanMuc IN ('GiamGia', 'GiamTru')
                AND SoTien <= 0)
        ),
    CONSTRAINT FK_CHI_TIET_HOA_DON_HOA_DON
        FOREIGN KEY (MaHoaDon)
        REFERENCES HOA_DON (MaHoaDon)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX IX_BANG_GIA_PHONG_Loai_Ngay
    ON BANG_GIA_PHONG (MaLoaiPhong, ApDungTuNgay, DenNgay);

CREATE INDEX IX_PHONG_TrangThai
    ON PHONG (TrangThai);

CREATE INDEX IX_PHIEU_DAT_PHONG_MaKH
    ON PHIEU_DAT_PHONG (MaKH);

CREATE INDEX IX_PHIEU_DAT_PHONG_Ngay
    ON PHIEU_DAT_PHONG (NgayCheckIn, NgayCheckOut);

CREATE INDEX IX_DON_PHONG_MaPhong_ThoiGian
    ON DON_PHONG (MaPhong, ThoiGian);

CREATE INDEX IX_SUA_PHONG_MaPhong_ThoiGian
    ON SUA_PHONG (MaPhong, ThoiGian);

CREATE INDEX IX_SU_DUNG_DICH_VU_MaDatPhong
    ON SU_DUNG_DICH_VU (MaDatPhong);

CREATE INDEX IX_HOA_DON_TrangThai
    ON HOA_DON (TrangThai);

CREATE INDEX IX_CHI_TIET_HOA_DON_MaHoaDon
    ON CHI_TIET_HOA_DON (MaHoaDon);

-- Mong doi: 14 bang.
SHOW TABLES;
