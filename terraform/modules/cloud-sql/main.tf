resource "google_sql_database_instance" "this" {
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  settings {
    tier              = var.tier
    availability_type = var.availability_type

    backup_configuration {
      enabled    = true
      start_time = "02:00"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_network
    }
  }

  deletion_protection = var.deletion_protection

  lifecycle {
    prevent_destroy = true
    # Ignore changes to settings that GCP manages automatically
    ignore_changes = [
      settings[0].disk_size,
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
