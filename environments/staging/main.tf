terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "rsgv-tfstate-staging"
    prefix = "infra/staging"
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

module "cloud_run_api" {
  source                = "../../terraform/modules/cloud-run"
  service_name          = "rsgv-api-staging"
  region                = var.region
  project_id            = var.project_id
  service_account_email = var.service_account_email
  min_instances         = 1
  max_instances         = 10
  env_vars              = var.api_env_vars
  allow_unauthenticated = false
}

module "cloud_sql" {
  source              = "../../terraform/modules/cloud-sql"
  instance_name       = var.cloud_sql_instance_name
  region              = var.region
  project_id          = var.project_id
  tier                = "db-g1-small"
  availability_type   = "REGIONAL"
  vpc_network         = data.google_compute_network.vpc.self_link
  database_name       = "rsgv_dev"
  db_user             = "rsgv_app"
  db_password         = var.db_password
  deletion_protection = true
}

module "memorystore" {
  source         = "../../terraform/modules/memorystore"
  instance_name  = "rsgv-redis-staging"
  region         = var.region
  project_id     = var.project_id
  memory_size_gb = 1
  vpc_network    = data.google_compute_network.vpc.self_link
}

module "gcs_uploads" {
  source        = "../../terraform/modules/gcs-bucket"
  bucket_name   = "rsgv-uploads-staging"
  project_id    = var.project_id
  force_destroy = false
}

module "secrets" {
  source     = "../../terraform/modules/secret-manager"
  project_id = var.project_id
  secrets    = var.secrets
}
