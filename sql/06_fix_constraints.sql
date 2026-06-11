USE SweetPayBakery;
GO

-- =====================================================
-- Bước 1: Xoá CHECK CONSTRAINT cũ trên payments.payment_method
-- (nếu tồn tại, tên constraint tự động đặt bởi SQL Server)
-- =====================================================
DECLARE @constraintName NVARCHAR(200);

-- Xoá constraint trên payment_method
SELECT @constraintName = name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('dbo.payments')
  AND name LIKE '%payment_method%';

IF @constraintName IS NOT NULL
BEGIN
    EXEC ('ALTER TABLE payments DROP CONSTRAINT [' + @constraintName + ']');
    PRINT 'Dropped payment_method constraint: ' + @constraintName;
END
ELSE
    PRINT 'No payment_method constraint found (already clean).';
GO

-- Xoá constraint trên payment_status
DECLARE @statusConstraint NVARCHAR(200);
SELECT @statusConstraint = name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('dbo.payments')
  AND name LIKE '%payment_status%';

IF @statusConstraint IS NOT NULL
BEGIN
    EXEC ('ALTER TABLE payments DROP CONSTRAINT [' + @statusConstraint + ']');
    PRINT 'Dropped payment_status constraint: ' + @statusConstraint;
END
ELSE
    PRINT 'No payment_status constraint found (already clean).';
GO

-- =====================================================
-- Bước 2: Tạo bảng store_bank_account nếu chưa có
-- =====================================================
IF OBJECT_ID('dbo.store_bank_account', 'U') IS NULL
BEGIN
    CREATE TABLE store_bank_account (
        account_id INT IDENTITY(1,1) PRIMARY KEY,
        bank_name NVARCHAR(100) NOT NULL,
        account_number NVARCHAR(50) NOT NULL,
        account_holder NVARCHAR(100) NOT NULL,
        bin_code NVARCHAR(20) NOT NULL,
        is_default BIT DEFAULT 1
    );
    PRINT 'Created store_bank_account table.';
END
ELSE
    PRINT 'store_bank_account already exists.';
GO

-- =====================================================
-- Bước 3: Thêm tài khoản MB Bank của bạn (nếu chưa có)
-- =====================================================
IF NOT EXISTS (SELECT 1 FROM store_bank_account WHERE account_number = '240220060903')
BEGIN
    INSERT INTO store_bank_account (bank_name, account_number, account_holder, bin_code)
    VALUES (N'MB Bank', '240220060903', N'NGUYEN VAN A', '970422');
    PRINT 'Inserted MB Bank account.';
END
ELSE
    PRINT 'MB Bank account already exists.';
GO

PRINT '=== Migration 06 completed successfully ===';
GO
