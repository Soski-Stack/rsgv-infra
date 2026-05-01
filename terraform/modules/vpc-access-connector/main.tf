resource "google_vpc_access_connector" "this" {
  name          = var.name
  region        = var.region
  project       = var.project_id
  network       = var.network
  ip_cidr_range = var.ip_cidr_range
  machine_type  = var.machine_type
  min_instances = var.min_instances
  max_instances = var.max_instances
}
