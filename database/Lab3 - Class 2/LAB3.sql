--Lab 3 - Class 2

--1. Tim cac so hoa don da mua san pham co ma so "BB01" hoac "BB02", moi san pham mua voi so luong tu 10 den 20, va tong gia tri hoa don lon hon 500000.
	SELECT DISTINCT HD.SOHD
	FROM CTHD
	INNER JOIN HOADON HD ON HD.SOHD = CTHD.SOHD
	WHERE CTHD.MASP IN ('BB01', 'BB02')
	AND CTHD.SL BETWEEN 10 AND 20
	AND TRIGIA > 500000
--2. Tìm các số hóa đơn mua cùng lúc 3 sản phẩm có mã số “BB01”, “BB02” và “BB03”, mỗi sản phẩm mua với số lượng từ 10 đến 20, và ngày mua hàng trong năm 2023. 
	SELECT DISTINCT HD.SOHD
	FROM CTHD
	INNER JOIN HOADON HD ON HD.SOHD = CTHD.SOHD
	WHERE CTHD.MASP IN ('BB01', 'BB02', 'BB03')
	AND CTHD.SL BETWEEN 10 AND 20
	AND YEAR(NGHD) = 2023
	GROUP BY HD.SOHD
	HAVING COUNT(DISTINCT MASP) = 3
--3. Tìm các khách hàng đã mua ít nhất một sản phẩm có mã số “BB01” với số lượng từ 10 đến 20, và tổng trị giá tất cả các hóa đơn của họ lớn hơn hoặc bằng 1 triệu đồng. 
	SELECT KHACHHANG.MAKH
	FROM KHACHHANG
	INNER JOIN HOADON ON KHACHHANG.MAKH = HOADON.MAKH
	INNER JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
	WHERE MASP = 'BB01'
	AND CTHD.SL BETWEEN 10 AND 20
	GROUP BY KHACHHANG.MAKH
	HAVING SUM(TRIGIA) >= 1000000
--4. Tìm các nhân viên bán hàng đã thực hiện giao dịch bán ít nhất một sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm bán với số lượng từ 15 trở lên, và tổng trị giá của tất cả các hóa đơn mà nhân viên đó xử lý lớn hơn hoặc bằng 2 triệu đồng. 
	SELECT DISTINCT MANV
	FROM HOADON HD
	INNER JOIN CTHD ON HD.SOHD = CTHD.SOHD
	WHERE MASP IN ('BB01', 'BB02')
	AND CTHD.SL >= 15
	GROUP BY MANV
	HAVING SUM(TRIGIA) >= 2000000
--5. Tìm các khách hàng đã mua ít nhất hai loại sản phẩm khác nhau với tổng số lượng từ tất cả các hóa đơn của họ lớn hơn hoặc bằng 50 và tổng trị giá của họ lớn hơn hoặc bằng 5 triệu đồng. 
	SELECT HD.MAKH
	FROM HOADON HD
	INNER JOIN CTHD ON HD.SOHD = CTHD.SOHD
	GROUP BY HD.MAKH
	HAVING COUNT(DISTINCT MASP) >= 2
	AND SUM(CTHD.SL) >= 50
	AND SUM(HD.TRIGIA) >= 5000000
--6. Tìm những khách hàng đã mua cùng lúc ít nhất ba sản phẩm khác nhau trong cùng một hóa đơn và mỗi sản phẩm đều có số lượng từ 5 trở lên.
	SELECT MAKH, HD.SOHD
	FROM HOADON HD
	INNER JOIN CTHD ON HD.SOHD = CTHD.SOHD
	WHERE CTHD.SL >= 5
	GROUP BY MAKH, HD.SOHD
	HAVING COUNT(DISTINCT MASP) >= 3

--7. Tìm các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất và đã được bán ra ít nhất 5 lần trong năm 2007
	SELECT SP.MASP, TENSP
	FROM SANPHAM SP
	INNER JOIN CTHD ON SP.MASP = CTHD.MASP 
	INNER JOIN HOADON HD ON CTHD.SOHD = HD.SOHD
	WHERE NUOCSX = 'Trung Quoc' 
	AND YEAR(NGHD) = 2007
	GROUP BY SP.MASP, TENSP
	HAVING COUNT(CTHD.SOHD) >= 5
	
