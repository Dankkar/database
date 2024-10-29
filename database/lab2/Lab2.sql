--Ten: Pham Le Dang Kha
--MSSV: 23520669
USE DU_AN_CONG_TY
-- Liệt kê tất cả các chuyên gia và sắp xếp theo họ tên.
SELECT * FROM ChuyenGia
ORDER BY HoTen

-- Hiển thị tên và số điện thoại của các chuyên gia có chuyên ngành 'Phát triển phần mềm'.
SELECT HoTen, SoDienThoai
FROM ChuyenGia
WHERE ChuyenNganh = N'Phát triển phần mềm'

-- Liệt kê tất cả các công ty có trên 100 nhân viên.
SELECT * FROM CONGTY
WHERE SoNhanVien > 100

-- Hiển thị tên và ngày bắt đầu của các dự án bắt đầu trong năm 2023.
SELECT TenDuAn, NgayBatDau
FROM DuAn
WHERE YEAR(NgayBatDau) = 2023

-- Liệt kê tất cả các kỹ năng và sắp xếp theo tên kỹ năng.
SELECT * FROM KyNang
ORDER BY TenKyNang

-- Hiển thị tên và email của các chuyên gia có tuổi dưới 35 (tính đến năm 2024).
SELECT HoTen, Email
FROM ChuyenGia
WHERE (YEAR(GETDATE()) - YEAR(NgaySinh)) < 35

-- Hiển thị tên và chuyên ngành của các chuyên gia nữ.
SELECT HoTen, ChuyenNganh
FROM ChuyenGia
WHERE GioiTinh = N'Nữ'

-- Liệt kê tên các kỹ năng thuộc loại 'Công nghệ'.
SELECT TenKyNang
FROM KyNang
WHERE LoaiKyNang = N'Công nghệ'

-- Hiển thị tên và địa chỉ của các công ty trong lĩnh vực 'Phân tích dữ liệu'.
SELECT TenCongTy, DiaChi
FROM CongTy
WHERE LinhVuc = N'Phân tích dữ liệu'

-- Liệt kê tên các dự án có trạng thái 'Hoàn thành'.
SELECT TenDuAn
FROM DuAn
WHERE TrangThai = N'Hoàn thành'

-- Hiển thị tên và số năm kinh nghiệm của các chuyên gia, sắp xếp theo số năm kinh nghiệm giảm dần.
SELECT HoTen, NamKinhNghiem
FROM ChuyenGia
ORDER BY NamKinhNghiem DESC

-- Liệt kê tên các công ty và số lượng nhân viên, chỉ hiển thị các công ty có từ 100 đến 200 nhân viên.
SELECT TenCongTy, SoNhanVien
FROM CongTy
WHERE SoNhanVien BETWEEN 100 AND 200;

-- Hiển thị tên dự án và ngày kết thúc của các dự án kết thúc trong năm 2023.
SELECT TenDuAn, NgayKetThuc
FROM DuAn
WHERE Year(NgayKetThuc) = 2023

-- Liệt kê tên và email của các chuyên gia có tên bắt đầu bằng chữ 'N'.
SELECT HoTen, Email
FROM ChuyenGia
WHERE HoTen LIKE N'N%'

-- Hiển thị tên kỹ năng và loại kỹ năng, không bao gồm các kỹ năng thuộc loại 'Ngôn ngữ lập trình'.
SELECT TenKyNang, LoaiKyNang
FROM KyNang
EXCEPT
SELECT TenKyNang, LoaiKyNang
FROM KyNang
WHERE LoaiKyNang = N'Ngôn ngữ lập trình'


-- Hiển thị tên công ty và lĩnh vực hoạt động, sắp xếp theo lĩnh vực.
SELECT TenCongTy, LinhVuc
FROM CongTy
ORDER BY LinhVuc

-- Hiển thị tên và chuyên ngành của các chuyên gia nam có trên 5 năm kinh nghiệm.
SELECT HoTen, ChuyenNganh
FROM ChuyenGia
WHERE GioiTinh = N'Nam'
AND NamKinhNghiem > 5

-- Liệt kê tất cả các chuyên gia trong cơ sở dữ liệu.
SELECT * FROM ChuyenGia

-- Hiển thị tên và email của tất cả các chuyên gia nữ.
SELECT HoTen, Email
FROM ChuyenGia
WHERE GioiTinh = N'Nữ'

--  Liệt kê tất cả các công ty và số nhân viên của họ, sắp xếp theo số nhân viên giảm dần.
SELECT * FROM CongTy ORDER BY SoNhanVien DESC

-- Hiển thị tất cả các dự án đang trong trạng thái "Đang thực hiện".
SELECT * FROM DuAn
WHERE TrangThai = N'Đang thực hiện'

-- Liệt kê tất cả các kỹ năng thuộc loại "Ngôn ngữ lập trình".
SELECT * FROM KyNang
WHERE LoaiKyNang = N'Ngôn ngữ lập trình'

-- Hiển thị tên và chuyên ngành của các chuyên gia có trên 8 năm kinh nghiệm.
SELECT HoTen, ChuyenNganh
FROM ChuyenGia
WHERE NamKinhNghiem > 8

