variable "instance_name"  { type = string }
variable "tier"           { type = string; default = "BASIC" }
variable "memory_size_gb" { type = number; default = 1 }
variable "region"         { type = string }
variable "project_id"     { type = string }
variable "vpc_network"    { type = string }
variable "redis_version"  { type = string; default = "REDIS_7_0" }
