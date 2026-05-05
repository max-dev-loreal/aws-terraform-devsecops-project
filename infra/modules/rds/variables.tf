variable "name_prefix" {
  type        = string
  description = "Prefix used for Name tags."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources."
  default     = {}
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for DB subnet group."
}

variable "db_security_group_id" {
  type        = string
  description = "Security group ID for DB."
}

variable "instance_class" {
  type        = string
  description = "RDS instance class."
}

variable "engine_version" {
  type    = string
  default = "15"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "username" {
  type    = string
  default = "postgres"
}

variable "password" {
  type        = string
  sensitive   = true
  description = "Database password."
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  type    = bool
  default = true
}

