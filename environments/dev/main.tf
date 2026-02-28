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

module "cloud_run_api" {
  source                = "../../terraform/modules/cloud-run"
  service_name          = "rsgv-api-dev"
  region                = var.region
  project_id            = var.project_id
  image                 = var.api_image
  service_account_email = var.service_account_email
  min_instances         = 0
  max_instances         = 5
  env_vars              = var.api_env_vars
  allow_unauthenticated = false
}

module "cloud_sql" {
  source              = "../../terraform/modules/cloud-sql"
  instance_name       = "rsgv-db-dev"
  region              = var.region
  project_id          = var.project_id
  tier                = "db-f1-micro"
  availability_type   = "ZONAL"
  vpc_network         = var.vpc_network
  database_name       = "rsgv"
  db_user             = "rsgv_app"
  db_password         = var.db_password
  deletion_protection = false
}

module "memorystore" {
  source         = "../../terraform/modules/memorystore"
  instance_name  = "rsgv-redis-dev"
  region         = var.region
  project_id     = var.project_id
  memory_size_gb = 1
  vpc_network    = var.vpc_network
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
