terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "rsgv-tfstate-dev"
    prefix = "infra/dev"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Reference the existing VPC — Terraform does not own or manage it
data "google_compute_network" "vpc" {
  name    = var.vpc_network_name
  project = var.project_id
}

module "cloud_run_api" {
  source                = "../../terraform/modules/cloud-run"
  service_name          = "rsgv-api-dev"
  region                = var.region
  project_id            = var.project_id
  service_account_email = var.service_account_email
  min_instances         = 0
  max_instances         = 5
  env_vars              = var.api_env_vars
  allow_unauthenticated = false
}

module "cloud_sql" {
  source              = "../../terraform/modules/cloud-sql"
  instance_name       = var.cloud_sql_instance_name
  region              = var.region
  project_id          = var.project_id
  tier                = "db-custom-1-3840"
  availability_type   = "ZONAL"
  vpc_network         = data.google_compute_network.vpc.self_link
  database_name       = "rsgv_dev"
  db_user             = "rsgv_app"
  db_password         = var.db_password
  deletion_protection = true
  # Match live instance settings
  backup_start_time              = "16:00"
  point_in_time_recovery_enabled = true
  enable_iam_authentication      = true
}

module "memorystore" {
  source         = "../../terraform/modules/memorystore"
  instance_name  = "rsgv-redis-dev"
  region         = var.region
  project_id     = var.project_id
  memory_size_gb = 1
  vpc_network    = data.google_compute_network.vpc.self_link
}

module "gcs_uploads" {
  source        = "../../terraform/modules/gcs-bucket"
  bucket_name   = "rsgv-uploads-dev"
  project_id    = var.project_id
  force_destroy = true
}

module "secrets" {
  source     = "../../terraform/modules/secret-manager"
  project_id = var.project_id
  secrets    = var.secrets
}
