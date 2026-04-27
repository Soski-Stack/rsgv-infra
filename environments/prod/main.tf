terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "rsgv-tfstate-prod"
    prefix = "infra/prod"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_compute_network" "vpc" {
  name    = var.vpc_network_name
  project = var.project_id
}

# ── Networking ────────────────────────────────────────────────────────
module "vpc_connector" {
  source = "../../terraform/modules/vpc-access-connector"

  name          = "rsgv-connector-prod"
  region        = var.region
  project_id    = var.project_id
  network       = var.vpc_network_name
  ip_cidr_range = "10.8.1.0/28"
}

# ── Cloud SQL ─────────────────────────────────────────────────────────
module "cloud_sql" {
  source = "../../terraform/modules/cloud-sql"

  instance_name                  = var.cloud_sql_instance_name
  region                         = var.region
  project_id                     = var.project_id
  tier                           = "db-custom-1-3840"
  availability_type              = "ZONAL"
  vpc_network                    = data.google_compute_network.vpc.self_link
  database_name                  = "rsgv_prod"
  db_user                        = "rsgv_app"
  db_password                    = var.db_password
  deletion_protection            = true
  backup_start_time              = "02:00"
  point_in_time_recovery_enabled = true
  enable_iam_authentication      = true
}

# ── Memorystore (Redis) ───────────────────────────────────────────────
module "memorystore" {
  source = "../../terraform/modules/memorystore"

  instance_name  = "rsgv-redis-prod"
  region         = var.region
  project_id     = var.project_id
  tier           = "BASIC"
  memory_size_gb = 1
  vpc_network    = data.google_compute_network.vpc.self_link
}

# ── Cloud Run: API ────────────────────────────────────────────────────
module "cloud_run_api" {
  source = "../../terraform/modules/cloud-run"

  service_name            = "rsgv-api-prod"
  region                  = var.region
  project_id              = var.project_id
  service_account_email   = var.service_account_email
  cpu                     = "1000m"
  memory                  = "1Gi"
  min_instances           = 1
  max_instances           = 5
  container_port          = 4000
  cpu_throttling_disabled = true
  vpc_connector           = module.vpc_connector.name
  vpc_egress              = "private-ranges-only"
  env_vars                = var.api_env_vars
  allow_unauthenticated   = false
}

# ── Cloud Run: Resume Engine ──────────────────────────────────────────
module "cloud_run_resume" {
  source = "../../terraform/modules/cloud-run"

  service_name          = "rsgv-resume-prod"
  region                = var.region
  project_id            = var.project_id
  service_account_email = var.service_account_email
  cpu                   = "1000m"
  memory                = "1Gi"
  min_instances         = 0
  max_instances         = 3
  container_port        = 8000
  vpc_connector         = module.vpc_connector.name
  vpc_egress            = "private-ranges-only"
  allow_unauthenticated = false
}

# ── Cloud Run: Frontend ───────────────────────────────────────────────
module "cloud_run_web" {
  source = "../../terraform/modules/cloud-run"

  service_name          = "rsgv-web-prod"
  region                = var.region
  project_id            = var.project_id
  service_account_email = var.service_account_email
  cpu                   = "1000m"
  memory                = "256Mi"
  min_instances         = 0
  max_instances         = 3
  container_port        = 8080
  allow_unauthenticated = true
}

# ── GCS Buckets ───────────────────────────────────────────────────────
module "gcs_resumes" {
  source = "../../terraform/modules/gcs-bucket"

  bucket_name             = "rsgv-resumes-prod"
  project_id              = var.project_id
  force_destroy           = false
  versioning_enabled      = false
  enable_lifecycle_delete = false
  public_read             = true
}

module "gcs_uploads" {
  source = "../../terraform/modules/gcs-bucket"

  bucket_name             = "rsgv-uploads-prod"
  project_id              = var.project_id
  force_destroy           = false
  versioning_enabled      = false
  enable_lifecycle_delete = false
}

# ── Secret Manager ────────────────────────────────────────────────────
module "secrets" {
  source = "../../terraform/modules/secret-manager"

  project_id = var.project_id
  secrets    = var.secrets
}
