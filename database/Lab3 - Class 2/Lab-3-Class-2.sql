-- 1. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1, đồng thời lọc ra những kỹ năng có cấp độ thấp hơn 3.
	SELECT TenKyNang, CapDo
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
	WHERE MaChuyenGia = 1 AND CapDo < 3

-- 2. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2 và có ít nhất 2 kỹ năng khác nhau.
	SELECT HoTen
	FROM ChuyenGia CG
	INNER JOIN ChuyenGia_DuAn CG_DA ON CG.MaChuyenGia = CG_DA.MaChuyenGia
	INNER JOIN ChuyenGia_KyNang CG_KN ON CG.MaChuyenGia = CG_KN.MaChuyenGia
	WHERE MaDuAn = 2
	GROUP BY HoTen
	HAVING COUNT(DISTINCT MaKyNang) >= 2
-- 3. Hiển thị tên công ty và tên dự án của tất cả các dự án, sắp xếp theo tên công ty và số lượng chuyên gia tham gia dự án.
	SELECT TenCongTy, TenDuAn
	FROM DuAn DA
	INNER JOIN CongTy CT ON DA.MaCongTy = CT.MaCongTy
	INNER JOIN ChuyenGia_DuAn CG_DA ON CG_DA.MaDuAn = DA.MaDuAn
	GROUP BY TenCongTy, TenDuAn
	ORDER BY TenCongTy, COUNT(MaChuyenGia)
-- 4. Đếm số lượng chuyên gia trong mỗi chuyên ngành và hiển thị chỉ những chuyên ngành có hơn 5 chuyên gia.
	SELECT CG.ChuyenNganh, COUNT(DISTINCT CG_DA.MaChuyenGia) AS SoLuongChuyenGia
	FROM ChuyenGia_DuAn CG_DA
	INNER JOIN ChuyenGia CG ON CG_DA.MaChuyenGia = CG.MaChuyenGia
	GROUP BY CG.ChuyenNganh
	HAVING COUNT(DISTINCT CG_DA.MaChuyenGia) > 5;
-- 5. Tìm chuyên gia có số năm kinh nghiệm cao nhất và hiển thị cả danh sách kỹ năng của họ.
	SELECT CG.MaChuyenGia, MaKyNang
	FROM ChuyenGia CG
	INNER JOIN ChuyenGia_KyNang CG_KN ON CG.MaChuyenGia = CG_KN.MaChuyenGia
	WHERE NamKinhNghiem >= ALL (SELECT NamKinhNghiem
								FROM ChuyenGia
								)
-- 6. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia, đồng thời tính toán tỷ lệ phần trăm so với tổng số dự án trong hệ thống.
	SELECT CG.HoTen,
	COUNT(MaDuAn) AS SoLuongDuAnThamGia,
	ROUND((COUNT(DISTINCT MaDuAn) * 100.0 / (SELECT COUNT(DISTINCT MaDuAn) FROM DuAn)),2) TiLe
	FROM ChuyenGia CG
	LEFT JOIN ChuyenGia_DuAn CG_DA ON CG.MaChuyenGia = CG_DA.MaChuyenGia
	GROUP BY CG.HoTen
-- 7. Hiển thị tên công ty và số lượng dự án của mỗi công ty, bao gồm cả những công ty không có dự án nào.
	SELECT TenCongTy, COUNT(MaDuAn)
	FROM CongTy CT
	LEFT JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
	GROUP BY TenCongTy
-- 8. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất, đồng thời hiển thị số lượng chuyên gia sở hữu kỹ năng đó.
	SELECT MaKyNang, COUNT(MaChuyenGia)
	FROM ChuyenGia_KyNang
	GROUP BY MaKyNang
	HAVING COUNT(MaChuyenGia) >= ALL (SELECT COUNT(MaChuyenGia) 
									  FROM ChuyenGia_KyNang
									  GROUP BY MaKyNang)
-- 9. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên, đồng thời tìm kiếm những người cũng có kỹ năng 'Java'.
	SELECT DISTINCT HoTen
	FROM ChuyenGia CG
	WHERE MaChuyenGia = (SELECT MaChuyenGia
						 FROM ChuyenGia_KyNang CG_KN
						 INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
						 WHERE TenKyNang = 'Python' AND CapDo = 4
						 INTERSECT
						 SELECT MaChuyenGia
						 FROM ChuyenGia_KyNang CG_KN
						 INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
						 WHERE TenKyNang = 'Java'
						 )