--8. Tìm các khách hàng đã mua ít nhất một sản phẩm do “Singapore” sản xuất trong năm 2006 và tổng trị giá hóa đơn của họ trong năm đó lớn hơn 1 triệu đồng.
	SELECT MAKH
	FROM HOADON HD
	INNER JOIN CTHD ON HD.SOHD = CTHD.SOHD
	INNER JOIN SANPHAM SP ON CTHD.MASP = SP.MASP
	WHERE NUOCSX = 'Singapore'
	AND YEAR(NGHD) = 2006
	GROUP BY MAKH
	HAVING SUM(TRIGIA) > 1000000
--9. Tìm những nhân viên bán hàng đã thực hiện giao dịch bán nhiều nhất các sản phẩm do “Trung Quoc” sản xuất trong năm 2006.
	SELECT MANV
	FROM HOADON HD
	INNER JOIN CTHD ON HD.SOHD = CTHD.SOHD
	INNER JOIN SANPHAM SP ON CTHD.MASP = SP.MASP
	WHERE NUOCSX = 'Trung Quoc'
	AND YEAR(NGHD) = 2006
	GROUP BY MANV
	HAVING SUM(CTHD.SL) >= ALL (SELECT SUM(CTHD1.SL)
									FROM HOADON HD1
									INNER JOIN CTHD CTHD1 ON HD1.SOHD = CTHD1.SOHD
									INNER JOIN SANPHAM SP1 ON CTHD1.MASP = SP1.MASP
									WHERE NUOCSX = 'Trung Quoc'
									AND YEAR(NGHD) = 2006
									GROUP BY HD1.MANV)
--10. Tìm những khách hàng chưa từng mua bất kỳ sản phẩm nào do “Singapore” sản xuất nhưng đã mua ít nhất một sản phẩm do “Trung Quoc” sản xuất.
	SELECT DISTINCT MAKH
	FROM KHACHHANG KH
	WHERE EXISTS (SELECT MAKH
				  FROM HOADON HD
				  INNER JOIN CTHD ON HD.SOHD = CTHD.SOHD
				  INNER JOIN SANPHAM SP ON CTHD.MASP = SP.MASP
				  WHERE HD.MAKH = KH.MAKH
				  AND NUOCSX = 'Trung Quoc'
				  )
	AND NOT EXISTS (SELECT MAKH
				  FROM HOADON HD
				  INNER JOIN CTHD ON HD.SOHD = CTHD.SOHD
				  INNER JOIN SANPHAM SP ON CTHD.MASP = SP.MASP
				  WHERE HD.MAKH = KH.MAKH
				  AND NUOCSX = 'Singapore'
				  )
--11. Tìm những hóa đơn có chứa tất cả các sản phẩm do “Singapore” sản xuất và trị giá hóa đơn lớn hơn tổng trị giá trung bình của tất cả các hóa đơn trong hệ thống.
	SELECT SOHD
	FROM HOADON HD
	WHERE NOT EXISTS (SELECT SP.MASP
					  FROM SANPHAM SP
					  WHERE NUOCSX = 'Singapore'
					  AND NOT EXISTS (SELECT SOHD
									  FROM CTHD
									  WHERE CTHD.SOHD = HD.SOHD
									  AND CTHD.MASP = SP.MASP
									  )
					  )
	AND HD.TRIGIA > (SELECT AVG(TRIGIA) FROM HOADON);
--12. Tìm danh sách các nhân viên có tổng số lượng bán ra của tất cả các loại sản phẩm vượt quá số lượng trung bình của tất cả các nhân viên khác.
SELECT MANV
FROM HOADON HD
INNER JOIN CTHD ON HD.SOHD = CTHD.SOHD
GROUP BY MANV
HAVING SUM(CTHD.SL) > (SELECT AVG(SUM_SL)
                        FROM (SELECT SUM(CTHD.SL) AS SUM_SL
                              FROM HOADON HD1
                              INNER JOIN CTHD CTHD1 ON HD1.SOHD = CTHD1.SOHD
                              GROUP BY HD1.MANV) AS AVG_SUM_TABLE);
