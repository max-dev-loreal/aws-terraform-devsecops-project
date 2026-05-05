variable "role_name" {
  type        = string
  description = "IAM role name for EC2 instances."
}

variable "instance_profile_name" {
  type        = string
  description = "Instance profile name."
}

variable "secret_arn" {
  type        = string
  description = "Secrets Manager secret ARN that EC2 may read."
}

