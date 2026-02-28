variable "instance_name" {
  type = string
}

variable "database_version" {
  type    = string
  default = "POSTGRES_15"
}

variable "region" {
  type = string
}

variable "project_id" {
  type = string
}

variable "tier" {
  type    = string
  default = "db-f1-micro"
}

variable "availability_type" {
  type    = string
  default = "ZONAL"
}

variable "vpc_network" {
  type = string
}

variable "database_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "deletion_protection" {
  type    = bool
  default = true
}
