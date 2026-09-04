# SweetPay Bakery — mở rộng hệ thống thương mại điện tử

## Phạm vi đã triển khai

| Tác nhân | Vai trò, chức năng trực tiếp |
|---|---|
| Khách vãng lai | Xem, tìm, lọc bánh; quản lý giỏ; đăng ký và đăng nhập. |
| Khách hàng | Đặt bánh, chọn giao tận nơi/nhận tại tiệm, dùng mã giảm giá, thanh toán, theo dõi và gửi yêu cầu hủy đơn. |
| Quản trị viên | Quản lý sản phẩm, danh mục, mã giảm giá, khách hàng, tài khoản nhân viên; phân công giao hàng, duyệt hủy, đối soát và xem báo cáo. |
| Nhân viên cửa hàng (`store_staff`) | Tiếp nhận, chuẩn bị bánh, cập nhật tồn kho, bàn giao cho người giao hàng hoặc khách đến nhận. |
| Nhân viên giao hàng (`delivery_staff`) | Xem đơn được phân công, nhận giao, cập nhật thành công/thất bại, ghi nhận thu tiền COD. |
| Cổng thanh toán VNPAY Sandbox | Nhận yêu cầu thanh toán, trả thông báo giao dịch có chữ ký để website cập nhật thanh toán. |

Nhân viên giao hàng thao tác bằng tài khoản trên website. Phiên bản này chưa tích hợp API của hãng vận chuyển. Hoàn tiền được thực hiện tại ngân hàng/cổng thanh toán, sau đó quản trị viên ghi nhận chứng từ trên website; nút ghi nhận không tự chuyển tiền.

## Nâng cấp dự án hiện có

1. Sao lưu cơ sở dữ liệu `SweetPayBakery` trước khi nâng cấp.
2. Chạy **chỉ** `sql/09_ecommerce_operations.sql` trên cơ sở dữ liệu hiện có. Script bổ sung vai trò, bảng và trạng thái đơn; giữ lại dữ liệu cũ, chạy lại được. Không chạy `01_schema.sql` trên dữ liệu đang dùng vì file đó khởi tạo lại cơ sở dữ liệu.
3. Build bằng NetBeans/Tomcat 9 (Java EE 8, `javax.servlet`). Hoặc chạy Ant với JDK 21 trở lên:

   ```powershell
   # Trên máy đang mở NetBeans, dùng cùng JDK với IDE.
   $env:JAVA_HOME = 'C:/Program Files/Apache NetBeans/jdk'
   & 'C:/Program Files/Apache NetBeans/extide/ant/bin/ant.bat' '-Djavac.source=21' '-Djavac.target=21' dist
   ```

   Dự án đặt mức source/target Java 21. Nếu đổi JDK từ phiên bản cũ, chọn Clean and Build trong NetBeans để tránh trộn các file class khác phiên bản.

4. Redeploy `dist/SweetBakery.war` hoặc nạp lại ứng dụng đang dùng `build/web`.
5. Đăng nhập bằng tài khoản quản trị hiện có, mở **Nhân viên** để tạo tài khoản nhân viên cửa hàng và nhân viên giao hàng. Mỗi người dùng đăng nhập tại `/login`; hệ thống đưa đến khu vực theo vai trò.

Không tạo sẵn tài khoản nhân viên với mật khẩu mặc định trong cơ sở dữ liệu thật. Mật khẩu tài khoản mới dùng PBKDF2; tài khoản cũ vẫn đăng nhập được. Khi quản trị khóa tài khoản hoặc đổi vai trò, quyền truy cập được cập nhật ở yêu cầu tiếp theo.

## Các màn hình

| Đường dẫn sau `/SweetBakery` | Chức năng |
|---|---|
| `/admin/fulfillment` | Điều hành đơn, chi tiết, lịch sử xử lý, phân công và duyệt hủy |
| `/admin/categories` | Thêm, sửa, ẩn/hiện, xóa danh mục chưa có sản phẩm |
| `/admin/vouchers` | Quản lý mã, phần trăm/số tiền, mức tối thiểu, giảm tối đa, thời gian và số lượt còn lại |
| `/admin/staff` | Tạo, chỉnh sửa, khóa/mở tài khoản nhân viên |
| `/admin/reconciliation` | Chuyển khoản chờ đối chiếu, COD chờ bàn giao và đơn hủy cần hoàn tiền |
| `/admin/reports` | Doanh thu theo ngày đặt, trạng thái đơn, bánh bán chạy, COD còn giữ, tồn kho thấp, giao dịch trả tiền trùng |
| `/staff/orders` | Tiếp nhận và chuẩn bị đơn |
| `/staff/inventory` | Điều chỉnh tồn kho kèm lý do, kiểm tra thay đổi đồng thời |
| `/delivery/orders` | Chỉ các đơn được phân công cho người đang đăng nhập |
| `/order-detail?id=...` | Khách theo dõi tiến độ, thanh toán lại và gửi yêu cầu hủy |

Trang quản trị cũ vẫn giữ phần sản phẩm, khách hàng và thống kê khách mua nhiều. Các liên kết đơn hàng cũ chuyển đến màn hình điều hành mới. Doanh thu và khách mua nhiều chỉ tính đơn hoàn tất, đã thanh toán.

## Quy trình demo

