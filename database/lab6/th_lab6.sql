﻿CREATE DATABASE VANHOC
USE VANHOC

CREATE TABLE TACGIA
(
	MaTG CHAR(5) PRIMARY KEY,
	HoTen VARCHAR(20),
	DiaChi VARCHAR(50),
	NgSinh SMALLDATETIME,
	SODT VARCHAR(15)
)

CREATE TABLE SACH
(
	MaSach CHAR(5) PRIMARY KEY,
	TenSach VARCHAR(25),
	TheLoai VARCHAR(25)
)

CREATE TABLE TACGIA_SACH
(
	MaTG CHAR(5),
	MaSach CHAR(5)
	PRIMARY KEY (MaTG, MaSach)
)

CREATE TABLE PHATHANH
(
	MaPH CHAR(5) PRIMARY KEY,
	MaSach CHAR(5),
	NgayPH SMALLDATETIME,
	SoLuong INT,
	NhaXuatBan VARCHAR(20)
)

ALTER TABLE TACGIA_SACH
ADD CONSTRAINT FK_TG_S FOREIGN KEY (MaTG) REFERENCES TACGIA(MaTG)

ALTER TABLE TACGIA_SACH
ADD CONSTRAINT FK_S_TG FOREIGN KEY (MaSach) REFERENCES SACH(MaSach)

ALTER TABLE PHATHANH
ADD CONSTRAINT FK_S_PH FOREIGN KEY (MaSach) REFERENCES SACH(MaSach)

SET DATEFORMAT DMY
--2.1. Ngày phát hành sách phải lớn hơn ngày sinh của tác giả. (1.5 đ)
CREATE TRIGGER trg_sach ON PHATHANH
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS(SELECT *
			  FROM inserted i
			  INNER JOIN TACGIA_SACH TG_S ON i.MaSach = TG_S.MaSach
			  INNER JOIN TACGIA TG ON TG_S.MaTG = TG.MaTG
			  WHERE i.NgayPH <= TG.NgSinh)
	BEGIN
		RAISERROR('Loi', 16, 1)
		ROLLBACK TRAN
	END
END

--2.2. Sách thuộc thể loại “Giáo khoa” chỉ do nhà xuất bản “Giáo dục” phát hành
CREATE TRIGGER trg_nxb ON SACH
AFTER UPDATE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted i
			   INNER JOIN PHATHANH PH ON i.MaSach = PH.MaSach
			   WHERE TheLoai = N'Văn học'
			   AND NhaXuatBan != N'Giáo dục')
	BEGIN
		RAISERROR('Loi', 16, 1)
		ROLLBACK TRAN
	END
END

CREATE TRIGGER trg_nxb2 ON PHATHANH
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted i
			   INNER JOIN SACH ON i.MaSach = SACH.MaSach
			   WHERE TheLoai = N'Văn học'
			   AND NhaXuatBan != N'Giáo dục')
	BEGIN
		RAISERROR('Loi', 16, 1)
		ROLLBACK TRAN
	END
END
--Tìm tác giả (MaTG,HoTen,SoDT) của những quyển sách thuộc thể loại “Văn học”
--do nhà xuất bản Trẻ phát hành
	SELECT TG.MaTG, HoTen, SoDT
	FROM TACGIA TG
	INNER JOIN TACGIA_SACH TG_S ON TG.MaTG = TG_S.MaTG
	INNER JOIN PHATHANH PH ON PH.MaSach = TG_S.MaSach
	INNER JOIN SACH S ON PH.MaSach = S.MaSach
	WHERE S.TheLoai = N'Văn học'
	AND NhaXuatBan = N'Trẻ'

--Tìm nhà xuất bản phát hành nhiều thể loại sách nhất
SELECT NhaXuatBan
FROM PHATHANH PH
INNER JOIN SACH S ON PH.MaSach = S.MaSach
GROUP BY NhaXuatBan
HAVING COUNT(TheLoai) >= ALL (SELECT COUNT(TheLoai)
							  FROM PHATHANH PH1
						      INNER JOIN SACH S1 ON PH1.MaSach = S1.MaSach
							  GROUP BY NhaXuatBan)

