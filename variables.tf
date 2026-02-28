variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "vpc_network_name" {
  description = "Name of the existing VPC network"
  type        = string
}

variable "cloud_sql_instance_name" {
  description = "Name of the existing Cloud SQL instance"
  type        = string
}

variable "service_account_email" {
  description = "Service account email for Cloud Run"
  type        = string
}

variable "api_env_vars" {
  description = "Environment variables for the API container"
  type        = map(string)
  default     = {}
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "secrets" {
  description = "Secrets to store in Secret Manager"
  type        = map(string)
  sensitive   = true
  default     = {}
}