--13. Tìm danh sách các hóa đơn có chứa ít nhất một sản phẩm từ mỗi nước sản xuất khác nhau có trong hệ thống.
	SELECT HD.SOHD
	FROM HOADON HD
	INNER JOIN CTHD ON HD.SOHD = CTHD.SOHD
	INNER JOIN SANPHAM SP ON CTHD.MASP = SP.MASP
	GROUP BY HD.SOHD
	HAVING COUNT(DISTINCT SP.NUOCSX) = (SELECT COUNT(DISTINCT NUOCSX)
										FROM SANPHAM
										)
-------------------------
USE QUANLYGIAOVU
--1. Tìm danh sách các giáo viên có mức lương cao nhất trong mỗi khoa, kèm theo tên khoa và hệ số lương.
	SELECT GV.MAGV, K.TENKHOA, GV.HESO
	FROM GIAOVIEN GV
	INNER JOIN KHOA K ON GV.MAKHOA = K.MAKHOA
	WHERE MUCLUONG >= ALL (SELECT MUCLUONG
							FROM GIAOVIEN
							WHERE GIAOVIEN.MAKHOA = GV.MAKHOA)
--2. Liệt kê danh sách các học viên có điểm trung bình cao nhất trong mỗi lớp, kèm theo tên lớp và mã lớp. 
	SELECT HV.MAHV, L.TENLOP, HV.MALOP
	FROM HOCVIEN HV
	INNER JOIN LOP L ON HV.MALOP = L.MALOP
	WHERE HV.DIEMTB = (SELECT MAX(DIEMTB)
							FROM HOCVIEN HV1
							WHERE HV.MALOP = HV1.MALOP
							)
--3. Tính tổng số tiết lý thuyết (TCLT) và thực hành (TCTH) mà mỗi giáo viên đã giảng dạy trong năm học 2023, sắp xếp theo tổng số tiết từ cao xuống thấp. 
	SELECT GV.MAGV, SUM(TCLT), SUM(TCTH)
	FROM GIAOVIEN GV
	INNER JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
	INNER JOIN MONHOC MH ON GD.MAMH = MH.MAMH
	WHERE GD.NAM = 2023
	GROUP BY GV.MAGV
	ORDER BY (SUM(TCLT) + SUM(TCTH)) DESC
--4. Tìm những học viên thi cùng một môn học nhiều hơn 2 lần nhưng chưa bao giờ đạt điểm trên 7, kèm theo mã học viên và mã môn học. 
	SELECT DISTINCT HV.MAHV, KQT.MAMH
	FROM HOCVIEN HV
	INNER JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
	WHERE KQT.MAMH IN (SELECT MAMH
					   FROM KETQUATHI
					   WHERE KQT.MAHV = KETQUATHI.MAHV
					   GROUP BY KETQUATHI.MAMH
					   HAVING COUNT(*) >= 2
					   )
	AND NOT EXISTS (SELECT DIEM 
					  FROM KETQUATHI KQT1
					  WHERE DIEM >7
					  AND KQT1.MAHV = HV.MAHV
					  AND KQT1.MAMH = KQT.MAMH
					  )

--5. Xác định những giáo viên đã giảng dạy ít nhất 3 môn học khác nhau trong cùng một năm học, kèm theo năm học và số lượng môn giảng dạy. 
	SELECT GV.MAGV, NAM, COUNT(DISTINCT MAMH)
	FROM GIAOVIEN GV
	INNER JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
	GROUP BY GV.MAGV, NAM
	HAVING COUNT(DISTINCT MAMH) >= 3
--6. Tìm những học viên có sinh nhật trùng với ngày thành lập của khoa mà họ đang theo học, kèm theo tên khoa và ngày sinh của học viên. 

--7. Liệt kê các môn học không có điều kiện tiên quyết (không yêu cầu môn học trước), kèm theo mã môn và tên môn học. 
	SELECT MH.MAMH, MH.TENMH
	FROM MONHOC MH
	LEFT JOIN DIEUKIEN DK ON MH.MAMH = DK.MAMH
	WHERE MAMH_TRUOC IS NULL