-- 10. Tìm dự án có nhiều chuyên gia tham gia nhất và hiển thị danh sách tên các chuyên gia tham gia vào dự án đó.
	SELECT MaDuAn, HoTen
	FROM ChuyenGia_DuAn CG_DA
	INNER JOIN ChuyenGia CG ON CG_DA.MaChuyenGia = CG.MaChuyenGia
	WHERE CG_DA.MaDuAn IN (
		SELECT MaDuAn
		FROM ChuyenGia_DuAn
		GROUP BY MaDuAn
		HAVING COUNT(MaChuyenGia) = (
									 SELECT MAX(NumExperts)
									 FROM (
											SELECT COUNT(MaChuyenGia) AS NumExperts
											FROM ChuyenGia_DuAn
											GROUP BY MaDuAn
										  ) AS MaxExperts
									)
							)
	
-- 11. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia, đồng thời lọc ra những người có ít nhất 5 kỹ năng.
	SELECT HoTen, COUNT(MaKyNang) SoLuongKyNang
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN ChuyenGia CG on CG_KN.MaChuyenGia = CG.MaChuyenGia
	GROUP BY HoTen
	HAVING COUNT(MaKyNang) >= 5
-- 12. Tìm các cặp chuyên gia làm việc cùng dự án và hiển thị thông tin về số năm kinh nghiệm của từng cặp.
	SELECT CG_DA1.MaChuyenGia AS MaChuyenGia1, CG1.NamKinhNghiem AS NamKinhNghiemCG1, CG_DA2.MaChuyenGia AS MaChuyenGia2, CG2.NamKinhNghiem AS NamKinhNghiemCG2
	FROM ChuyenGia_DuAn CG_DA1
	INNER JOIN ChuyenGia_DuAn CG_DA2 ON CG_DA1.MaDuAn = CG_DA2.MaDuAn
	INNER JOIN ChuyenGia CG1 ON CG_DA1.MaChuyenGia = CG1.MaChuyenGia
	INNER JOIN ChuyenGia CG2 ON CG_DA2.MaChuyenGia = CG2.MaChuyenGia
	WHERE CG_DA1.MaChuyenGia > CG_DA2.MaChuyenGia
-- 13. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ, đồng thời tính toán tỷ lệ phần trăm so với tổng số kỹ năng mà họ sở hữu.
	SELECT HoTen, COUNT(MaKyNang), 
				  (SELECT COUNT(MaKyNang)
				   FROM ChuyenGia_KyNang CG_KN1
				   WHERE CG_KN.MaChuyenGia = CG_KN1.MaChuyenGia
				   ) AS Tong
	FROM ChuyenGia_KyNang CG_KN 
	INNER JOIN ChuyenGia CG ON CG_KN.MaChuyenGia = CG.MaChuyenGia
	

-- 14. Tìm các công ty không có dự án nào và hiển thị cả thông tin về số lượng nhân viên trong mỗi công ty đó.
	SELECT MaCongTy, SoNhanVien
	FROM CongTy
	WHERE MaCongTy NOT IN (SELECT DISTINCT MaCongTy
						   FROM DuAn)
-- 15. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào, sắp xếp theo tên chuyên gia.
	SELECT HoTen, TenDuAn
	FROM ChuyenGia CG
	LEFT JOIN ChuyenGia_DuAn CG_DA ON CG.MaChuyenGia = CG_DA.MaChuyenGia
	LEFT JOIN DuAn DA ON CG_DA.MaDuAn = DA.MaDuAn
	ORDER BY HoTen
-- 16. Tìm các chuyên gia có ít nhất 3 kỹ năng, đồng thời lọc ra những người không có bất kỳ kỹ năng nào ở cấp độ cao hơn 3.
	SELECT MaChuyenGia
	FROM ChuyenGia_KyNang CG_KN
	GROUP BY MaChuyenGia
	HAVING COUNT(MaKyNang) >= 3
	AND MAX(CapDo) <= 3
-- 17. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó, chỉ hiển thị những công ty có tổng số năm kinh nghiệm lớn hơn 10 năm.
	SELECT TenCongTy, SUM(NamKinhNghiem) TongSoNam
	FROM CongTy CT
	INNER JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
	INNER JOIN ChuyenGia_DuAn CG_DA ON DA.MaDuAn = CG_DA.MaDuAn
	INNER JOIN ChuyenGia CG ON CG_DA.MaChuyenGia = CG.MaChuyenGia
	GROUP BY TenCongTy
	HAVING SUM(NamKinhNghiem) > 10

	SELECT CT.TenCongTy,
       (SELECT SUM(CG.NamKinhNghiem)
        FROM DuAn DA
        INNER JOIN ChuyenGia_DuAn CG_DA ON DA.MaDuAn = CG_DA.MaDuAn
        INNER JOIN ChuyenGia CG ON CG_DA.MaChuyenGia = CG.MaChuyenGia
        WHERE DA.MaCongTy = CT.MaCongTy) AS TongNamKinhNghiem
