CREATE DATABASE DE3

USE DE3

CREATE TABLE DOCGIA (
    MaDG CHAR(5) NOT NULL CONSTRAINT PK_DG PRIMARY KEY,
    HoTen VARCHAR(30),
    NgaySinh SMALLDATETIME,
    DiaChi VARCHAR(30),
    SoDT VARCHAR(15)
);

CREATE TABLE SACH (
    MaSach CHAR(5) NOT NULL CONSTRAINT PK_SACH PRIMARY KEY,
    TenSach VARCHAR(25),
    TheLoai VARCHAR(25),
    NhaXuatBan VARCHAR(30)
);

CREATE TABLE PHIEUTHUE (
    MaPT CHAR(5) NOT NULL CONSTRAINT PK_PT PRIMARY KEY,
    MaDG CHAR(5) NOT NULL CONSTRAINT FK_PT_DG FOREIGN KEY REFERENCES DOCGIA(MaDG),
    NgayThue SMALLDATETIME,
    NgayTra SMALLDATETIME,
    SoSachThue INT
);

CREATE TABLE CHITIET_PT (
    MaPT CHAR(5) NOT NULL CONSTRAINT FK_CTPT FOREIGN KEY REFERENCES PHIEUTHUE(MaPT),
    MaSach CHAR(5) NOT NULL CONSTRAINT FK_CTMS FOREIGN KEY REFERENCES SACH(MaSach),
   PRIMARY KEY (MaPT, MaSach)
);

--2.1. Mỗi lần thuê sách, độc giả không được thuê quá 10 ngày
ALTER TABLE PHIEUTHUE
ADD CONSTRAINT CK_ThoiGianThue
CHECK (DATEDIFF(DAY, NgayThue, NgayTra) <= 10)

--2.2. Số sách thuê bằng tổng số lần thuê trong bảng chi tiết phiếu thuê
GO
CREATE TRIGGER TRG_Check_SoSachThue
ON PHIEUTHUE
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PHIEUTHUE pt
        JOIN (
            SELECT MaPT, COUNT(*) AS TongSoSach
            FROM CHITIET_PT
            GROUP BY MaPT
        ) ct ON pt.MaPT = ct.MaPT
        WHERE pt.SoSachThue <> ct.TongSoSach
    )
    BEGIN
        RAISERROR ('Số sách thuê không khớp với chi tiết phiếu thuê.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;


--3.1. Tìm độc giả (MaDG, HoTen) đã thuê sách thể loại "Tin học" trong năm 2007
SELECT DISTINCT MaDG, HoTen
FROM DOCGIA
WHERE MaDG IN (SELECT MaDG
			   FROM PHIEUTHUE pt 
					INNER JOIN CHITIET_PT ct ON pt.MaPT = ct.MaPT
					INNER JOIN SACH s ON ct.MaSach = s.MaSach
			   WHERE s.TheLoai = 'Tin học' AND YEAR(pt.NgayThue) = 2007)

-- 3.2. Tìm độc giả (MaDG, HoTen) đã thuê nhiều thể loại sách nhất
SELECT MaDG, HoTen 
FROM DOCGIA
WHERE MaDG IN (SELECT MaDG
			   FROM PHIEUTHUE pt 
					INNER JOIN CHITIET_PT ct ON pt.MaPT = ct.MaPT
					INNER JOIN SACH s ON ct.MaSach = s.MaSach
			   GROUP BY MaDG
			   HAVING COUNT(DISTINCT s.TheLoai) =  (SELECT TOP 1 COUNT(DISTINCT s.TheLoai)
													FROM PHIEUTHUE pt 
														 INNER JOIN CHITIET_PT ct ON pt.MaPT = ct.MaPT
														 INNER JOIN SACH s ON ct.MaSach = s.MaSach
													GROUP BY MaDG
													ORDER BY COUNT(DISTINCT s.TheLoai) DESC))

-- 3.3. Trong mỗi thể loại sách, tìm tên sách được thuê nhiều nhất
SELECT s1.TheLoai, s1.TenSach, COUNT(*) AS SoLanThue
FROM SACH s1, CHITIET_PT ct1
WHERE s1.MaSach = ct1.MaSach
GROUP BY s1.TheLoai, s1.TenSach
HAVING COUNT(*) >= ALL (SELECT COUNT(*) 
						FROM SACH s2, CHITIET_PT ct2
						WHERE s2.MaSach = ct2.MaSach AND s2.TheLoai = s1.TheLoai
						GROUP BY s2.MaSach)
