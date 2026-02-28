resource "google_secret_manager_secret" "this" {
  for_each  = var.secrets
  secret_id = each.key
  project   = var.project_id

  replication { automatic = true }
}

resource "google_secret_manager_secret_version" "this" {
  for_each    = var.secrets
  secret      = google_secret_manager_secret.this[each.key].id
  secret_data = each.value
}