FROM CongTy CT
WHERE (SELECT SUM(CG.NamKinhNghiem)
       FROM DuAn DA
       INNER JOIN ChuyenGia_DuAn CG_DA ON DA.MaDuAn = CG_DA.MaDuAn
       INNER JOIN ChuyenGia CG ON CG_DA.MaChuyenGia = CG.MaChuyenGia
       WHERE DA.MaCongTy = CT.MaCongTy) > 10;
-- 18. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python', đồng thời hiển thị danh sách các dự án mà họ đã tham gia.
	SELECT CG_KN.MaChuyenGia, MaDuAn
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
	INNER JOIN ChuyenGia_DuAn CG_DA ON CG_KN.MaChuyenGia = CG_DA.MaChuyenGia
	WHERE TenKyNang = 'Java'
	AND CG_DA.MaChuyenGia NOT IN (SELECT MaChuyenGia
								  FROM ChuyenGia_KyNang 
								  INNER JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
								  WHERE TenKyNang = 'Python')
-- 19. Tìm chuyên gia có số lượng kỹ năng nhiều nhất và hiển thị cả danh sách các dự án mà họ đã tham gia.
	SELECT DISTINCT CG_KN.MaChuyenGia, MaDuAn
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN ChuyenGia_DuAn CG_DA ON CG_KN.MaChuyenGia = CG_DA.MaChuyenGia
	WHERE CG_KN.MaChuyenGia IN (SELECT MaChuyenGia
								FROM ChuyenGia_KyNang
								GROUP BY MaChuyenGia
								HAVING COUNT(MaKyNang) >= ALL (SELECT COUNT(MaKyNang)
															   FROM ChuyenGia_KyNang
															   GROUP BY MaChuyenGia))


-- 20. Liệt kê các cặp chuyên gia có cùng chuyên ngành và hiển thị thông tin về số năm kinh nghiệm của từng người trong cặp đó.
	SELECT CG1.MaChuyenGia, CG2.MaChuyenGia, CG1.NamKinhNghiem, CG2.NamKinhNghiem
	FROM ChuyenGia CG1
	INNER JOIN ChuyenGia CG2 ON CG1.ChuyenNganh = CG2.ChuyenNganh
	WHERE CG1.MaChuyenGia > CG2.MaChuyenGia
-- 21. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất và hiển thị danh sách tất cả các dự án mà công ty đó đã thực hiện.
	SELECT MaCongTy, DA.MaDuAn, DA.TenDuAn
	FROM DuAn DA
	INNER JOIN ChuyenGia_DuAn CG_DA ON CG_DA.MaDuAn = DA.MaDuAn
	INNER JOIN ChuyenGia CG ON CG_DA.MaChuyenGia = CG.MaChuyenGia
	GROUP BY MaCongTy,DA.MaDuAn, DA.TenDuAn
	HAVING SUM(NamKinhNghiem) >= ALL (SELECT SUM(NamKinhNghiem)
									  FROM ChuyenGia CG
									  INNER JOIN ChuyenGia_DuAn CG_DA ON CG.MaChuyenGia = CG_DA.MaChuyenGia
									  INNER JOIN DuAn DA ON CG_DA.MaDuAn = DA.MaDuAn
									  GROUP BY MaCongTy
									 )
-- 22. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia và hiển thị danh sách chi tiết về từng chuyên gia sở hữu kỹ năng đó cùng với cấp độ của họ.
	SELECT MaKyNang, MaChuyenGia, CapDo
	FROM ChuyenGia_KyNang CG_KN
	WHERE MaKyNang IN (SELECT MaKyNang
					   FROM ChuyenGia_KyNang
					   GROUP BY MaKyNang
					   HAVING COUNT(DISTINCT MaChuyenGia) = (SELECT COUNT(DISTINCT MaChuyenGia)
															 FROM ChuyenGia
						))
--23. Tìm tất cả các chuyên gia có ít nhất 2 kỹ năng thuộc cùng một lĩnh vực và hiển thị tên chuyên gia cùng với tên lĩnh vực đó.
	SELECT DISTINCT CG.HoTen, KN.LoaiKyNang
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN ChuyenGia CG ON CG_KN.MaChuyenGia = CG.MaChuyenGia
	INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
	WHERE CG.MaChuyenGia IN (SELECT MaChuyenGia
							 FROM ChuyenGia_KyNang 
							 INNER JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
							 GROUP BY MaChuyenGia, KyNang.LoaiKyNang
							 HAVING COUNT(DISTINCT ChuyenGia_KyNang.MaKyNang) >=2
							 );