--Trong mỗi nhà xuất bản, tìm tác giả (MaTG,HoTen) có số lần phát hành nhiều sách
--nhất
SELECT NhaXuatBan, TG.MaTG, HoTen
FROM PHATHANH PH
INNER JOIN TACGIA_SACH TG_S ON PH.MaSach = TG_S.MaSach
INNER JOIN TACGIA TG ON TG_S.MaTG = TG.MaTG
GROUP BY NhaXuatBan, TG.MaTG, HoTen
HAVING COUNT(MaPH) >= ALL (SELECT COUNT(MaPH)
						   FROM TACGIA_SACH TG_S2 
						   INNER JOIN PHATHANH PH2 ON PH2.MaSach = TG_S2.MaSach
						   WHERE PH.NhaXuatBan = PH2.NhaXuatBan
						   GROUP BY MaTG)
---------------------------------
--DE 2
CREATE DATABASE VANPHONG
USE VANPHONG

CREATE TABLE NHANVIEN
(
	MANV CHAR(5) PRIMARY KEY,
	HOTEN VARCHAR(20),
	NGAYVL SMALLDATETIME,
	HSLUONG NUMERIC(4,2),
	MAPHONG CHAR(5)
)

CREATE TABLE PHONGBAN
(
	MAPHONG CHAR(5) PRIMARY KEY,
	TENPHONG VARCHAR(25),
	TRUONGPHONG CHAR(5)
)

CREATE TABLE XE
(
	MAXE CHAR(5) PRIMARY KEY,
	LOAIXE VARCHAR(20),
	SOCHONGOI INT,
	NAMSX INT
)

CREATE TABLE PHANCONG
(
	MAPC CHAR(5) PRIMARY KEY,
	MANV CHAR(5),
	MAXE CHAR(5),
	NGAYDI SMALLDATETIME,
	NGAYVE SMALLDATETIME,
	NOIDEN VARCHAR(25)
)

ALTER TABLE NHANVIEN
ADD CONSTRAINT FK_NV_PB FOREIGN KEY (MAPHONG) REFERENCES PHONGBAN(MAPHONG)

ALTER TABLE PHONGBAN
ADD CONSTRAINT FK_PB_NV FOREIGN KEY (TRUONGPHONG) REFERENCES NHANVIEN(MANV)

ALTER TABLE PHANCONG
ADD CONSTRAINT FK_PC_NV FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV)

ALTER TABLE PHANCONG
ADD CONSTRAINT FK_PC_XE FOREIGN KEY (MAXE) REFERENCES NHANVIEN(MAXE)

ALTER TABLE XE
ADD CONSTRAINT CK_T CHECK (LOAIXE != 'Toyota' OR NamSX >= 2006)

--Nhân viên thuộc phòng lái xe “Ngoại thành” chỉ được phân công lái xe loại Toyota
CREATE TRIGGER TRG_NV1 ON NHANVIEN
AFTER UPDATE
AS
BEGIN
	IF EXISTS(SELECT 1
			  FROM inserted i
			  INNER JOIN PHANCONG PC ON i.MANV = PC.MANV
			  INNER JOIN XE ON PC.MAXE = XE.MAXE
			  INNER JOIN PHONGBAN PB ON i.MAPHONG = PB.MAPHONG
			  WHERE PB.TENPHONG = N'Ngoại thành' AND LOAIXE != 'Toyota')
	BEGIN
		RAISERROR ('LOI', 16, 1);
		ROLLBACK TRAN
	END
END

