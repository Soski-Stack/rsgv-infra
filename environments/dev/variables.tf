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
  description = "Name of the existing VPC network (Terraform will reference it via data source, not manage it)"
  type        = string
}

variable "cloud_sql_instance_name" {
  description = "Name of the existing Cloud SQL instance to import/manage"
  type        = string
}

variable "service_account_email" {
  description = "Service account email for Cloud Run identity"
  type        = string
}

variable "api_env_vars" {
  description = "Static environment variables for the API (non-secret)"
  type        = map(string)
  default     = {}
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "secrets" {
  description = "Secrets to provision in Secret Manager"
  type        = map(string)
  sensitive   = true
  default     = {}
}