1. Admin tạo hai tài khoản nhân viên; kiểm tra sản phẩm và tồn kho.
2. Khách chọn bánh, nhập thông tin và đặt đơn COD giao tận nơi.
3. Nhân viên cửa hàng: **Chờ xác nhận → Đã xác nhận → Đang chuẩn bị → Sẵn sàng giao**.
4. Admin phân công nhân viên giao hàng cho đơn.
5. Người được phân công: **Đang giao → Hoàn tất**, đánh dấu đã thu đủ COD. Nếu giao thất bại, nhập lý do; cửa hàng chuyển về sẵn sàng giao để thử lại.
6. Admin mở **Đối soát thanh toán**, nhập mã biên nhận sau khi thực tế nhận tiền từ người giao hàng.
7. Với nhận tại tiệm: nhân viên cửa hàng chuyển sang **Sẵn sàng nhận tại tiệm**, thu COD nếu có, rồi hoàn tất.
8. Thử đơn mới: khách gửi yêu cầu hủy trước khi cửa hàng xác nhận. Trong lúc chờ duyệt, đơn không được chuẩn bị/giao. Admin duyệt hủy sẽ hoàn lại tồn kho và lượt voucher đúng một lần; hoặc từ chối kèm lý do. Một đơn có một yêu cầu hủy.

Đơn trả trước chỉ vào bước xác nhận khi có trạng thái đã thanh toán. Nút **Thông báo tôi đã chuyển khoản** chỉ tạo thông báo cho cửa hàng; admin đối chiếu sao kê rồi nhập mã giao dịch để xác nhận. Hủy đơn đã thanh toán giữ thông tin đã nhận tiền và đưa đơn vào danh sách cần hoàn tiền.

## Kết nối VNPAY Sandbox

Phần tạo URL, Return và IPN được triển khai theo [tài liệu PAY chính thức của VNPAY](https://sandbox.vnpayment.vn/apis/docs/thanh-toan-pay/pay.html). Đăng ký thông tin merchant thử nghiệm tại [VNPAY Sandbox](https://sandbox.vnpayment.vn/devreg/).

1. Sao chép `config/sweetpay.properties.example` thành `<CATALINA_BASE>/conf/sweetpay.properties.local`.
2. Điền `VNPAY_TMN_CODE`, `VNPAY_HASH_SECRET`, `VNPAY_RETURN_URL`. Có thể dùng biến môi trường hoặc thuộc tính JVM cùng tên; thuộc tính JVM được ưu tiên, sau đó biến môi trường, rồi file cấu hình.
3. Return URL: `https://<địa-chỉ-thử-nghiệm>/SweetBakery/payments/vnpay/return`.
4. Đăng ký IPN URL với VNPAY: `https://<địa-chỉ-thử-nghiệm>/SweetBakery/payments/vnpay/ipn`. URL này phải được VNPAY truy cập từ Internet. `localhost` chỉ phục vụ thử nội bộ, không nhận được IPN từ VNPAY.
5. Khi có đủ cấu hình, lựa chọn **VNPAY Sandbox** xuất hiện ở bước đặt hàng. Sau khi tạo đơn, khách bấm nút thanh toán tại chi tiết đơn.

Ứng dụng chỉ chuyển hướng đến máy chủ Sandbox. Chữ ký HMAC-SHA512, mã merchant, mã tham chiếu, số tiền và kết quả giao dịch đều được kiểm tra. IPN cập nhật thanh toán trong transaction, khóa theo đơn để chống thông báo lặp/đồng thời. Return URL chỉ hiển thị kết quả, không đánh dấu đã trả tiền. Một lần thử thanh toán có hiệu lực 15 phút; thử lại dùng mã mới sau khi thất bại/hết hạn.

Nếu thanh toán đến sau khi đơn bị hủy, đơn vẫn giữ trạng thái hủy và xuất hiện trong đối soát hoàn tiền. Nếu hai lần thử cùng thành công, khoản thu trùng được liệt kê riêng trong báo cáo để xử lý trên cổng thanh toán.

**Cần thông tin merchant Sandbox do nhóm đăng ký để kiểm thử giao dịch trực tiếp với VNPAY.** Bộ kiểm thử trong dự án dùng chữ ký và thông báo mô phỏng trong cơ sở dữ liệu riêng, không gọi cổng thanh toán hoặc thực hiện chuyển tiền.

## Kiểm thử tự động

Yêu cầu: JDK 21+, Python 3.9+, SQL Server local, `sqlcmd`, Tomcat 9. Để chạy giao diện cần Node và Playwright; khai báo `PLAYWRIGHT_MODULE` nếu module không nằm trên đường dẫn mặc định. Java kết nối SQL bằng tài khoản hiện có trong `DBContext`, có thể ghi đè bằng `SWEETPAY_DB_USER`, `SWEETPAY_DB_PASSWORD`.

```powershell
python scripts/test_operations.py --tomcat-home 'C:/Users/Admin/Downloads/apache-tomcat-9.0.116' --http
```

Script tự tạo database có tiền tố `SweetPayBakeryOpsTest`, chạy migration hai lần để kiểm tra khả năng chạy lại, biên dịch toàn bộ Java và chạy kiểm thử. Máy chủ giao diện thử nghiệm dùng cổng 18081, cấu hình merchant giả lập riêng; không dùng database đang bán hàng. Kết thúc sẽ dừng máy chủ thử và xóa đúng database vừa tạo. Thêm `--keep-database` nếu muốn giữ dữ liệu để kiểm tra. Nhật ký lưu ở `.tools/tests/<thời-gian>/results.txt`; ảnh giao diện ở `.tools/*-desktop.png`, `.tools/orders-mobile.png`.

Các kiểm thử bao gồm: quyền của từng vai trò, tài khoản bị khóa, đơn không thuộc người dùng, CSRF, danh mục/mã giảm giá, chỉnh tồn kho đồng thời, hoàn tồn kho/voucher một lần, vòng đời COD và nhận tại tiệm, IPN bị giả mạo/sai tiền/sai merchant, thông báo lặp/đồng thời, thanh toán lại và thanh toán đến sau hủy.
