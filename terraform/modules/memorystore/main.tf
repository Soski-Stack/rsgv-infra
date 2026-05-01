resource "google_redis_instance" "this" {
  name           = var.instance_name
  tier           = var.tier
  memory_size_gb = var.memory_size_gb
  region         = var.region
  project        = var.project_id

  authorized_network = var.vpc_network
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  redis_version      = var.redis_version
}
