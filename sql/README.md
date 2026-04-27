# SQL Scripts

Execution order for a fresh database:

1. `01_schema.sql`
2. `02_normalization_fix.sql`
3. `03_user_google_migration.sql` (optional, for Google OAuth fields)
4. `04_product_seed.sql` (optional, sample data)

Notes:

- Legacy root-level `SQL_*.sql` files are now placeholders only.
- Use scripts in this folder as the source of truth.
