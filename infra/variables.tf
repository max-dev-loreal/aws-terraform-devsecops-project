variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances."
  default     = "ami-0c1ac8a41498c1a9c"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name."
  default     = "stockholm-max-key"
}

variable "bastion_ssh_cidrs" {
  type        = list(string)
  description = "Allowed CIDRs for SSH to the bastion host."
  default     = []
}

variable "db_password" {
  type        = string
  description = "DB password stored in Secrets Manager and used for RDS."
  sensitive   = true
}

variable "telegram_bot_token" {
  type        = string
  description = "Telegram bot token for Lambda"
  sensitive   = true
  default     = ""
}

variable "telegram_chat_id" {
  type        = string
  description = "Telegram chat ID for Lambda"
  default     = ""
}

variable "app_image_tag" {
  type        = string
  description = "Docker image tag to deploy on EC2"
  default     = "latest"
}

variable "github_pat_secret_arn" {
  type        = string
  description = "ARN of GitHub PAT secret in Secrets Manager"
  sensitive   = true
}

variable "github_owner" {
  type        = string
  description = "GitHub repository owner"
  default     = "max-dev-loreal"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
  default     = "High-Availability-Cloud-Architecture-IaC-"
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS ALB listener"
  default     = ""
}
