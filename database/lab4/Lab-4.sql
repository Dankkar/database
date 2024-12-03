-- 76. Liệt kê top 3 chuyên gia có nhiều kỹ năng nhất và số lượng kỹ năng của họ.
	SELECT TOP 3 CG_KN.MaChuyenGia, COUNT(MaKyNang)
	FROM ChuyenGia_KyNang CG_KN 
	GROUP BY CG_KN.MaChuyenGia
	ORDER BY COUNT(MaKyNang) DESC
-- 77. Tìm các cặp chuyên gia có cùng chuyên ngành và số năm kinh nghiệm chênh lệch không quá 2 năm.
	SELECT CG1.MaChuyenGia, CG2.MaChuyenGia
	FROM ChuyenGia CG1 
	INNER JOIN ChuyenGia CG2 ON CG1.ChuyenNganh = CG2.ChuyenNganh
	WHERE CG1.MaChuyenGia > CG2.MaChuyenGia
	AND ABS(CG1.NamKinhNghiem - CG2.NamKinhNghiem) <= 2
-- 78. Hiển thị tên công ty, số lượng dự án và tổng số năm kinh nghiệm của các chuyên gia tham gia dự án của công ty đó.
	SELECT TenCongTy, COUNT(DA.MaDuAn), SUM(NamKinhNghiem)
	FROM CongTy CT
	INNER JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
	INNER JOIN ChuyenGia_DuAn CG_DA ON CG_DA.MaDuAn = DA.MaDuAn
	INNER JOIN ChuyenGia CG ON CG.MaChuyenGia = CG_DA.MaChuyenGia
	GROUP BY TenCongTy
-- 79. Tìm các chuyên gia có ít nhất một kỹ năng cấp độ 5 nhưng không có kỹ năng nào dưới cấp độ 3.
	SELECT DISTINCT MaChuyenGia
	FROM ChuyenGia_KyNang CG_KN1
	WHERE CapDo = 5 
	AND NOT EXISTS (SELECT MaChuyenGia
					FROM ChuyenGia_KyNang CG_KN2
					WHERE CapDo < 3
					AND CG_KN1.MaChuyenGia = CG_KN2.MaChuyenGia)

-- 80. Liệt kê các chuyên gia và số lượng dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào.
	SELECT CG.MaChuyenGia, COUNT(MaDuAn)
	FROM ChuyenGia CG
	LEFT JOIN ChuyenGia_DuAn CG_DA ON CG.MaChuyenGia = CG_DA.MaChuyenGia
	GROUP BY CG.MaChuyenGia

-- 81*. Tìm chuyên gia có kỹ năng ở cấp độ cao nhất trong mỗi loại kỹ năng.
	SELECT DISTINCT MaChuyenGia, LoaiKyNang, CapDo
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
	WHERE CapDo = (SELECT MAX(CapDo)
				   FROM ChuyenGia_KyNang CG_KN1
				   INNER JOIN KyNang KN1 ON CG_KN1.MaKyNang = KN1.MaKyNang
				   WHERE KN.LoaiKyNang = KN1.LoaiKyNang)
	ORDER BY LoaiKyNang, MaChuyenGia

-- 82. Tính tỷ lệ phần trăm của mỗi chuyên ngành trong tổng số chuyên gia.
	SELECT ChuyenNganh, ROUND((COUNT(MaChuyenGia) * 100.0 / (SELECT COUNT(DISTINCT MaChuyenGia) FROM ChuyenGia)),2) AS TyLePhanTram
	FROM ChuyenGia CG
	GROUP BY ChuyenNganh

-- 83. Tìm các cặp kỹ năng thường xuất hiện cùng nhau nhất trong hồ sơ của các chuyên gia.
	SELECT CG_KN1.MaKyNang, CG_KN2.MaKyNang, COUNT(CG_KN1.MaChuyenGia)
	FROM ChuyenGia_KyNang CG_KN1
	INNER JOIN ChuyenGia_KyNang CG_KN2 ON CG_KN1.MaChuyenGia = CG_KN2.MaChuyenGia
	WHERE CG_KN1.MaKyNang > CG_KN2.MaKyNang
	GROUP BY CG_KN1.MaKyNang, CG_KN2.MaKyNang
	ORDER BY COUNT(CG_KN1.MaChuyenGia) DESC