CREATE TRIGGER TRG_PB1 ON PHONGBAN
AFTER UPDATE
AS
BEGIN
	IF EXISTS(SELECT 1
			  FROM inserted i
			  INNER JOIN NHANVIEN NV ON i.MAPHONG = NV.MAPHONG
			  INNER JOIN PHANCONG PC ON NV.MANV = PC.MANV
			  INNER JOIN XE ON PC.MAXE = XE.MAXE
			  WHERE i.TENPHONG = N'Ngoại thành' AND LOAIXE != 'Toyota')
	BEGIN
		RAISERROR ('LOI', 16, 1);
		ROLLBACK TRAN
	END
END

CREATE TRIGGER TRG_PHANCONG ON PHANCONG
AFTER INSERT
AS
BEGIN
	IF EXISTS(SELECT 1
			  FROM inserted i
			  INNER JOIN NHANVIEN NV ON i.MANV = NV.MANV
			  INNER JOIN XE ON i.MAXE = XE.MAXE
			  INNER JOIN PHONGBAN PB ON PB.MAPHONG = NV.MAPHONG
			  WHERE LOAIXE != 'Toyota' AND PB.TENPHONG = N'Ngoại thành')
	BEGIN
		RAISERROR ('LOI', 16, 1)
		ROLLBACK TRAN
	END
END

CREATE TRIGGER TRG_XE ON XE
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS(SELECT 1
			  FROM inserted i
			  INNER JOIN PHANCONG PC ON i.MAXE = PC.MAXE
			  INNER JOIN NHANVIEN NV ON PC.MANV = NV.MANV
			  INNER JOIN PHONGBAN PB ON PB.MAPHONG = NV.MAPHONG
			  WHERE i.LOAIXE != 'Toyota' AND PB.TENPHONG = N'Ngoại thành')
	BEGIN
		RAISERROR('LOI', 16, 1)
		ROLLBACK TRAN
	END
END

--3.1 Tìm nhân viên (MaNV,HoTen) thuộc phòng lái xe “Nội thành” được phân công lái
--loại xe Toyota có số chỗ ngồi là 4

SELECT NV.MANV, HOTEN
FROM NHANVIEN NV
INNER JOIN PHONGBAN PB ON NV.MAPHONG = PB.MAPHONG
WHERE TENPHONG = N'Nội thành'
AND MANV IN (SELECT MANV
			 FROM PHANCONG PC
			 INNER JOIN XE ON PC.MAXE = XE.MAXE
			 WHERE XE.LOAIXE = 'Toyota'
			 AND SOCHONGOI = 4)

--3.2 Tìm nhân viên(MANV,HoTen) là trưởng phòng được phân công lái tất cả các loại
--xe. 
SELECT NV.MANV, HOTEN
FROM NHANVIEN NV
INNER JOIN PHONGBAN PB ON NV.MANV = PB.TRUONGPHONG
WHERE NOT EXISTS (SELECT *
				  FROM XE
				  WHERE NOT EXISTS(SELECT *
								   FROM PHANCONG PC
								   WHERE PC.MANV = NV.MANV
								   AND PC.MAXE = XE.MAXE))

--3.3Trong mỗi phòng ban,tìm nhân viên (MaNV,HoTen) được phân công lái ít nhất loại
--xe Toyota. 

SELECT TENPHONG, NV1.MANV, HOTEN
FROM NHANVIEN NV1
INNER JOIN PHONGBAN PB ON NV1.MAPHONG = PB.MAPHONG
INNER JOIN PHANCONG PC ON NV1.MANV = PC.MANV
INNER JOIN XE ON PC.MAXE = XE.MAXE
WHERE XE.LOAIXE = 'Toyota'
GROUP BY NV1.MAPHONG, NV1.MANV, HOTEN, TENPHONG
HAVING COUNT(MAPC) <= ALL (SELECT COUNT(MAPC)
						   FROM NHANVIEN NV2
						   INNER JOIN PHANCONG PC2 ON NV2.MANV = PC2.MANV
						   INNER JOIN XE ON PC2.MAXE = XE.MAXE
						   WHERE XE.LOAIXE = 'Toyota'
						   AND NV1.MAPHONG = NV2.MAPHONG
						   GROUP BY NV2.MANV)
						   
