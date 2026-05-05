variable "name_prefix" {
  type        = string
  description = "Prefix used for Name tags."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources."
  default     = {}
}

variable "ami_id" {
  type        = string
  description = "AMI ID."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name."
}

variable "instance_profile_name" {
  type        = string
  description = "IAM instance profile name for app instances."
}

variable "private_security_group_id" {
  type        = string
  description = "Security group for private app instances."
}

variable "bastion_security_group_id" {
  type        = string
  description = "Security group for bastion."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs (first used for bastion)."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for ASG."
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group ARN."
}

variable "user_data_base64" {
  type        = string
  description = "Base64-encoded user data script."
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

