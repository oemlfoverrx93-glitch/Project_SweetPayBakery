# SQL Scripts

Execution order for a fresh database:

1. `01_schema.sql`
2. `02_normalization_fix.sql`
3. `04_product_seed.sql` (optional, sample data)
4. `05_bank_account.sql` (optional, default bank account)
5. `06_fix_constraints.sql` (optional, compatibility fixes)
6. `07_fix_total_amount_column.sql` (optional, total amount compatibility fix)
7. `09_ecommerce_operations.sql` (employee roles, fulfillment, cancellation, payment attempts and reconciliation)

Notes:

- Legacy root-level `SQL_*.sql` files are now placeholders only.
- Use scripts in this folder as the source of truth.
- For an existing database, back it up and apply `09_ecommerce_operations.sql` only for this upgrade. Do not rerun `01_schema.sql`: it drops and recreates the database.
- See `docs/ecommerce-upgrade.md` for role setup, workflows, sandbox configuration and isolated tests.
