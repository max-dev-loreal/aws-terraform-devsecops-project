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

variable "bastion_ssh_cidrs" {
  type        = list(string)
  description = "Allowed CIDRs for SSH to bastion."
  default     = []
}

