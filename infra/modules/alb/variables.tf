variable "name_prefix" {
  type        = string
  description = "Prefix used for Name tags."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources."
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the ALB."
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID for the ALB."
}

variable "target_port" {
  type        = number
  description = "Target group port."
  default     = 80
}

variable "healthcheck_path" {
  type        = string
  description = "Health check path."
  default     = "/health"
}

