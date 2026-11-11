# SweetBakery Nhóm 3

## Chạy bằng NetBeans

1. Clone hoặc tải mã nguồn từ nhánh `nhom-3-buoi-4`. Trong NetBeans, chọn **File → Open Project** và mở thư mục chứa `build.xml` và `nbproject`.
2. Dùng JDK 21 và Apache Tomcat 9. Nếu NetBeans báo thiếu server, mở **Project Properties → Run** và chọn Tomcat 9 đã đăng ký ở **Services → Servers**.
3. Chọn **Clean and Build**. Lần đầu, Ant tải các thư viện cần thiết từ Maven Central. Sau đó chọn **Run Project** để mở trang chủ ở context `/SweetBakery-Nhom3/`.

Giao diện của bài Buổi 4 bắt đầu ở `web/index.jsp`. Mẫu JSP nằm trong `web/WEB-INF/views/buoi4.jsp`. CSS, JavaScript và ảnh bánh nằm trong `web/assets/buoi4`.

## Trình diễn

- Mở menu bánh, chọn kích cỡ và lời chúc, rồi thêm vào giỏ. Chọn **Đăng nhập mẫu** ở bước đặt hàng.
- Mã `BANH10` giảm 10% cho giỏ từ 300.000 ₫ trong kỳ dữ liệu mẫu. Bấm **Tiếp tục thanh toán**, rồi chọn kết quả thành công hoặc thất bại. Giỏ vẫn còn khi mô phỏng thất bại.
- Chọn **Khu vực nhân viên** ở chân trang để vào vai quản trị viên, nhân viên cửa hàng hoặc nhân viên chăm sóc khách hàng. Đơn thanh toán mẫu xuất hiện ở màn hình xác nhận của nhân viên cửa hàng.
- Trong lịch sử đơn, mở đơn mẫu đã giao để gửi đánh giá. Vai nhân viên CSKH có thể duyệt và phản hồi.

Giao diện Buổi 4 lưu dữ liệu mẫu trong trình duyệt. Các thao tác đăng nhập, thanh toán, hoàn tiền và vận chuyển là thao tác trình diễn. Có thể mở một cửa sổ InPrivate mới để bắt đầu lại với dữ liệu mẫu ban đầu.

## Lược đồ

`thiet_ke_nhom3/Luoc_do_Nhom_3.sql` là lược đồ MySQL của báo cáo Buổi 4. Project demo có thể chạy mà không cần khởi tạo lược đồ này.
