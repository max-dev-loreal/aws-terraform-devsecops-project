variable "name_prefix" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources."
  default     = {}
}

variable "region" {
  type        = string
  description = "AWS region for boto3 clients."
  default     = "eu-north-1"
}

variable "telegram_bot_token" {
  type      = string
  sensitive = true
}

variable "telegram_chat_id" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_pat_secret_arn" {
  type = string
}

variable "plans_s3_bucket" {
  type        = string
  description = "S3 bucket containing terraform plans"
}
