variable "bucket_name" {
  type = string
}

variable "location" {
  type    = string
  default = "US-EAST1"
}

variable "project_id" {
  type = string
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "versioning_enabled" {
  type    = bool
  default = true
}

variable "lifecycle_age_days" {
  type    = number
  default = 365
}

variable "enable_lifecycle_delete" {
  description = "Create a lifecycle rule that deletes objects older than lifecycle_age_days"
  type        = bool
  default     = true
}

variable "public_read" {
  description = "Grant allUsers:objectViewer (publicly readable objects)"
  type        = bool
  default     = false
}
