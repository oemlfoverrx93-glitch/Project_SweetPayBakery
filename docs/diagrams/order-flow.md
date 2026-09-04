# Hình 4.x. Activity Diagram quy trình đặt hàng và thanh toán

```mermaid
flowchart TD
    A["Khách xem sản phẩm"] --> B["Thêm sản phẩm vào giỏ hàng"]
    B --> C{"Đã đăng nhập?"}
    C -- "Chưa" --> D["AuthFilter chuyển đến /login"]
    D --> E["Đăng nhập thành công"]
    C -- "Rồi" --> F["Mở trang checkout"]
    E --> F
    F --> G["Nhập thông tin nhận hàng"]
    G --> H{"Nhập voucher?"}
    H -- "Có" --> I["VoucherDAO kiểm tra mã, thời hạn, số lượng"]
    I --> J{"Voucher hợp lệ?"}
    J -- "Không" --> F
    J -- "Có" --> K["Tính giảm giá"]
    H -- "Không" --> L["Tính tạm tính, phí giao hàng, tổng tiền"]
    K --> L
    L --> M["PlaceOrderServlet kiểm tra CSRF, cart, tồn kho"]
    M --> N{"Dữ liệu hợp lệ?"}
    N -- "Không" --> F
    N -- "Có" --> O["OrderDAO.placeOrder chạy transaction"]
    O --> O1["Đọc lại giá, danh mục và voucher trong transaction"]
    O1 --> P["Tạo orders, order_details, payments"]
    P --> Q["Trừ tồn kho và lượt voucher"]
    Q --> R{"Phương thức thanh toán"}
    R -- "COD" --> S["Chuyển đến order-success"]
    R -- "BANK_TRANSFER" --> T["PaymentServlet tạo thông tin VietQR"]
    T --> U["Khách gửi thông báo đã chuyển khoản"]
    U --> U1["Admin đối chiếu sao kê và nhập mã giao dịch"]
    U1 --> V["Cập nhật trạng thái paid"]
    R -- "VNPAY" --> W["Tạo payment_attempt và URL ký HMAC-SHA512"]
    W --> X["Khách thanh toán tại VNPAY Sandbox"]
    X --> Y["IPN có chữ ký, mã merchant, số tiền và mã tham chiếu hợp lệ"]
    Y --> V
    X --> Z["Return URL chỉ hiển thị kết quả"]
    S --> STAFF["Nhân viên xác nhận và chuẩn bị bánh"]
    V --> STAFF
    STAFF --> RECEIVE{"Cách nhận bánh"}
    RECEIVE -- "Tại tiệm" --> PICKUP["Sẵn sàng nhận, thu COD nếu có và hoàn tất"]
    RECEIVE -- "Giao tận nơi" --> READY["Sẵn sàng giao"]
    READY --> ASSIGN["Admin phân công nhân viên giao hàng"]
    ASSIGN --> DELIVERY["Người được giao cập nhật đang giao"]
    DELIVERY --> DONE["Giao thành công, xác nhận đã thu COD nếu có"]
    DONE --> REMIT["Admin ghi nhận bàn giao tiền COD"]
    DELIVERY --> FAILED["Giao thất bại kèm lý do"]
    FAILED --> READY
```

Ghi chú: đơn trả trước chỉ được xác nhận sau khi đã thanh toán. `OrderWorkflowService` kiểm soát bước xử lý, quyền tác nhân, COD và hủy đơn; `GatewayPaymentService` chỉ cập nhật thanh toán từ IPN hợp lệ. Yêu cầu hủy được gửi khi đơn còn chờ xác nhận; trong lúc chờ duyệt, đơn tạm dừng xử lý. Duyệt hủy hoàn tồn kho và lượt voucher một lần; tiền đã nhận được đưa vào đối soát hoàn tiền.