-- 84. Tính số ngày trung bình giữa ngày bắt đầu và ngày kết thúc của các dự án cho mỗi công ty.
	SELECT MaCongTy, AVG(DATEDIFF(day, NgayBatDau, NgayKetThuc)) SoNgayTrungBinh
	FROM DuAn DA
	WHERE DA.NgayKetThuc IS NOT NULL
	GROUP BY MaCongTy
-- 85*. Tìm chuyên gia có sự kết hợp độc đáo nhất của các kỹ năng (kỹ năng mà chỉ họ có).
SELECT MaChuyenGia
FROM ChuyenGia_KyNang CG_KN
GROUP BY MaChuyenGia
HAVING COUNT(DISTINCT MaKyNang) = 
       (SELECT MAX(SoLuong)
        FROM (SELECT COUNT(DISTINCT MaKyNang) AS SoLuong, MaChuyenGia
              FROM ChuyenGia_KyNang
              GROUP BY MaChuyenGia) AS SubQuery)


-- 86*. Tạo một bảng xếp hạng các chuyên gia dựa trên số lượng dự án và tổng cấp độ kỹ năng.
SELECT CG.MaChuyenGia,
       COUNT(DISTINCT CG_DA.MaDuAn) AS SoDuAn,
       SUM(CG_KN.CapDo) AS TongCapDo,
       (COUNT(DISTINCT CG_DA.MaDuAn) * 0.5 + SUM(CG_KN.CapDo) * 0.5) AS DiemXepHang
FROM ChuyenGia CG
LEFT JOIN ChuyenGia_DuAn CG_DA ON CG.MaChuyenGia = CG_DA.MaChuyenGia
LEFT JOIN ChuyenGia_KyNang CG_KN ON CG.MaChuyenGia = CG_KN.MaChuyenGia
GROUP BY CG.MaChuyenGia
ORDER BY DiemXepHang DESC


-- 87. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT DA.MaDuAn
FROM DuAn DA
INNER JOIN ChuyenGia_DuAn CG_DA ON DA.MaDuAn = CG_DA.MaDuAn
INNER JOIN ChuyenGia CG ON CG.MaChuyenGia = CG_DA.MaChuyenGia
GROUP BY DA.MaDuAn
HAVING COUNT(DISTINCT CG.ChuyenNganh) = 
       (SELECT COUNT(DISTINCT ChuyenNganh) FROM ChuyenGia)


-- 88. Tính tỷ lệ thành công của mỗi công ty dựa trên số dự án hoàn thành so với tổng số dự án.
SELECT CT.TenCongTy,
       COUNT(CASE WHEN DA.TrangThai = 'HoanThanh' THEN 1 END) * 100.0 / COUNT(*) AS TyLeThanhCong
FROM CongTy CT
INNER JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
GROUP BY CT.TenCongTy


-- 89. Tìm các chuyên gia có kỹ năng "bù trừ" nhau (một người giỏi kỹ năng A nhưng yếu kỹ năng B, người kia ngược lại).
SELECT CG_KN1.MaChuyenGia AS ChuyenGia1, CG_KN2.MaChuyenGia AS ChuyenGia2, KN1.MaKyNang AS KyNangA, KN2.MaKyNang AS KyNangB
FROM ChuyenGia_KyNang CG_KN1
INNER JOIN ChuyenGia_KyNang CG_KN2 ON CG_KN1.MaChuyenGia != CG_KN2.MaChuyenGia
INNER JOIN KyNang KN1 ON CG_KN1.MaKyNang = KN1.MaKyNang
INNER JOIN KyNang KN2 ON CG_KN2.MaKyNang = KN2.MaKyNang
WHERE CG_KN1.CapDo > 3 AND CG_KN2.CapDo < 3
AND CG_KN1.MaKyNang = KN1.MaKyNang
AND CG_KN2.MaKyNang != KN1.MaKyNang
