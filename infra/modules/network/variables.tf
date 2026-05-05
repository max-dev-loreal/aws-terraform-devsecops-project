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
  description = "AWS region (used for endpoint service names)."
}

variable "azs" {
  type        = list(string)
  description = "Two availability zones."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Two CIDR blocks for public subnets."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Two CIDR blocks for private subnets."
}

variable "db_subnet_cidrs" {
  type        = list(string)
  description = "Two CIDR blocks for DB subnets."
}

