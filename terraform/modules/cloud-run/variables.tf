variable "service_name" {
  description = "Cloud Run service name"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "image_placeholder" {
  description = "Initial container image (Terraform ignores updates — image is managed by rsgv-crm CI/CD)"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello:latest"
}

variable "cpu" {
  description = "CPU limit"
  type        = string
  default     = "1000m"
}

variable "memory" {
  description = "Memory limit"
  type        = string
  default     = "512Mi"
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "env_vars" {
  description = "Static environment variables (secrets should use Secret Manager)"
  type        = map(string)
  default     = {}
}

variable "service_account_email" {
  description = "Service account email for Cloud Run identity"
  type        = string
}

variable "allow_unauthenticated" {
  description = "Allow unauthenticated public access"
  type        = bool
  default     = false
}
