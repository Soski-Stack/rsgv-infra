# Importing Existing Cloud SQL Resources

Run these commands **once** to bring existing GCP resources under Terraform management.
Replace `<PROJECT_ID>` and `rsgv-db-dev` with actual values.

## 1. Cloud SQL Instance
```bash
terraform import \
  module.cloud_sql.google_sql_database_instance.this \
  <PROJECT_ID>/rsgv-db-dev
```

## 2. Database
```bash
terraform import \
  module.cloud_sql.google_sql_database.db \
  <PROJECT_ID>/rsgv-db-dev/rsgv
```

## 3. App User
```bash
terraform import \
  module.cloud_sql.google_sql_user.app_user \
  <PROJECT_ID>/rsgv-db-dev/rsgv-app
```

## Notes
- Run from the relevant `environments/<env>/` directory
- Run `terraform plan` after each import to confirm no destroy/recreate actions
- `lifecycle { prevent_destroy = true }` is set on all three resources — Terraform will error rather than destroy
- `ignore_changes = [password]` on the user means password rotations won't trigger drift
