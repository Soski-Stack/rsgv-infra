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
