USE SweetPayBakery;
GO

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;

DECLARE @customerRoleId INT;
SELECT @customerRoleId = role_id FROM roles WHERE role_name = N'customer';

IF @customerRoleId IS NULL
BEGIN
    INSERT INTO roles (role_name, description)
    VALUES (N'customer', N'Khách hàng');

    SET @customerRoleId = SCOPE_IDENTITY();
END;

DECLARE @categoryId INT;
SELECT @categoryId = category_id FROM categories WHERE slug = 'demo-bao-cao';

IF @categoryId IS NULL
BEGIN
    INSERT INTO categories (category_name, slug, description, status)
    VALUES (N'Demo báo cáo', 'demo-bao-cao', N'Sản phẩm dùng cho dữ liệu báo cáo demo', 1);

    SET @categoryId = SCOPE_IDENTITY();
END;

DECLARE @productId INT;
SELECT @productId = product_id FROM products WHERE sku = 'DEMO-TOP-CUSTOMER';

IF @productId IS NULL
BEGIN
    INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
    VALUES (@categoryId, N'Combo bánh demo báo cáo', 'DEMO-TOP-CUSTOMER', 'combo-banh-demo-bao-cao',
            N'Sản phẩm ảo để tạo chi tiết đơn hàng demo', 250000, NULL, N'Tổng hợp', N'Combo', 1, GETDATE());

    SET @productId = SCOPE_IDENTITY();
END;

IF OBJECT_ID(N'dbo.inventory', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM inventory WHERE product_id = @productId)
BEGIN
    INSERT INTO inventory (product_id, quantity_in_stock, min_stock_level, last_restock_date, expiration_date, updated_at)
    VALUES (@productId, 999, 5, GETDATE(), NULL, GETDATE());
END;

DECLARE @DemoCustomers TABLE (
    Email NVARCHAR(100) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    Address NVARCHAR(255) NOT NULL
);

INSERT INTO @DemoCustomers (Email, FullName, Phone, Address)
VALUES
(N'demo.top01@sweetpay.test', N'Nguyễn Minh Anh', N'0901000001', N'12 Phan Đình Phùng, Hà Nội'),
(N'demo.top02@sweetpay.test', N'Trần Quốc Bình', N'0901000002', N'24 Nguyễn Huệ, TP. Hồ Chí Minh'),
(N'demo.top03@sweetpay.test', N'Lê Thu Chi', N'0901000003', N'36 Lê Lợi, Đà Nẵng'),
(N'demo.top04@sweetpay.test', N'Phạm Hải Đăng', N'0901000004', N'48 Hai Bà Trưng, Hà Nội'),
(N'demo.top05@sweetpay.test', N'Hoàng Ngọc Hà', N'0901000005', N'60 Trần Phú, Hải Phòng'),
(N'demo.top06@sweetpay.test', N'Vũ Gia Hân', N'0901000006', N'72 Pasteur, TP. Hồ Chí Minh'),
(N'demo.top07@sweetpay.test', N'Đỗ Nhật Khang', N'0901000007', N'84 Nguyễn Trãi, Hà Nội'),
(N'demo.top08@sweetpay.test', N'Bùi Thanh Lam', N'0901000008', N'96 Hùng Vương, Huế'),
(N'demo.top09@sweetpay.test', N'Phan Mai Linh', N'0901000009', N'108 Cầu Giấy, Hà Nội'),
(N'demo.top10@sweetpay.test', N'Đặng Đức Long', N'0901000010', N'120 Lý Thường Kiệt, Đà Nẵng'),
(N'demo.top11@sweetpay.test', N'Võ Bảo Ngân', N'0901000011', N'132 Điện Biên Phủ, TP. Hồ Chí Minh'),
(N'demo.top12@sweetpay.test', N'Lý Hoài Nam', N'0901000012', N'144 Nguyễn Văn Cừ, Cần Thơ');

INSERT INTO users (role_id, full_name, email, phone, password_hash, address, status, created_at)
SELECT @customerRoleId, c.FullName, c.Email, c.Phone, N'plain:123456', c.Address, 1, GETDATE()
FROM @DemoCustomers c
WHERE NOT EXISTS (SELECT 1 FROM users u WHERE u.email = c.Email);

DECLARE @DemoOrders TABLE (
    Email NVARCHAR(100) NOT NULL,
    OrderCode NVARCHAR(50) PRIMARY KEY,
    Subtotal DECIMAL(18,2) NOT NULL,
    DiscountAmount DECIMAL(18,2) NOT NULL,
    ShippingFee DECIMAL(18,2) NOT NULL,
    OrderStatus NVARCHAR(30) NOT NULL,
    OrderDate DATETIME NOT NULL,
    PaymentStatus NVARCHAR(30) NOT NULL,
    PaymentMethod NVARCHAR(30) NOT NULL
);

