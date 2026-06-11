USE SweetPayBakery;
GO

-- =======================================================
-- Kiểm tra total_amount là computed column hay cột thường
-- =======================================================
SELECT 
    c.name AS column_name,
    c.is_computed,
    cc.definition AS computed_definition
FROM sys.columns c
LEFT JOIN sys.computed_columns cc ON cc.object_id = c.object_id AND cc.column_id = c.column_id
WHERE c.object_id = OBJECT_ID('dbo.orders')
  AND c.name = 'total_amount';
GO

-- =======================================================
-- Nếu total_amount là COMPUTED COLUMN → đổi thành cột thường
-- (Computed column không cho INSERT trực tiếp)
-- Nếu đã là cột thường thì bỏ qua bước này
-- =======================================================
IF EXISTS (
    SELECT 1 FROM sys.computed_columns 
    WHERE object_id = OBJECT_ID('dbo.orders') AND name = 'total_amount'
)
BEGIN
    -- Xóa computed column cũ
    ALTER TABLE orders DROP COLUMN total_amount;
    PRINT 'Dropped computed column total_amount.';

    -- Tạo lại thành cột thường NOT NULL DEFAULT 0
    ALTER TABLE orders ADD total_amount DECIMAL(18,2) NOT NULL DEFAULT 0;
    PRINT 'Re-added total_amount as regular column with DEFAULT 0.';

    -- Cập nhật lại giá trị cho các đơn hàng cũ
    UPDATE orders SET total_amount = 
        CASE WHEN subtotal - discount_amount + shipping_fee < 0 
             THEN 0 
             ELSE subtotal - discount_amount + shipping_fee 
        END;
    PRINT 'Updated existing orders total_amount values.';
END
ELSE
BEGIN
    PRINT 'total_amount is already a regular column. No changes needed.';
    
    -- Đảm bảo có DEFAULT 0 phòng trường hợp null
    -- (Nếu chưa có DEFAULT thì thêm vào)
    IF NOT EXISTS (
        SELECT 1 FROM sys.default_constraints dc
        JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
        WHERE c.object_id = OBJECT_ID('dbo.orders') AND c.name = 'total_amount'
    )
    BEGIN
        ALTER TABLE orders ADD CONSTRAINT DF_orders_total_amount DEFAULT 0 FOR total_amount;
        PRINT 'Added DEFAULT 0 constraint to total_amount.';
    END
END
GO

PRINT '=== Migration 07 completed ===';
GO