--8. Tìm danh sách các giáo viên dạy nhiều môn học nhất trong học kỳ 1 năm 2006, kèm theo số lượng môn học mà họ đã dạy. 
	SELECT GV.MAGV, COUNT(DISTINCT MAMH) AS SoLuongMonHoc
	FROM GIAOVIEN GV
	INNER JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
	WHERE HOCKY = 1
	AND NAM = 2006
	GROUP BY GV.MAGV
	HAVING COUNT(MAMH) >= ALL (SELECT COUNT(DISTINCT MAMH)
							   FROM GIANGDAY GD1
							   INNER JOIN GIAOVIEN GV1 ON GD1.MAGV = GV1.MAGV
							   WHERE HOCKY = 1
							   AND NAM = 2006
							   GROUP BY GV1.MAGV)

--9. Tìm những giáo viên đã dạy cả môn “Co So Du Lieu” và “Cau Truc Roi Rac” trong cùng một học kỳ, kèm theo học kỳ và năm học. 
	SELECT GD.MAGV, GD.HOCKY, GD.NAM
	FROM GIANGDAY GD
	INNER JOIN MONHOC MH1 ON GD.MAMH = MH1.MAMH
	INNER JOIN MONHOC MH2 ON GD.MAMH = MH2.MAMH
	WHERE MH1.TENMH = 'Co so du lieu'
	AND MH2.TENMH = 'Cau truc roi rac'
	GROUP BY GD.MAGV, GD.HOCKY, GD.NAM
	HAVING COUNT(DISTINCT MH1.MAMH) = 1
	AND COUNT(DISTINCT MH2.MAMH) = 1;

--10. Liệt kê danh sách các môn học mà tất cả các giáo viên trong khoa “CNTT” đều đã giảng dạy ít nhất một lần trong năm 2006. 
	SELECT MH.MAMH, MH.TENMH
	FROM MONHOC MH
	WHERE NOT EXISTS (
		SELECT GV.MAGV
		FROM GIAOVIEN GV
		INNER JOIN KHOA K ON GV.MAKHOA = K.MAKHOA
		WHERE K.TENKHOA = 'CNTT'
		AND NOT EXISTS (
			SELECT GD.MAMH
			FROM GIANGDAY GD
			WHERE GD.MAMH = MH.MAMH
			AND GD.MAGV = GV.MAGV
			AND GD.NAM = 2006
			)
)

--11. Tìm những giáo viên có hệ số lương cao hơn mức lương trung bình của tất cả giáo viên trong khoa của họ, kèm theo tên khoa và hệ số lương của giáo viên đó. 
	SELECT GV.MAGV, GV.HESO, K.TENKHOA
	FROM GIAOVIEN GV
	INNER JOIN KHOA K ON GV.MAKHOA = K.MAKHOA
	WHERE GV.HESO > (
		SELECT AVG(GV1.HESO)
		FROM GIAOVIEN GV1
		WHERE GV1.MAKHOA = GV.MAKHOA
		)

--12. Xác định những lớp có sĩ số lớn hơn 40 nhưng không có giáo viên nào dạy quá 2 môn trong học kỳ 1 năm 2006, kèm theo tên lớp và sĩ số.
	SELECT L.TENLOP, L.SISO
	FROM LOP L
	WHERE L.SISO > 40
	AND NOT EXISTS (
		SELECT GV.MAGV
		FROM GIAOVIEN GV
		INNER JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
		WHERE GD.HOCKY = 1
		AND GD.NAM = 2006
		AND GD.MALOP = L.MALOP
		GROUP BY GV.MAGV
		HAVING COUNT(DISTINCT GD.MAMH) > 2
		)

--13. Tìm những môn học mà tất cả các học viên của lớp “K11” đều đạt điểm trên 7 trong lần thi cuối cùng của họ, kèm theo mã môn và tên môn học. 
SELECT MH.MAMH, MH.TENMH
FROM MONHOC MH
WHERE NOT EXISTS (
    SELECT HV.MAHV
    FROM HOCVIEN HV
    WHERE HV.MALOP = 'K11'
      AND NOT EXISTS (
        SELECT KQT.MAMH
        FROM KETQUATHI KQT
        WHERE KQT.MAHV = HV.MAHV
          AND KQT.MAMH = MH.MAMH
          AND KQT.LANTHI = (
            SELECT MAX(LANTHI)
            FROM KETQUATHI KQT2
            WHERE KQT2.MAHV = HV.MAHV
              AND KQT2.MAMH = MH.MAMH
          )
          AND KQT.DIEM > 7
      )
)

