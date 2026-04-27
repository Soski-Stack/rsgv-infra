variable "name" {
  description = "Connector name (max 25 chars)"
  type        = string
}

variable "region" {
  description = "GCP region for the connector"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "network" {
  description = "VPC network the connector attaches to"
  type        = string
  default     = "default"
}

variable "ip_cidr_range" {
  description = "/28 CIDR range for the connector subnet (must not overlap with anything else in the VPC)"
  type        = string
}

variable "machine_type" {
  description = "Connector instance machine type"
  type        = string
  default     = "e2-micro"
}

variable "min_instances" {
  description = "Minimum connector instances (>= 2)"
  type        = number
  default     = 2
}

variable "max_instances" {
  description = "Maximum connector instances (>= min_instances + 1)"
  type        = number
  default     = 3
}
