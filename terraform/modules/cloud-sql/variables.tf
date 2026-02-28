variable "instance_name" {
  description = "Cloud SQL instance name (must match existing GCP resource if importing)"
  type        = string
}

variable "database_version" {
  description = "Database engine version"
  type        = string
  default     = "POSTGRES_15"
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "ZONAL or REGIONAL"
  type        = string
  default     = "ZONAL"
}

variable "vpc_network" {
  description = "VPC network self-link for private IP"
  type        = string
}

variable "database_name" {
  description = "Name of the database inside the instance"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "deletion_protection" {
  description = "Enable GCP-level deletion protection"
  type        = bool
  default     = true
}