--14. Liệt kê danh sách các giáo viên đã dạy ít nhất một môn học trong mỗi học kỳ của năm 2006, kèm theo mã giáo viên và số lượng học kỳ mà họ đã giảng dạy. 
SELECT GD.MAGV, COUNT(DISTINCT GD.HOCKY) AS SoHocKy
FROM GIANGDAY GD
WHERE GD.NAM = 2006
GROUP BY GD.MAGV
HAVING COUNT(DISTINCT GD.HOCKY) = (SELECT COUNT(DISTINCT HOCKY)
                                   FROM GIANGDAY
                                   WHERE NAM = 2006)

--15. Tìm những giáo viên vừa là trưởng khoa vừa giảng dạy ít nhất 2 môn khác nhau trong năm 2006, kèm theo tên khoa và mã giáo viên. 
SELECT GV.MAGV, K.TENKHOA
FROM GIAOVIEN GV
INNER JOIN KHOA K ON GV.MAGV = K.TRGKHOA
INNER JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
WHERE GD.NAM = 2006
GROUP BY GV.MAGV, K.TENKHOA
HAVING COUNT(DISTINCT GD.MAMH) >= 2;

--16. Xác định những môn học mà tất cả các lớp do giáo viên chủ nhiệm “Nguyen To Lan” đều phải học trong năm 2006, kèm theo mã lớp và tên lớp. 
SELECT DISTINCT MH.MAMH, MH.TENMH
FROM MONHOC MH
WHERE NOT EXISTS (
    SELECT L.MALOP
    FROM LOP L
    INNER JOIN GIAOVIEN GV ON L.MAGVCN = GV.MAGV
    WHERE GV.HOTEN = 'Nguyen To Lan'
      AND NOT EXISTS (
          SELECT GD.MAMH
          FROM GIANGDAY GD
          WHERE GD.MALOP = L.MALOP
            AND GD.MAMH = MH.MAMH
            AND GD.NAM = 2006
      )
)
--17. Liệt kê danh sách các môn học mà không có điều kiện tiên quyết (không cần phải học trước bất kỳ môn nào), nhưng lại là điều kiện tiên quyết cho ít nhất 2 môn khác nhau, kèm theo mã môn và tên môn học. 
SELECT MH1.MAMH, MH1.TENMH
FROM MONHOC MH1
WHERE MH1.MAMH NOT IN (SELECT MAMH_TRUOC FROM DIEUKIEN)
  AND MH1.MAMH IN (SELECT MAMH_TRUOC
                   FROM DIEUKIEN
                   GROUP BY MAMH_TRUOC
                   HAVING COUNT(DISTINCT MAMH) >= 2)

--18. Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này và cũng chưa thi bất kỳ môn nào khác sau lần đó
SELECT HV.MAHV, HV.HO, HV.TEN
FROM HOCVIEN HV
WHERE EXISTS (
    SELECT *
    FROM KETQUATHI KQT
    WHERE KQT.MAHV = HV.MAHV
      AND KQT.MAMH = 'CSDL'
      AND KQT.LANTHI = 1
      AND KQT.DIEM < 5
      AND NOT EXISTS (
          SELECT *
          FROM KETQUATHI KQT1
          WHERE KQT1.MAHV = HV.MAHV
            AND (KQT1.MAMH = 'CSDL' AND KQT1.LANTHI > 1
                 OR KQT1.NGTHI > KQT.NGTHI)
      )
)
--19. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào trong năm 2006, nhưng đã từng giảng dạy trước đó. 
SELECT GV.MAGV, GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (
    SELECT *
    FROM GIANGDAY GD
    WHERE GD.MAGV = GV.MAGV AND GD.NAM = 2006
)
  AND EXISTS (
    SELECT *
    FROM GIANGDAY GD
    WHERE GD.MAGV = GV.MAGV AND GD.NAM < 2006
)
--20. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách trong năm 2006, nhưng đã từng giảng dạy các môn khác của khoa khác. 
SELECT GV.MAGV, GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (
    SELECT *
    FROM GIANGDAY GD
    INNER JOIN MONHOC MH ON GD.MAMH = MH.MAMH
    WHERE GD.MAGV = GV.MAGV
      AND MH.MAKHOA = GV.MAKHOA
      AND GD.NAM = 2006
)
  AND EXISTS (
    SELECT *
    FROM GIANGDAY GD
    INNER JOIN MONHOC MH ON GD.MAMH = MH.MAMH
    WHERE GD.MAGV = GV.MAGV
      AND MH.MAKHOA != GV.MAKHOA
)
--21. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn "Khong dat", nhưng có điểm trung bình tất cả các môn khác trên 7. 
SELECT HV.MAHV
FROM HOCVIEN HV
WHERE HV.MALOP = 'K11'
  AND EXISTS (
      SELECT KQT.MAMH
      FROM KETQUATHI KQT
      WHERE KQT.MAHV = HV.MAHV
        AND KQT.DIEM < 5
      GROUP BY KQT.MAMH
      HAVING COUNT(*) > 3
  )
  AND (SELECT AVG(DIEM)
       FROM KETQUATHI
       WHERE MAHV = HV.MAHV AND MAMH NOT IN (
           SELECT MAMH
           FROM KETQUATHI
           WHERE MAHV = HV.MAHV AND DIEM < 5
       )) > 7