--24. Hiển thị tên các dự án và số lượng chuyên gia tham gia cho mỗi dự án, chỉ hiển thị những dự án có hơn 3 chuyên gia tham gia.
	SELECT TenDuAn, COUNT(MaChuyenGia) AS SoLuongChuyenGia
	FROM DuAn DA 
	INNER JOIN ChuyenGia_DuAn CG_DA ON DA.MaDuAn = CG_DA.MaDuAn
	GROUP BY TenDuAn
	HAVING COUNT(MaChuyenGia) > 3
	
--25.Tìm công ty có số lượng dự án lớn nhất và hiển thị tên công ty cùng với số lượng dự án.
	SELECT TenCongTy, COUNT(MaDuAn) AS SoLuongDuAn
	FROM DuAn DA
	INNER JOIN CongTy CT ON DA.MaCongTy = CT.MaCongTy
	GROUP BY TenCongTy
	HAVING COUNT(MaDuAn) >= ALL (SELECT COUNT(MaDuAn)
								 FROM DuAn
								 GROUP BY MaCongTy)

--26. Liệt kê tên các chuyên gia có kinh nghiệm từ 5 năm trở lên và có ít nhất 4 kỹ năng khác nhau.
	SELECT HoTen
	FROM ChuyenGia CG
	INNER JOIN ChuyenGia_KyNang CG_KN ON CG.MaChuyenGia = CG_KN.MaChuyenGia
	WHERE NamKinhNghiem >=5
	GROUP BY HoTen
	HAVING COUNT(DISTINCT MaKyNang) >= 4
					

--27. Tìm tất cả các kỹ năng mà không có chuyên gia nào sở hữu.
	SELECT MaKyNang
	FROM KyNang KN
	WHERE NOT EXISTS (SELECT Distinct MaKyNang
					  FROM ChuyenGia_KyNang CG_KN
					  WHERE CG_KN.MaKyNang = KN.MaKyNang)					

--28. Hiển thị tên chuyên gia và số năm kinh nghiệm của họ, sắp xếp theo số năm kinh nghiệm giảm dần.
	SELECT HoTen, NamKinhNghiem
	FROM ChuyenGia
	ORDER BY NamKinhNghiem DESC

--29. Tìm tất cả các cặp chuyên gia có ít nhất 2 kỹ năng giống nhau.
	SELECT CG_KN1.MaChuyenGia, CG_KN2.MaChuyenGia
	FROM ChuyenGia_KyNang CG_KN1
	INNER JOIN ChuyenGia_KyNang CG_KN2 ON CG_KN1.MaKyNang = CG_KN2.MaKyNang
	WHERE CG_KN1.MaChuyenGia > CG_KN2.MaChuyenGia
	GROUP BY CG_KN1.MaChuyenGia, CG_KN2.MaChuyenGia
	HAVING COUNT(CG_KN1.MaKyNang) >=2

--30. Tìm các công ty có ít nhất một chuyên gia nhưng không có dự án nào.
	
--31. Liệt kê tên các chuyên gia cùng với số lượng kỹ năng cấp độ cao nhất mà họ sở hữu.
	SELECT HoTen,  COUNT(CG_KN.MaKyNang) AS SoLuongKyNangCapCaoNhat
	FROM ChuyenGia CG
	INNER JOIN ChuyenGia_KyNang CG_KN ON CG.MaChuyenGia = CG_KN.MaChuyenGia
	WHERE CG_KN.CapDo = (SELECT MAX(CapDo)
						 FROM ChuyenGia_KyNang
						 WHERE ChuyenGia_KyNang.MaChuyenGia = CG.MaChuyenGia
						)
	GROUP BY HoTen

--32. Tìm dự án mà tất cả các chuyên gia đều tham gia và hiển thị tên dự án cùng với danh sách tên chuyên gia tham gia.
	SELECT MaDuAn
	FROM DuAn DA
	WHERE NOT EXISTS (SELECT MaChuyenGia
					  FROM ChuyenGia CG
					  WHERE NOT EXISTS (SELECT MaDuAn
										FROM ChuyenGia_DuAn CG_DA
										WHERE CG_DA.MaDuAn = DA.MaDuAn AND CG_DA.MaChuyenGia = CG.MaChuyenGia
										)
										)

--33. Tìm tất cả các kỹ năng mà ít nhất một chuyên gia sở hữu nhưng không thuộc về nhóm kỹ năng 'Python' hoặc 'Java'.
	SELECT DISTINCT CG_KN.MaKyNang
	FROM ChuyenGia_KyNang CG_KN
	INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
	WHERE NOT EXISTS (SELECT MaKyNang	
					  FROM KyNang KN1
					  WHERE (TenKyNang IN ('Python', 'Java') AND KN1.MaKyNang = CG_KN.MaKyNang))
