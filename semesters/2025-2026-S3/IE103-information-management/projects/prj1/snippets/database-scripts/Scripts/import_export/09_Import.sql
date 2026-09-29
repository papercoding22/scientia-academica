USE QuanLyKhachSan;

SET @tep = 'bang_gia_phong.csv';

INSERT INTO BANG_GIA_PHONG (MaBangGia, MaLoaiPhong, HeSo, ApDungTuNgay, DenNgay, DonGia)
SELECT TRIM(BOTH '"' FROM TRIM(d.ma)),
       TRIM(BOTH '"' FROM TRIM(d.loai)),
       TRIM(BOTH '"' FROM TRIM(d.heso)),
       TRIM(BOTH '"' FROM TRIM(d.tu)),
       TRIM(BOTH '"' FROM TRIM(d.den)),
       TRIM(BOTH '"' FROM TRIM(d.gia))
FROM   JSON_TABLE(
           CONCAT('[["',
                  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                      CONVERT(LOAD_FILE(CONCAT(@@secure_file_priv, @tep)) USING utf8mb4),
                      '\\', '\\\\'), '"', '\\"'), '\t', '\\t'), '\r', ''),
                      ',', '","'), '\n', '"],["'),
                  '"]]'),
           '$[*]' COLUMNS (SoDong FOR ORDINALITY,
                           ma   TEXT CHARACTER SET utf8mb4 PATH '$[0]',
                           loai TEXT CHARACTER SET utf8mb4 PATH '$[1]',
                           heso TEXT CHARACTER SET utf8mb4 PATH '$[2]',
                           tu   TEXT CHARACTER SET utf8mb4 PATH '$[3]',
                           den  TEXT CHARACTER SET utf8mb4 PATH '$[4]',
                           gia  TEXT CHARACTER SET utf8mb4 PATH '$[5]')) d
WHERE  d.SoDong > 1
  AND  TRIM(CONCAT_WS('', d.ma, d.loai, d.heso, d.tu, d.den, d.gia)) <> '';