INSERT INTO @DemoOrders (Email, OrderCode, Subtotal, DiscountAmount, ShippingFee, OrderStatus, OrderDate, PaymentStatus, PaymentMethod)
VALUES
(N'demo.top01@sweetpay.test', N'DEMO-TOP-001-A', 2400000, 0, 0, N'completed', '2026-06-03T10:15:00', N'paid', N'BANK_TRANSFER'),
(N'demo.top01@sweetpay.test', N'DEMO-TOP-001-B', 1100000, 0, 0, N'completed', '2026-06-12T15:30:00', N'paid', N'COD'),
(N'demo.top02@sweetpay.test', N'DEMO-TOP-002-A', 3100000, 0, 0, N'completed', '2026-06-05T11:00:00', N'paid', N'BANK_TRANSFER'),
(N'demo.top03@sweetpay.test', N'DEMO-TOP-003-A', 2800000, 0, 0, N'completed', '2026-06-08T09:40:00', N'paid', N'BANK_TRANSFER'),
(N'demo.top04@sweetpay.test', N'DEMO-TOP-004-A', 2450000, 0, 0, N'completed', '2026-06-09T14:05:00', N'paid', N'COD'),
(N'demo.top05@sweetpay.test', N'DEMO-TOP-005-A', 2200000, 0, 0, N'completed', '2026-06-11T16:20:00', N'paid', N'BANK_TRANSFER'),
(N'demo.top06@sweetpay.test', N'DEMO-TOP-006-A', 1950000, 0, 0, N'completed', '2026-06-13T08:45:00', N'paid', N'BANK_TRANSFER'),
(N'demo.top07@sweetpay.test', N'DEMO-TOP-007-A', 1700000, 0, 0, N'completed', '2026-06-14T13:10:00', N'paid', N'COD'),
(N'demo.top08@sweetpay.test', N'DEMO-TOP-008-A', 1450000, 0, 0, N'completed', '2026-06-15T17:30:00', N'paid', N'BANK_TRANSFER'),
(N'demo.top09@sweetpay.test', N'DEMO-TOP-009-A', 1200000, 0, 0, N'completed', '2026-06-16T10:25:00', N'paid', N'BANK_TRANSFER'),
(N'demo.top10@sweetpay.test', N'DEMO-TOP-010-A', 980000, 0, 0, N'completed', '2026-06-17T12:00:00', N'paid', N'COD'),
(N'demo.top11@sweetpay.test', N'DEMO-TOP-011-A', 750000, 0, 0, N'completed', '2026-06-18T09:10:00', N'paid', N'BANK_TRANSFER'),
(N'demo.top12@sweetpay.test', N'DEMO-TOP-012-A', 520000, 0, 0, N'completed', '2026-06-18T18:00:00', N'paid', N'COD'),
(N'demo.top12@sweetpay.test', N'DEMO-TOP-012-X', 9000000, 0, 0, N'cancelled', '2026-06-10T18:00:00', N'refunded', N'BANK_TRANSFER'),
(N'demo.top01@sweetpay.test', N'DEMO-TOP-001-OLD', 5000000, 0, 0, N'completed', '2026-05-20T18:00:00', N'paid', N'BANK_TRANSFER');

IF EXISTS (
    SELECT 1
    FROM sys.computed_columns
    WHERE object_id = OBJECT_ID('dbo.orders')
      AND name = 'total_amount'
)
BEGIN
    INSERT INTO orders (
        user_id, voucher_id, order_code, recipient_name, recipient_phone, shipping_address,
        receive_method, receive_time, subtotal, discount_amount, shipping_fee,
        order_status, note, order_date
    )
    SELECT u.user_id, NULL, d.OrderCode, u.full_name, u.phone, u.address,
           N'delivery', NULL, d.Subtotal, d.DiscountAmount, d.ShippingFee,
           d.OrderStatus, N'Dữ liệu ảo cho báo cáo top khách hàng', d.OrderDate
    FROM @DemoOrders d
    INNER JOIN users u ON u.email = d.Email
    WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.order_code = d.OrderCode);
END
ELSE
BEGIN
    INSERT INTO orders (
        user_id, voucher_id, order_code, recipient_name, recipient_phone, shipping_address,
        receive_method, receive_time, subtotal, discount_amount, shipping_fee, total_amount,
        order_status, note, order_date
    )
    SELECT u.user_id, NULL, d.OrderCode, u.full_name, u.phone, u.address,
           N'delivery', NULL, d.Subtotal, d.DiscountAmount, d.ShippingFee,
           CASE WHEN d.Subtotal - d.DiscountAmount + d.ShippingFee < 0 THEN 0 ELSE d.Subtotal - d.DiscountAmount + d.ShippingFee END,
           d.OrderStatus, N'Dữ liệu ảo cho báo cáo top khách hàng', d.OrderDate
    FROM @DemoOrders d
    INNER JOIN users u ON u.email = d.Email
    WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.order_code = d.OrderCode);
END;

IF COL_LENGTH('dbo.orders', 'total_amount') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1
       FROM sys.computed_columns
       WHERE object_id = OBJECT_ID('dbo.orders')
         AND name = 'total_amount'
   )
BEGIN
    UPDATE orders
    SET total_amount = CASE
        WHEN subtotal - discount_amount + shipping_fee < 0 THEN 0
        ELSE subtotal - discount_amount + shipping_fee
    END
    WHERE order_code LIKE N'DEMO-TOP-%';
END;

INSERT INTO payments (order_id, payment_method, amount, payment_status, transaction_code, paid_at, created_at)
SELECT o.order_id, d.PaymentMethod,
       CASE WHEN d.Subtotal - d.DiscountAmount + d.ShippingFee < 0 THEN 0 ELSE d.Subtotal - d.DiscountAmount + d.ShippingFee END,
       d.PaymentStatus,
       d.OrderCode + N'-PAY',
       CASE WHEN d.PaymentStatus = N'paid' THEN d.OrderDate ELSE NULL END,
       d.OrderDate
FROM @DemoOrders d
INNER JOIN orders o ON o.order_code = d.OrderCode
WHERE NOT EXISTS (SELECT 1 FROM payments p WHERE p.order_id = o.order_id);

INSERT INTO order_details (order_id, product_id, quantity, unit_price)
SELECT o.order_id, @productId, 1, d.Subtotal
FROM @DemoOrders d
INNER JOIN orders o ON o.order_code = d.OrderCode
WHERE NOT EXISTS (
    SELECT 1
    FROM order_details od
    WHERE od.order_id = o.order_id
      AND od.product_id = @productId
);

PRINT N'Demo top customers seed completed. Use date range 2026-06-01 to 2026-06-18 on Admin Dashboard.';
GO
