USE DU_AN_CONG_TY
-- 8. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1.	
	SELECT TenKyNang, CapDo
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
	WHERE CG_KN.MaChuyenGia = 1
-- 9. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2.
	SELECT CG.HoTen
	FROM ChuyenGia_DuAn CG_DA
	INNER JOIN ChuyenGia CG ON CG_DA.MaChuyenGia = CG.MaChuyenGia
	WHERE CG_DA.MaDuAn = 2

-- 10. Hiển thị tên công ty và tên dự án của tất cả các dự án.
	SELECT CT.TenCongTy, DA.TenDuAn
	FROM DuAn DA
	INNER JOIN CongTy CT ON DA.MaCongTy = CT.MaCongTy

-- 11. Đếm số lượng chuyên gia trong mỗi chuyên ngành.
	SELECT CG.ChuyenNganh, COUNT(MaChuyenGia) SoLuongChuyenGia
	FROM ChuyenGia CG
	GROUP BY ChuyenNganh

-- 12. Tìm chuyên gia có số năm kinh nghiệm cao nhất.
	SELECT MaChuyenGia, HoTen
	FROM ChuyenGia CG
	WHERE NamKinhNghiem = (SELECT MAX(NamKinhNghiem) FROM ChuyenGia)
-- 13. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia.
	SELECT CG.HoTen, COUNT(MaDuAn) AS SoLuongDuAn
	FROM ChuyenGia_DuAn CG_DA
	INNER JOIN ChuyenGia CG ON CG_DA.MaChuyenGia = CG.MaChuyenGia
	GROUP BY CG.HoTen
-- 14. Hiển thị tên công ty và số lượng dự án của mỗi công ty.
	SELECT CT.TenCongTy, COUNT(MaDuAn) AS SoLuongDuAn
	FROM DuAn DA
	INNER JOIN CongTy CT ON DA.MaCongTy = CT.MaCongTy
	GROUP BY CT.TenCongTy

-- 15. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất.
	SELECT TOP 1 CG_KN.MaKyNang, TenKyNang
	FROM ChuyenGia_KyNang AS CG_KN
	INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
	GROUP BY CG_KN.MaKyNang, TenKyNang
	ORDER BY COUNT(MaChuyenGia) DESC

-- 16. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên.
	SELECT HoTen
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN ChuyenGia CG ON CG_KN.MaChuyenGia = CG.MaChuyenGia
	INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
	WHERE TenKyNang = 'Python' AND CapDo >= 4

-- 17. Tìm dự án có nhiều chuyên gia tham gia nhất.
	SELECT TOP 1 CG_DA.MaDuAn, TenDuAn, COUNT(MaChuyenGia)
	FROM ChuyenGia_DuAn CG_DA
	INNER JOIN DuAn DA ON CG_DA.MaDuAn = DA.MaDuAn
	GROUP BY CG_DA.MaDuAn, DA.TenDuAn
	ORDER BY COUNT(MaChuyenGia) DESC

-- 18. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia.
	SELECT CG.HoTen, COUNT(MaKyNang) AS SoLuongKyNang
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN ChuyenGia CG ON CG_KN.MaChuyenGia = CG.MaChuyenGia
	GROUP BY CG.HoTen

-- 19. Tìm các cặp chuyên gia làm việc cùng dự án.
	SELECT CG1.HoTen AS TenChuyenGia1, CG2.HoTen AS TenChuyenGia2
	FROM ChuyenGia_DuAn CG_DA1
	JOIN ChuyenGia_DuAn CG_DA2 ON CG_DA1.MaDuAn = CG_DA2.MaDuAn
	JOIN ChuyenGia CG1 ON CG_DA1.MaChuyenGia = CG1.MaChuyenGia
	JOIN ChuyenGia CG2 ON CG_DA2.MaChuyenGia = CG2.MaChuyenGia
	WHERE CG1.MaChuyenGia < CG2.MaChuyenGia

-- 20. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ.
	SELECT CG.HoTen, COUNT(MaKyNang) AS SoLuongKyNang
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN ChuyenGia CG ON CG_KN.MaChuyenGia = CG.MaChuyenGia
	WHERE CapDo = 5
	GROUP BY CG.HoTen
	
-- 21. Tìm các công ty không có dự án nào.
	SELECT MaCongTy
	FROM CongTy
	EXCEPT
	SELECT MaCongTy
	FROM DuAn 

-- 22. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả chuyên gia không tham gia dự án nào.
	SELECT HoTen, TenDuAn
	FROM ChuyenGia_DuAn CG_DA
	LEFT JOIN ChuyenGia CG ON CG_DA.MaChuyenGia = CG.MaChuyenGia
	LEFT JOIN DuAn DA ON CG_DA.MaDuAn = DA.MaDuAn

-- 23. Tìm các chuyên gia có ít nhất 3 kỹ năng.
	SELECT CG.HoTen
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN ChuyenGia CG ON CG_KN.MaChuyenGia = CG.MaChuyenGia
	GROUP BY CG.HoTen
	HAVING COUNT(CG_KN.MaKyNang) >= 3
-- 24. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó.
	

-- 25. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python'.
	SELECT CG.HoTen
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN ChuyenGia CG ON CG_KN.MaChuyenGia = CG.MaChuyenGia
	INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
	WHERE TenKyNang = 'Java'
	EXCEPT
	SELECT CG.HoTen
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN ChuyenGia CG ON CG_KN.MaChuyenGia = CG.MaChuyenGia
	INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
	WHERE TenKyNang = 'Python'
-- 76. Tìm chuyên gia có số lượng kỹ năng nhiều nhất.
	SELECT TOP 1  CG.HoTen
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN ChuyenGia CG ON CG_KN.MaChuyenGia = CG.MaChuyenGia
	GROUP BY CG.HoTen
	ORDER BY COUNT(CG_KN.MaKyNang) DESC

-- 77. Liệt kê các cặp chuyên gia có cùng chuyên ngành.
	SELECT CG1.HoTen AS TenChuyenGia1, CG2.HoTen AS TenChuyenGia2
	FROM ChuyenGia CG1
	INNER JOIN ChuyenGia CG2 ON CG1.ChuyenNganh = CG2.ChuyenNganh
	WHERE CG1.MaChuyenGia > CG2.MaChuyenGia
-- 78. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất.
	SELECT TOP 1 CT.MaCongTy, CT.TenCongTy, SUM(CG.NamKinhNghiem) AS TongSoNamKN
	FROM ChuyenGia_DuAn CG_DA
	INNER JOIN ChuyenGia CG ON CG_DA.MaChuyenGia = CG.MaChuyenGia
	INNER JOIN DuAn DA ON CG_DA.MaDuAn = DA.MaDuAn
	INNER JOIN CongTy CT ON DA.MaCongTy = CT.MaCongTy
	GROUP BY CT.MaCongTy, CT.TenCongTy
	ORDER BY TongSoNamKN DESC

-- 79. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia.

	SELECT KN.TenKyNang
	FROM KyNang KN
	INNER JOIN ChuyenGia_KyNang CG_KN ON KN.MaKyNang = CG_KN.MaKyNang
	GROUP BY KN.TenKyNang
	HAVING COUNT(DISTINCT CG_KN.MaChuyenGia) = (SELECT COUNT(*) FROM ChuyenGia);
