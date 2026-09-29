USE QuanLyKhachSan;

SET @thu_muc   = REPLACE(@@secure_file_priv, '\\', '/');
SET @thoi_diem = DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s');
SET @dinh_dang = ' CHARACTER SET utf8mb4 FIELDS TERMINATED BY '','' LINES TERMINATED BY ''\\r\\n''';

SET @tep_doanh_thu = CONCAT(@thu_muc, 'doanh_thu_theo_thang_', @thoi_diem, '.csv');
SET @tep_khach     = CONCAT(@thu_muc, 'khach_dang_luu_tru_',   @thoi_diem, '.csv');

DROP TEMPORARY TABLE IF EXISTS tmp_XuatDoanhThu, tmp_XuatKhach;

CREATE TEMPORARY TABLE tmp_XuatDoanhThu AS
SELECT 0                          AS STT,
       CONCAT(_utf8mb4 0xEFBBBF, 'Thang') AS Thang,
       'SoHoaDon'                 AS SoHoaDon,
       'DoanhThu'                 AS DoanhThu
UNION ALL
SELECT ROW_NUMBER() OVER (ORDER BY DATE_FORMAT(hd.NgayLap, '%Y-%m')),
       DATE_FORMAT(hd.NgayLap, '%Y-%m'),
       COUNT(*),
       SUM(hd.TongTien)
FROM   HOA_DON hd
WHERE  hd.TrangThai = 'DaThanhToan'
GROUP  BY DATE_FORMAT(hd.NgayLap, '%Y-%m');

CREATE TEMPORARY TABLE tmp_XuatKhach AS
SELECT 0                          AS STT,
       CONCAT(_utf8mb4 0xEFBBBF, 'HoTen') AS HoTen,
       'CCCD'                     AS CCCD,
       'SDT'                      AS SDT,
       'SoPhong'                  AS SoPhong,
       'NgayCheckIn'              AS NgayCheckIn,
       'NgayCheckOut'             AS NgayCheckOut
UNION ALL
SELECT ROW_NUMBER() OVER (ORDER BY p.SoPhong),
       kh.HoTen,
       CONCAT(REPEAT('*', GREATEST(CHAR_LENGTH(kh.CCCD) - 4, 0)), RIGHT(kh.CCCD, 4)),
       COALESCE(CONCAT(REPEAT('*', GREATEST(CHAR_LENGTH(kh.SDT) - 4, 0)), RIGHT(kh.SDT, 4)), ''),
       p.SoPhong,
       pdp.NgayCheckIn,
       pdp.NgayCheckOut
FROM   PHIEU_DAT_PHONG    pdp
JOIN   KHACH_HANG         kh ON kh.MaKH       = pdp.MaKH
JOIN   CHI_TIET_DAT_PHONG ct ON ct.MaDatPhong = pdp.MaDatPhong
JOIN   PHONG              p  ON p.MaPhong     = ct.MaPhong
WHERE  pdp.TrangThai = 'DangO';

SET @sql = CONCAT('SELECT Thang, SoHoaDon, DoanhThu FROM tmp_XuatDoanhThu ORDER BY STT',
                  ' INTO OUTFILE ', QUOTE(@tep_doanh_thu), @dinh_dang);
PREPARE lenh FROM @sql;
EXECUTE lenh;
DEALLOCATE PREPARE lenh;

SET @sql = CONCAT('SELECT HoTen, CCCD, SDT, SoPhong, NgayCheckIn, NgayCheckOut',
                  ' FROM tmp_XuatKhach ORDER BY STT',
                  ' INTO OUTFILE ', QUOTE(@tep_khach), @dinh_dang);
PREPARE lenh FROM @sql;
EXECUTE lenh;
DEALLOCATE PREPARE lenh;

DROP TEMPORARY TABLE IF EXISTS tmp_XuatDoanhThu, tmp_XuatKhach;

SELECT @tep_doanh_thu AS TepDaGhi
UNION ALL
SELECT @tep_khach;
