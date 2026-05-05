variable "name_prefix" {
  type        = string
  description = "Prefix used for Name tags."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources."
  default     = {}
}

variable "region" {
  type        = string
  description = "AWS region."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for interface endpoint ENIs."
}

variable "security_group_id" {
  type        = string
  description = "Security group applied to endpoint ENIs."
}

