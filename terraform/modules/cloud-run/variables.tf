variable "service_name"          { type = string }
variable "region"                { type = string }
variable "project_id"            { type = string }
variable "image"                 { type = string }
variable "cpu"                   { type = string; default = "1000m" }
variable "memory"                { type = string; default = "512Mi" }
variable "min_instances"         { type = number; default = 0 }
variable "max_instances"         { type = number; default = 10 }
variable "env_vars"              { type = map(string); default = {} }
variable "service_account_email" { type = string }
variable "allow_unauthenticated" { type = bool; default = false }
