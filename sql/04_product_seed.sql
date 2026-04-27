USE SweetPayBakery;
GO

SET NOCOUNT ON;
GO

-- 1) Seed categories
IF NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'banh-kem')
BEGIN
    INSERT INTO categories (category_name, slug, description, status)
    VALUES (N'Bánh kem', 'banh-kem', N'Các loại bánh kem', 1);
END

IF NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'banh-ngot')
BEGIN
    INSERT INTO categories (category_name, slug, description, status)
    VALUES (N'Bánh ngọt', 'banh-ngot', N'Các loại bánh ngọt', 1);
END

IF NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'cookie')
BEGIN
    INSERT INTO categories (category_name, slug, description, status)
    VALUES (N'Cookie', 'cookie', N'Các loại bánh quy', 1);
END
GO

DECLARE @catCake INT = (SELECT TOP 1 category_id FROM categories WHERE slug = 'banh-kem');
DECLARE @catSweet INT = (SELECT TOP 1 category_id FROM categories WHERE slug = 'banh-ngot');
DECLARE @catCookie INT = (SELECT TOP 1 category_id FROM categories WHERE slug = 'cookie');

-- 2) Seed products (12 sample products)
IF NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SP001')
INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
VALUES (@catCake, N'Bánh kem dâu', 'SP001', 'banh-kem-dau', N'Bánh kem vị dâu ngọt nhẹ', 250000, 220000, N'Dâu', N'16cm', 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SP002')
INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
VALUES (@catCake, N'Bánh kem chocolate', 'SP002', 'banh-kem-chocolate', N'Bánh kem chocolate đậm vị', 280000, 250000, N'Chocolate', N'18cm', 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SP003')
INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
VALUES (@catCake, N'Bánh kem matcha', 'SP003', 'banh-kem-matcha', N'Bánh kem matcha thơm trà xanh', 300000, 275000, N'Matcha', N'18cm', 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SP004')
INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
VALUES (@catCake, N'Bánh kem xoài', 'SP004', 'banh-kem-xoai', N'Bánh kem xoài tươi mát', 290000, 260000, N'Xoài', N'18cm', 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SP005')
INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
VALUES (@catSweet, N'Cupcake vani', 'SP005', 'cupcake-vani', N'Cupcake mềm nhẹ vị vani', 35000, 30000, N'Vani', N'1 cái', 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SP006')
INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
VALUES (@catSweet, N'Cupcake chocolate', 'SP006', 'cupcake-chocolate', N'Cupcake chocolate mềm mịn', 38000, 33000, N'Chocolate', N'1 cái', 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SP007')
INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
VALUES (@catSweet, N'Su kem trà xanh', 'SP007', 'su-kem-tra-xanh', N'Bánh su kem vị trà xanh', 28000, 25000, N'Trà xanh', N'1 cái', 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SP008')
INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
VALUES (@catSweet, N'Tiramisu mini', 'SP008', 'tiramisu-mini', N'Tiramisu vị cà phê nhẹ', 55000, 50000, N'Cà phê', N'1 phần', 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SP009')
INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
VALUES (@catCookie, N'Cookie bơ', 'SP009', 'cookie-bo', N'Bánh quy bơ giòn thơm', 45000, 40000, N'Bơ', N'Hộp', 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SP010')
INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
VALUES (@catCookie, N'Cookie chocolate chip', 'SP010', 'cookie-chocolate-chip', N'Bánh quy chocolate chip', 50000, 45000, N'Chocolate', N'Hộp', 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SP011')
INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
VALUES (@catCookie, N'Cookie matcha', 'SP011', 'cookie-matcha', N'Bánh quy matcha thơm dịu', 52000, 47000, N'Matcha', N'Hộp', 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SP012')
INSERT INTO products (category_id, product_name, sku, slug, description, price, sale_price, flavor, size, status, created_at)
VALUES (@catCookie, N'Biscotti hạnh nhân', 'SP012', 'biscotti-hanh-nhan', N'Biscotti giòn với hạnh nhân', 60000, 55000, N'Hạnh nhân', N'Hộp', 1, GETDATE());
GO

-- 3) Seed main product images
INSERT INTO product_images (product_id, image_url, is_main, sort_order)
SELECT p.product_id, 'assets/images/products/banhkemdau.jpg', 1, 1
FROM products p
WHERE p.sku = 'SP001'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1);

INSERT INTO product_images (product_id, image_url, is_main, sort_order)
SELECT p.product_id, 'assets/images/products/banhkemchoco.jpg', 1, 1
FROM products p
WHERE p.sku = 'SP002'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1);

INSERT INTO product_images (product_id, image_url, is_main, sort_order)
SELECT p.product_id, 'assets/images/products/banhkemmatcha.jpg', 1, 1
FROM products p
WHERE p.sku = 'SP003'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1);

INSERT INTO product_images (product_id, image_url, is_main, sort_order)
SELECT p.product_id, 'assets/images/products/banhkemxoai.jpg', 1, 1
FROM products p
WHERE p.sku = 'SP004'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1);

INSERT INTO product_images (product_id, image_url, is_main, sort_order)
SELECT p.product_id, 'assets/images/products/cupcakevani.jpg', 1, 1
FROM products p
WHERE p.sku = 'SP005'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1);

INSERT INTO product_images (product_id, image_url, is_main, sort_order)
SELECT p.product_id, 'assets/images/products/cupcakechoco.jpg', 1, 1
FROM products p
WHERE p.sku = 'SP006'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1);

INSERT INTO product_images (product_id, image_url, is_main, sort_order)
SELECT p.product_id, 'assets/images/products/sukemtraxanh.jpg', 1, 1
FROM products p
WHERE p.sku = 'SP007'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1);

INSERT INTO product_images (product_id, image_url, is_main, sort_order)
SELECT p.product_id, 'assets/images/products/tiramisu.jpg', 1, 1
FROM products p
WHERE p.sku = 'SP008'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1);

INSERT INTO product_images (product_id, image_url, is_main, sort_order)
SELECT p.product_id, 'assets/images/products/cookiebo.jpg', 1, 1
FROM products p
WHERE p.sku = 'SP009'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1);

INSERT INTO product_images (product_id, image_url, is_main, sort_order)
SELECT p.product_id, 'assets/images/products/cookiechocochip.jpg', 1, 1
FROM products p
WHERE p.sku = 'SP010'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1);

INSERT INTO product_images (product_id, image_url, is_main, sort_order)
SELECT p.product_id, 'assets/images/products/cookiematcha.jpg', 1, 1
FROM products p
WHERE p.sku = 'SP011'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1);

INSERT INTO product_images (product_id, image_url, is_main, sort_order)
SELECT p.product_id, 'assets/images/products/biscotti.jpg', 1, 1
FROM products p
WHERE p.sku = 'SP012'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1);
GO

-- 4) Seed inventory for stock checks
IF OBJECT_ID(N'dbo.inventory', N'U') IS NOT NULL
BEGIN
    INSERT INTO inventory (product_id, quantity_in_stock, min_stock_level, last_restock_date, expiration_date, updated_at)
    SELECT p.product_id, 50, 5, GETDATE(), NULL, GETDATE()
    FROM products p
    WHERE p.sku IN ('SP001','SP002','SP003','SP004','SP005','SP006','SP007','SP008','SP009','SP010','SP011','SP012')
      AND NOT EXISTS (SELECT 1 FROM inventory i WHERE i.product_id = p.product_id);
END
GO

PRINT N'Seed dữ liệu sản phẩm hoàn tất.';
GO