-- Liệt kê tất cả các dự án của công ty có MaCongTy là 1.
SELECT * 
FROM DuAn
WHERE MaCongTy = 1

-- Đếm số lượng chuyên gia trong mỗi chuyên ngành.
SELECT COUNT(MaChuyenGia)
FROM ChuyenGia

-- Tìm chuyên gia có số năm kinh nghiệm cao nhất.
SELECT * FROM ChuyenGia
WHERE NamKinhNghiem = (SELECT MAX(NamKinhNghiem) FROM ChuyenGia);


-- Liệt kê tổng số nhân viên cho mỗi công ty mà có số nhân viên lớn hơn 100. Sắp xếp kết quả theo số nhân viên tăng dần.
SELECT SoNhanVien
FROM CongTy
WHERE SoNhanVien > 100
ORDER BY SoNhanVien


-- Xác định số lượng dự án mà mỗi công ty tham gia có trạng thái 'Đang thực hiện'. Chỉ bao gồm các công ty có hơn một dự án đang thực hiện. Sắp xếp kết quả theo số lượng dự án giảm dần.
SELECT CT.MaCongTy, COUNT(MaDuAn) AS SoLuongDuAn
FROM DuAn
JOIN CongTy CT ON DuAn.MaCongTy = CT.MaCongTy
WHERE TrangThai = N'Đang thực hiện'
GROUP BY CT.MaCongTy
HAVING COUNT(MaDuAn) > 1
ORDER BY SoLuongDuAn DESC
-- Tìm kiếm các kỹ năng mà chuyên gia có cấp độ từ 4 trở lên và tính tổng số chuyên gia cho mỗi kỹ năng đó. Chỉ bao gồm những kỹ năng có tổng số chuyên gia lớn hơn 2. Sắp xếp kết quả theo tên kỹ năng tăng dần.
SELECT KN.MaKyNang, COUNT(MaChuyenGia) as SoLuongChuyenGia
FROM ChuyenGia_KyNang CG_KN
JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
WHERE CG_KN.CapDo >= 4
GROUP BY KN.MaKyNang, KN.TenKyNang
HAVING COUNT(MaChuyenGia) > 2
ORDER By KN.TenKyNang
-- Liệt kê tên các công ty có lĩnh vực 'Điện toán đám mây' và tính tổng số nhân viên của họ. Sắp xếp kết quả theo tổng số nhân viên tăng dần.
SELECT TenCongTy, SUM(SoNhanVien) AS TongSoNhanVien
FROM CongTy
WHERE LinhVuc = N'Điện toán đám mây'
GROUP BY TenCongTy
ORDER BY TongSoNhanVien
-- Liệt kê tên các công ty có số nhân viên từ 50 đến 150 và tính trung bình số nhân viên của họ. Sắp xếp kết quả theo tên công ty tăng dần.
SELECT TenCongTy, AVG(SoNhanVien) as SoNhanVienTrungBinh
FROM CongTy
WHERE SoNhanVien BETWEEN 50 AND 150
GROUP BY TenCongTy
ORDER BY TenCongTy
-- Xác định số lượng kỹ năng cho mỗi chuyên gia có cấp độ tối đa là 5 và chỉ bao gồm những chuyên gia có ít nhất một kỹ năng đạt cấp độ tối đa này. Sắp xếp kết quả theo tên chuyên gia tăng dần.
SELECT CG.MaChuyenGia, COUNT(MaKyNang) as SoLuongKyNang
FROM ChuyenGia_KyNang CG_KN
JOIN ChuyenGia CG ON CG_KN.MaChuyenGia = CG.MaChuyenGia
WHERE CapDo = 5
GROUP BY CG.MaChuyenGia, CG.HoTen
Having Count(MaKyNang) > 0
ORDER BY HoTen
-- Liệt kê tên các kỹ năng mà chuyên gia có cấp độ từ 4 trở lên và tính tổng số chuyên gia cho mỗi kỹ năng đó. Chỉ bao gồm những kỹ năng có tổng số chuyên gia lớn hơn 2. Sắp xếp kết quả theo tên kỹ năng tăng dần.
SELECT TenKyNang, COUNT(MaChuyenGia) as SoLuongChuyenGia
FROM ChuyenGia_KyNang CG_KN
JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
WHERE CapDo >= 4
GROUP BY CG_KN.MaKyNang, KN.TenKyNang
HAVING COUNT(MaChuyenGia) > 2
ORDER BY KN.TenKyNang
-- Tìm kiếm tên của các chuyên gia trong lĩnh vực 'Phát triển phần mềm' và tính trung bình cấp độ kỹ năng của họ. Chỉ bao gồm những chuyên gia có cấp độ trung bình lớn hơn 3. Sắp xếp kết quả theo cấp độ trung bình giảm dần.
SELECT HoTen, AVG(CapDo) as TrungBinhCapDo
FROM ChuyenGia_KyNang CG_KN
JOIN ChuyenGia CG On CG_KN.MaChuyenGia = CG.MaChuyenGia
WHERE CG.ChuyenNganh = N'Phát triển phần mềm'
GROUP BY CG.HoTen
HAVING AVG(CapDo) > 3
ORDER BY TrungBinhCapDo DESC;


