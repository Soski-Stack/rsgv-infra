resource "google_sql_database_instance" "this" {
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  settings {
    tier              = var.tier
    availability_type = var.availability_type

    backup_configuration {
      enabled                        = true
      start_time                     = var.backup_start_time
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    dynamic "database_flags" {
      for_each = var.enable_iam_authentication ? [1] : []
      content {
        name  = "cloudsql.iam_authentication"
        value = "on"
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_network
    }
  }

  deletion_protection = var.deletion_protection

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      # GCP-managed computed fields — not settable via provider
      settings[0].disk_size,
      settings[0].deletion_protection_enabled,
      settings[0].backup_configuration[0].location,
      settings[0].ip_configuration[0].psc_config,
      settings[0].maintenance_window,
      settings[0].password_validation_policy,
    ]
  }
}

resource "google_sql_database" "db" {
  name     = var.database_name
  instance = google_sql_database_instance.this.name
  project  = var.project_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_sql_user" "app_user" {
  name     = var.db_user
  instance = google_sql_database_instance.this.name
  password = var.db_password
  project  = var.project_id

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [password]
  }
}
