USE SweetPayBakery;
GO

SET NOCOUNT ON;
GO

-- 1) Remove duplicated payment status from orders (single source of truth is payments.payment_status)
IF COL_LENGTH('orders', 'payment_status') IS NOT NULL
BEGIN
    DECLARE @dropOrderPaymentSql NVARCHAR(MAX) = N'';

    SELECT @dropOrderPaymentSql = @dropOrderPaymentSql + N'ALTER TABLE dbo.orders DROP CONSTRAINT [' + c.name + N'];'
    FROM sys.check_constraints c
    WHERE c.parent_object_id = OBJECT_ID('dbo.orders')
      AND c.definition LIKE '%[payment_status]%';

    SELECT @dropOrderPaymentSql = @dropOrderPaymentSql + N'ALTER TABLE dbo.orders DROP CONSTRAINT [' + dc.name + N'];'
    FROM sys.default_constraints dc
    INNER JOIN sys.columns col
        ON col.object_id = dc.parent_object_id
       AND col.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID('dbo.orders')
      AND col.name = 'payment_status';

    IF (LEN(@dropOrderPaymentSql) > 0)
    BEGIN
        EXEC sp_executesql @dropOrderPaymentSql;
    END

    ALTER TABLE dbo.orders DROP COLUMN payment_status;
END
GO

-- 2) Convert total_amount to computed (prevent manual inconsistency)
IF OBJECT_ID('dbo.orders', 'U') IS NOT NULL
BEGIN
    UPDATE dbo.orders
    SET subtotal = ISNULL(subtotal, 0),
        discount_amount = ISNULL(discount_amount, 0),
        shipping_fee = ISNULL(shipping_fee, 0);
END
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.orders')
      AND name = 'total_amount'
      AND is_computed = 0
)
BEGIN
    DECLARE @dropTotalDefaultSql NVARCHAR(MAX) = N'';

    SELECT @dropTotalDefaultSql = @dropTotalDefaultSql + N'ALTER TABLE dbo.orders DROP CONSTRAINT [' + dc.name + N'];'
    FROM sys.default_constraints dc
    INNER JOIN sys.columns col
        ON col.object_id = dc.parent_object_id
       AND col.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID('dbo.orders')
      AND col.name = 'total_amount';

    IF (LEN(@dropTotalDefaultSql) > 0)
    BEGIN
        EXEC sp_executesql @dropTotalDefaultSql;
    END

    ALTER TABLE dbo.orders DROP COLUMN total_amount;
    ALTER TABLE dbo.orders
    ADD total_amount AS (CASE WHEN subtotal - discount_amount + shipping_fee < 0 THEN 0 ELSE subtotal - discount_amount + shipping_fee END);
END
GO

-- 3) Enforce one line per product in each order
IF OBJECT_ID('dbo.order_details', 'U') IS NOT NULL
BEGIN
    ;WITH duplicated AS (
        SELECT
            order_id,
            product_id,
            MIN(order_detail_id) AS keep_id,
            SUM(quantity) AS total_quantity,
            MAX(unit_price) AS keep_unit_price,
            COUNT(*) AS cnt
        FROM dbo.order_details
        GROUP BY order_id, product_id
        HAVING COUNT(*) > 1
    )
    UPDATE od
    SET od.quantity = d.total_quantity,
        od.unit_price = d.keep_unit_price
    FROM dbo.order_details od
    INNER JOIN duplicated d ON d.keep_id = od.order_detail_id;

    ;WITH duplicated AS (
        SELECT
            order_id,
            product_id,
            MIN(order_detail_id) AS keep_id
        FROM dbo.order_details
        GROUP BY order_id, product_id
        HAVING COUNT(*) > 1
    )
    DELETE od
    FROM dbo.order_details od
    INNER JOIN duplicated d
        ON d.order_id = od.order_id
       AND d.product_id = od.product_id
    WHERE od.order_detail_id <> d.keep_id;
END
GO

IF OBJECT_ID('dbo.order_details', 'U') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1
       FROM sys.key_constraints
       WHERE name = 'UQ_order_details_order_product'
         AND parent_object_id = OBJECT_ID('dbo.order_details')
   )
BEGIN
    ALTER TABLE dbo.order_details
    ADD CONSTRAINT UQ_order_details_order_product UNIQUE (order_id, product_id);
END
GO

-- 4) Enforce one inventory row per product
IF OBJECT_ID('dbo.inventory', 'U') IS NOT NULL
BEGIN
    ;WITH ranked AS (
        SELECT
            inventory_id,
            ROW_NUMBER() OVER (
                PARTITION BY product_id
                ORDER BY updated_at DESC, inventory_id DESC
            ) AS rn
        FROM dbo.inventory
    )
    DELETE i
    FROM dbo.inventory i
    INNER JOIN ranked r ON r.inventory_id = i.inventory_id
    WHERE r.rn > 1;
END
GO

IF OBJECT_ID('dbo.inventory', 'U') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1
       FROM sys.key_constraints
       WHERE name = 'UQ_inventory_product'
         AND parent_object_id = OBJECT_ID('dbo.inventory')
   )
BEGIN
    ALTER TABLE dbo.inventory
    ADD CONSTRAINT UQ_inventory_product UNIQUE (product_id);
END
GO

PRINT N'Normalization fixes applied.';
GO
