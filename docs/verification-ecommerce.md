# Biên bản kiểm tra bản mở rộng — 04/09/2026

- Biên dịch toàn bộ mã Java với `--release 21`: đạt.
- Đóng gói Ant thành `dist/SweetBakery.war`: đạt.
- Migration 09 trên database thử nghiệm, chạy hai lần: đạt, không trùng bảng hoặc vai trò.
- 61 kiểm tra JDBC/nghiệp vụ: đạt.
- 63 kiểm tra HTTP/trình duyệt: đạt, gồm biểu mẫu multipart cũ, các vai trò, CSRF, thao tác quản lý, thanh toán thử nội bộ, tiếng Việt và hiển thị trên điện thoại.
- Kiểm tra 11 trang của ứng dụng thật tại `http://localhost:8080/SweetBakery`: HTTP 200, không phát hiện lỗi mã hóa tiếng Việt.

Lần chạy tự động đầy đủ: `.tools/tests/20260904083553456716/results.txt`. Chạy lại bằng `scripts/test_operations.py` theo hướng dẫn trong `ecommerce-upgrade.md`.

## Bảo toàn dữ liệu

Trước nâng cấp đã tạo bản sao lưu SQL Server dạng COPY_ONLY, có CHECKSUM và đã chạy RESTORE VERIFYONLY thành công:

```text
C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\Backup\SweetPayBakery_before_operations_2026-09-04T083621.bak
```

Sau khi áp dụng `09_ecommerce_operations.sql`, số đơn hàng (23), tài khoản (15), sản phẩm (15) và tổng lượng tồn (1401) khớp số liệu trước nâng cấp. Hai vai trò được bổ sung: `store_staff`, `delivery_staff`. Không tạo tài khoản hay đơn thử vào database chính. Các tệp báo cáo Word/Excel và thay đổi có sẵn của người dùng được giữ lại.

## Giới hạn xác minh

VNPAY được kiểm tra bằng IPN có chữ ký tự tạo trong hệ thống thử nghiệm biệt lập, bao gồm sai chữ ký, sai tiền, sai merchant, gọi lặp, gọi đồng thời, thanh toán lại và tiền đến sau hủy. Chưa chạy giao dịch với tài khoản merchant VNPAY thật vì chưa có cấu hình Sandbox của nhóm. Website chính đang ẩn lựa chọn VNPAY ở checkout cho đến khi điền cấu hình.

Giao hàng thực hiện qua tài khoản nhân viên trên website. Hoàn tiền thực hiện ngoài website rồi nhập chứng từ để đối soát; chưa tích hợp API hoàn tiền tự động.
