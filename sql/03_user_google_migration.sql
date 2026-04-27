USE SweetPayBakery;
GO

SET NOCOUNT ON;
GO

IF COL_LENGTH('users', 'google_sub') IS NULL
BEGIN
    ALTER TABLE users ADD google_sub NVARCHAR(100) NULL;
END
GO

IF COL_LENGTH('users', 'auth_provider') IS NULL
BEGIN
    ALTER TABLE users ADD auth_provider NVARCHAR(30) NULL;
END
GO

IF COL_LENGTH('users', 'avatar_url') IS NULL
BEGIN
    ALTER TABLE users ADD avatar_url NVARCHAR(255) NULL;
END
GO

IF COL_LENGTH('users', 'email_verified') IS NULL
BEGIN
    ALTER TABLE users ADD email_verified BIT NOT NULL CONSTRAINT DF_users_email_verified DEFAULT 0;
END
GO

IF COL_LENGTH('users', 'last_login_at') IS NULL
BEGIN
    ALTER TABLE users ADD last_login_at DATETIME NULL;
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UQ_users_google_sub'
      AND object_id = OBJECT_ID('dbo.users')
)
BEGIN
    CREATE UNIQUE INDEX UQ_users_google_sub ON users(google_sub) WHERE google_sub IS NOT NULL;
END
GO

UPDATE users
SET auth_provider = ISNULL(auth_provider, 'local')
WHERE auth_provider IS NULL;
GO

PRINT N'User Google migration completed.';
GO
