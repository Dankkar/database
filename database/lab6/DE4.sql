CREATE DATABASE DE4

USE DE4

CREATE TABLE KHACHHANG (
    MaKH CHAR(5) NOT NULL CONSTRAINT PK_KH PRIMARY KEY,
    HoTen VARCHAR(30),
    DiaChi VARCHAR(30),
    SoDT VARCHAR(15),
    LoaiKH VARCHAR(10)
);

CREATE TABLE BANG_DIA (
    MaBD CHAR(5) NOT NULL CONSTRAINT PK_BD PRIMARY KEY,
    TenBD VARCHAR(25),
    TheLoai VARCHAR(25)
);

CREATE TABLE PHIEUTHUE (
    MaPT CHAR(5) NOT NULL CONSTRAINT PK_PT PRIMARY KEY,
    MaKH CHAR(5) CONSTRAINT FK_PT_KH FOREIGN KEY REFERENCES KHACHHANG(MaKH),
    NgayThue SMALLDATETIME,
    NgayTra SMALLDATETIME,
    Soluongthue INT
);

CREATE TABLE CHITIET_PM (
    MaPT CHAR(5) CONSTRAINT FK_CT_PT FOREIGN KEY REFERENCES PHIEUTHUE(MaPT),
    MaBD CHAR(5) CONSTRAINT FK_CT_BD FOREIGN KEY REFERENCES BANG_DIA(MaBD),
    CONSTRAINT PK_CTPM PRIMARY KEY (MaPT, MaBD)
);

--2.1. Thể loại băng đĩa chỉ thuộc các thể loại sau “ca nhạc”, “phim hành động”, “phim tình cảm”, “phim hoạt hình”.
ALTER TABLE BANG_DIA
ADD CONSTRAINT CK_TheLoai CHECK (TheLoai IN (N'ca nhạc', N'phim hành động', N'phim tình cảm', N'phim hoạt hình'));

--2.2. Chỉ những khách hàng thuộc loại VIP mới được thuê với số lượng băng đĩa trên 5
GO
CREATE TRIGGER trg_CheckSoluongThue_AfterInsertUpdate
ON PHIEUTHUE
AFTER INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra nếu khách hàng không phải VIP mà số lượng thuê > 5
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        INNER JOIN KHACHHANG kh ON i.MaKH = kh.MaKH
        WHERE i.Soluongthue > 5 AND kh.LoaiKH <> 'VIP'
    )
    BEGIN
        -- Báo lỗi nếu vi phạm
        RAISERROR ('Chỉ khách hàng loại VIP mới được thuê với số lượng băng đĩa trên 5.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

GO
CREATE TRIGGER trg_CheckLoaiKH_AfterUpdate
ON KHACHHANG
AFTER UPDATE
AS
BEGIN
    -- Kiểm tra nếu thay đổi loại khách hàng và có phiếu thuê với số lượng > 5
    IF EXISTS (
        SELECT 1
        FROM PHIEUTHUE pt
        INNER JOIN INSERTED i ON pt.MaKH = i.MaKH
        WHERE i.LoaiKH <> 'VIP' AND pt.Soluongthue > 5
    )
    BEGIN
        -- Báo lỗi nếu vi phạm
        RAISERROR ('Khách hàng có phiếu thuê với số lượng băng đĩa trên 5 phải là VIP.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--3.1. Tìm các khách hàng (MaDG,HoTen) đã thuê băng đĩa thuộc thể loại phim “Tình cảm” có số lượng thuê lớn hơn 3
SELECT DISTINCT KH.MaKH, KH.HoTen
FROM KHACHHANG KH
	 INNER JOIN PHIEUTHUE PT ON KH.MaKH = PT.MaKH
	 INNER JOIN CHITIET_PM CT ON PT.MaPT = CT.MaPT
	 INNER JOIN BANG_DIA BD ON CT.MaBD = BD.MaBD
WHERE BD.TheLoai = N'phim tình cảm' AND PT.Soluongthue > 3;

--3.2. Tìm các khách hàng(MaDG,HoTen) thuộc loại VIP đã thuê nhiều băng đĩa nhất
SELECT KH.MaKH, KH.HoTen
FROM KHACHHANG KH
	 INNER JOIN PHIEUTHUE PT ON KH.MaKH = PT.MaKH
WHERE KH.LoaiKH = 'VIP'
GROUP BY KH.MaKH, KH.HoTen
HAVING SUM(Soluongthue) = (SELECT SUM(Soluongthue)
						   FROM KHACHHANG KH
								INNER JOIN PHIEUTHUE PT ON KH.MaKH = PT.MaKH
						   WHERE KH.LoaiKH = 'VIP'
						   GROUP BY KH.MaKH, KH.HoTen
						   ORDER BY SUM(Soluongthue) DESC)

--3.3 Trong mỗi thể loại băng đĩa, cho biết tên khách hàng nào đã thuê nhiều băng đĩa nhất. 
SELECT TheLoai, HoTen
FROM KHACHHANG kh,
(SELECT bd1.TheLoai, pt1.MaKH
 FROM BANG_DIA bd1, PHIEUTHUE pt1, CHITIET_PM ct1
 WHERE bd1.MaBD = ct1.MaBD AND ct1.MaPT = pt1.MaPT
 GROUP BY bd1.TheLoai, pt1.MaKH
 HAVING COUNT(*) >= ALL (SELECT COUNT(*)
						 FROM BANG_DIA bD2, PHIEUTHUE pt2, CHITIET_PM ct2
						 WHERE bd2.MaBD = ct2.MaBD AND ct2.MaPT = pt2.MaPT AND bd2.TheLoai = bd1.TheLoai
						 GROUP BY pt2.MaKH)) AS THONGKE
WHERE kh.MaKH = THONGKE.MaKH