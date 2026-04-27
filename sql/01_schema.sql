USE master;
GO

-- 1. Nếu Database đang tồn tại, xóa nó đi để làm lại từ đầu
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'SweetPayBakery')
BEGIN
    ALTER DATABASE SweetPayBakery SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SweetPayBakery;
END
GO

CREATE DATABASE SweetPayBakery;
GO

USE SweetPayBakery;
GO

-- [Các bảng bên dưới giữ nguyên logic đã tối ưu ở câu trả lời trước của mình]

-- 1. Roles
CREATE TABLE roles (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(255)
);

-- 2. Users
CREATE TABLE users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    role_id INT NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    phone NVARCHAR(20),
    password_hash NVARCHAR(255) NOT NULL,
    address NVARCHAR(255),
    status BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_users_roles FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- 3. Categories
CREATE TABLE categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL,
    slug NVARCHAR(100) UNIQUE,
    description NVARCHAR(255),
    image_url NVARCHAR(255),
    status BIT DEFAULT 1
);

-- 4. Products
CREATE TABLE products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    category_id INT NOT NULL,
    product_name NVARCHAR(150) NOT NULL,
    sku NVARCHAR(50) UNIQUE,
    slug NVARCHAR(150) UNIQUE,
    description NVARCHAR(MAX),
    price DECIMAL(18,2) NOT NULL CHECK (price >= 0),
    sale_price DECIMAL(18,2) NULL CHECK (sale_price >= 0),
    flavor NVARCHAR(100),
    size NVARCHAR(50),
    status BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_products_categories FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 5. Product Images
CREATE TABLE product_images (
    image_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    image_url NVARCHAR(255) NOT NULL,
    is_main BIT DEFAULT 0,
    sort_order INT DEFAULT 1,
    CONSTRAINT FK_product_images_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 6. Vouchers
CREATE TABLE vouchers (
    voucher_id INT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(50) NOT NULL UNIQUE,
    voucher_name NVARCHAR(100) NOT NULL,
    discount_type NVARCHAR(20) NOT NULL CHECK (discount_type IN ('percent', 'fixed')),
    discount_value DECIMAL(18,2) NOT NULL CHECK (discount_value > 0),
    min_order_value DECIMAL(18,2) DEFAULT 0,
    max_discount DECIMAL(18,2) NULL,
    quantity INT DEFAULT 0,
    start_date DATETIME,
    end_date DATETIME,
    status BIT DEFAULT 1,
    CONSTRAINT CHK_date_range CHECK (end_date >= start_date)
);

-- 7. Orders
CREATE TABLE orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    voucher_id INT NULL,
    order_code NVARCHAR(50) NOT NULL UNIQUE,
    recipient_name NVARCHAR(100) NOT NULL,

	recipient_phone NVARCHAR(20) NOT NULL,
    shipping_address NVARCHAR(255) NOT NULL,
    receive_method NVARCHAR(50) CHECK (receive_method IN ('delivery', 'pickup')),
    receive_time DATETIME NULL,
    subtotal DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
    discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
    shipping_fee DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (shipping_fee >= 0),
    total_amount AS (CASE WHEN subtotal - discount_amount + shipping_fee < 0 THEN 0 ELSE subtotal - discount_amount + shipping_fee END),
    order_status NVARCHAR(30) DEFAULT 'pending' 
        CHECK (order_status IN ('pending', 'confirmed', 'preparing', 'shipping', 'ready_for_pickup', 'completed', 'cancelled')),
    note NVARCHAR(255),
    order_date DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_orders_users FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT FK_orders_vouchers FOREIGN KEY (voucher_id) REFERENCES vouchers(voucher_id)
);

-- 8. Order Details
CREATE TABLE order_details (
    order_detail_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(18,2) NOT NULL,
    line_total AS (quantity * unit_price), 
    CONSTRAINT UQ_order_details_order_product UNIQUE (order_id, product_id),
    CONSTRAINT FK_order_details_orders FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT FK_order_details_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 9. Inventory
CREATE TABLE inventory (
    inventory_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL UNIQUE,
    quantity_in_stock INT NOT NULL DEFAULT 0 CHECK (quantity_in_stock >= 0),
    min_stock_level INT DEFAULT 5,
    last_restock_date DATETIME DEFAULT GETDATE(),
    expiration_date DATETIME NULL,
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_inventory_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 10. Payments
CREATE TABLE payments (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_method NVARCHAR(30) NOT NULL
        CHECK (payment_method IN ('COD', 'BANK_TRANSFER', 'MOMO', 'VNPAY')),
    amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    payment_status NVARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (payment_status IN ('pending', 'unpaid', 'paid', 'failed', 'refunded')),
    transaction_code NVARCHAR(100) NULL,
    paid_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_payments_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- 11. Chèn dữ liệu mẫu
INSERT INTO roles(role_name, description) VALUES 
(N'admin', N'Quản trị hệ thống'),
(N'customer', N'Khách hàng');

INSERT INTO users(role_id, full_name, email, phone, password_hash, address) VALUES
(1, N'Admin SweetPay', N'admin@sweetpay.com', '0900000001', 'hashed_admin123', N'Hà Nội'),
(2, N'Nguyễn Văn A', N'vana@gmail.com', '0900000002', 'hashed_123456', N'Hồ Chí Minh');

INSERT INTO categories(category_name, slug, description, image_url) VALUES
(N'Bánh kem', 'banh-kem', N'Các loại bánh kem sinh nhật', 'assets/images/cake-category.jpg'),
(N'Bánh ngọt', 'banh-ngot', N'Các loại bánh ngọt hàng ngày', 'assets/images/sweet-category.jpg');

INSERT INTO products(category_id, product_name, sku, slug, price, sale_price) VALUES
(1, N'Bánh kem dâu', 'CAKE001', 'banh-kem-dau', 350000, 320000),
(2, N'Cupcake vani', 'SWEET001', 'cupcake-vani', 45000, 39000);
GO
