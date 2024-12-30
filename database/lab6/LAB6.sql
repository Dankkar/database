-- Câu hỏi SQL từ cơ bản đến nâng cao, bao gồm trigger
USE DU_AN_CONG_TY
-- Cơ bản:
--1. Liệt kê tất cả chuyên gia trong cơ sở dữ liệu.
	SELECT MaChuyenGia, HoTen
	FROM ChuyenGia
--2. Hiển thị tên và email của các chuyên gia nữ.
	SELECT HoTen, Email
	FROM ChuyenGia
	WHERE GioiTinh = N'Nữ'
--3. Liệt kê các công ty có trên 100 nhân viên.
	SELECT MaCongTy
	FROM CongTy
	WHERE SoNhanVien  > 100
--4. Hiển thị tên và ngày bắt đầu của các dự án trong năm 2023.
	SELECT TenDuAn, NgayBatDau
	FROM DuAn
	WHERE YEAR(DuAn.NgayBatDau) = 2023

--5

-- Trung cấp:
--6. Liệt kê tên chuyên gia và số lượng dự án họ tham gia.
	SELECT HoTen, COUNT(MaDuAn)
	FROM ChuyenGia CG
	INNER JOIN ChuyenGia_DuAn CG_DA ON CG.MaChuyenGia = CG_DA.MaChuyenGia
	GROUP BY CG.MaChuyenGia, HoTen
--7. Tìm các dự án có sự tham gia của chuyên gia có kỹ năng 'Python' cấp độ 4 trở lên.
	SELECT DISTINCT DA.MaDuAn
	FROM DuAn DA
	INNER JOIN ChuyenGia_DuAn CG_DA ON DA.MaDuAn = CG_DA.MaDuAn
	WHERE MaChuyenGia IN (SELECT MaChuyenGia
						  FROM ChuyenGia_KyNang CG_KN
						  INNER JOIN KyNang KN ON CG_KN.MaKyNang = KN.MaKyNang
						  WHERE KN.TenKyNang = 'Python'
						  AND CG_KN.CapDo >= 4)
--8. Hiển thị tên công ty và số lượng dự án đang thực hiện.
	SELECT TenCongTy, COUNT(DA.MaDuAn)
	FROM CongTy CT
	INNER JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
	GROUP BY DA.MaCongTy, CT.TenCongTy
--9. Tìm chuyên gia có số năm kinh nghiệm cao nhất trong mỗi chuyên ngành.
	SELECT HoTen, MaChuyenGia
	FROM ChuyenGia CG1
	WHERE NamKinhNghiem >= ALL (SELECT NamKinhNghiem
								FROM ChuyenGia CG2
								WHERE CG1.ChuyenNganh = CG2.ChuyenNganh)

--10. Liệt kê các cặp chuyên gia đã từng làm việc cùng nhau trong ít nhất một dự án.
	SELECT CG1.HoTen AS TENCG1, CG1.MaChuyenGia AS MACG1, CG2.HoTen AS TENCG2, CG2.MaChuyenGia AS MACG2
	FROM ChuyenGia CG1
	INNER JOIN ChuyenGia_DuAn CG_DA ON CG1.MaChuyenGia = CG_DA.MaChuyenGia
	INNER JOIN ChuyenGia_DuAn CG_DA2 ON CG_DA.MaDuAn = CG_DA2.MaDuAn
	INNER JOIN ChuyenGia CG2 ON CG2.MaChuyenGia = CG_DA2.MaChuyenGia
	WHERE CG1.MaChuyenGia > CG2.MaChuyenGia

-- Nâng cao:
--11. Tính tổng thời gian (theo ngày) mà mỗi chuyên gia đã tham gia vào các dự án.
	SELECT MaChuyenGia ,SUM(DATEDIFF(DAY,NgayThamGia, GETDATE()))
	FROM ChuyenGia_DuAn
	GROUP BY MaChuyenGia
--12. Tìm các công ty có tỷ lệ dự án hoàn thành cao nhất (trên 90%).
	SELECT MaCongTy
	FROM (
		  SELECT MaCongTy, 
		  COUNT(CASE WHEN TrangThai = N'Hoàn Thành' THEN 1 END) AS SoDuAnHoanThanh,
		  COUNT(MaDuAn) AS SoDuAn
		  FROM DuAn
		  GROUP BY MaCongTy
		 ) AS CONGTYDUAN
	WHERE SoDuAnHoanThanh > 0.9 * SoDuAn
--13. Liệt kê top 3 kỹ năng được yêu cầu nhiều nhất trong các dự án.
	
--14. Tính lương trung bình của chuyên gia theo từng cấp độ kinh nghiệm (Junior: 0-2 năm, Middle: 3-5 năm, Senior: >5 năm).

--15. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
	SELECT MaDuAn
	FROM DuAn DA
	WHERE NOT EXISTS(SELECT 1
					 FROM (SELECT DISTINCT ChuyenNganh FROM ChuyenGia) AS ALLCHUYENGANH
					 WHERE NOT EXISTS(SELECT 1
									  FROM ChuyenGia_DuAn CG_DA
									  INNER JOIN ChuyenGia CG ON CG.MaChuyenGia = CG_DA.MaChuyenGia
									  WHERE CG.ChuyenNganh = ALLCHUYENGANH.ChuyenNganh
									  AND CG_DA.MaDuAn = DA.MaDuAn))

-- Trigger:
--16. Tạo một trigger để tự động cập nhật số lượng dự án của công ty khi thêm hoặc xóa dự án.
	GO
	CREATE TRIGGER UPDATE_DA ON DUAN
	AFTER INSERT, DELETE
	AS
	BEGIN
		IF EXISTS(SELECT 1 FROM inserted)
		BEGIN
			UPDATE CongTy
			SET SoLuongDuAn = SoLuongDuAn + (SELECT COUNT(*)
											   FROM inserted
											   WHERE CongTy.MaCongTy = inserted.MaCongTy)
			WHERE MaCongTy IN (SELECT MaCongTy FROM inserted);
		END
		IF EXISTS(SELECT 1 FROM deleted)
		BEGIN
			UPDATE CongTy
			SET SoLuongDuAn = SoLuongDuAn - (SELECT COUNT(*)
											 FROM deleted
											 WHERE CongTy.MaCongTy = deleted.MaCongTy)
			WHERE MaCongTy IN (SELECT MaCongTy FROM deleted)
		END
	END


--17. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng ChuyenGia.


--18. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.

--19. Tạo một trigger để tự động cập nhật trạng thái của dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc.


--20. Tạo một trigger để tự động tính toán và cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
