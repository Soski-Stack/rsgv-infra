variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for the bastion VM"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "GCP zone for the bastion VM"
  type        = string
  default     = "us-east1-b"
}

variable "network" {
  description = "VPC network name (must match Cloud SQL private network)"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork name for the bastion VM"
  type        = string
  default     = "default"
}

variable "machine_type" {
  description = "GCE machine type for the bastion"
  type        = string
  default     = "e2-micro"
}

variable "bastion_image" {
  description = "Boot disk image for the bastion VM"
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "service_account_email" {
  description = "Service account email attached to the bastion VM (needs roles/cloudsql.client)"
  type        = string
}

variable "allowed_admins" {
  description = "List of IAM principals allowed to SSH via IAP (e.g. user:esosa@example.com, serviceAccount:...)"
  type        = list(string)
  default     = []
}

variable "cloud_sql_instance" {
  description = "Cloud SQL connection name (project:region:instance) for the startup script"
  type        = string
}

variable "environment" {
  description = "Environment label (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "labels" {
  description = "Additional labels to apply to resources"
  type        = map(string)
  default     = {}
}