--22. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn "Khong dat" và thi lần thứ 2 của môn CTRR đạt đúng 5 điểm, nhưng điểm trung bình của tất cả các môn khác đều dưới 6. 
SELECT HV.HOTEN
FROM HOCVIEN HV
WHERE HV.MALOP = 'K11'
  AND EXISTS (
      SELECT KQT.MAMH
      FROM KETQUATHI KQT
      WHERE KQT.MAHV = HV.MAHV
        AND KQT.DIEM < 5
      GROUP BY KQT.MAMH
      HAVING COUNT(*) > 3
  )
  AND EXISTS (
      SELECT *
      FROM KETQUATHI KQT
      WHERE KQT.MAHV = HV.MAHV
        AND KQT.MAMH = 'CTRR'
        AND KQT.LANTHI = 2
        AND KQT.DIEM = 5
  )
  AND (SELECT AVG(DIEM)
       FROM KETQUATHI
       WHERE MAHV = HV.MAHV
         AND MAMH NOT IN (
             SELECT MAMH
             FROM KETQUATHI
             WHERE MAHV = HV.MAHV AND DIEM < 5
         )) < 6

--23. Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học và có tổng số tiết giảng dạy (TCLT + TCTH) lớn hơn 30 tiết. 
SELECT GV.HOTEN
FROM GIAOVIEN GV
INNER JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
INNER JOIN MONHOC MH ON GD.MAMH = MH.MAMH
WHERE GD.MAMH = 'CTRR'
GROUP BY GV.HOTEN, GD.HOCKY, GD.NAM
HAVING COUNT(DISTINCT GD.MALOP) >= 2
   AND SUM(TCLT + TCTH) > 30;

--24. Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng), kèm theo số lần thi của mỗi học viên cho môn này. 
SELECT HV.MAHV, KQT.MAMH, KQT.DIEM, COUNT(KQT.LANTHI) AS SoLanThi
FROM HOCVIEN HV
INNER JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
WHERE KQT.MAMH = 'CSDL'
  AND KQT.LANTHI = (SELECT MAX(LANTHI)
                    FROM KETQUATHI KQT2
                    WHERE KQT2.MAHV = KQT.MAHV
                      AND KQT2.MAMH = KQT.MAMH)
GROUP BY HV.MAHV, KQT.MAMH, KQT.DIEM

--25. Danh sách học viên và điểm trung bình tất cả các môn (chỉ lấy điểm của lần thi sau cùng), kèm theo số lần thi trung bình cho tất cả các môn mà mỗi học viên đã tham gia.
SELECT HV.MAHV, 
       AVG(SL.DIEM) AS DiemTrungBinh, 
       AVG(SL.SoLanThi) AS SoLanThiTB
FROM HOCVIEN HV
INNER JOIN (
    SELECT KQT.MAHV, 
           KQT.MAMH, 
           MAX(KQT.LANTHI) AS SoLanThi, 
           MAX(KQT.DIEM) AS DIEM
    FROM KETQUATHI KQT
    GROUP BY KQT.MAHV, KQT.MAMH
) SL ON HV.MAHV = SL.MAHV
GROUP BY HV.MAHV;

