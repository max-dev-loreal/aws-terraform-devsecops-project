variable "region" {
  default = "eu-north-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "db_instance_class" {
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
  default     = ["0.0.0.0/0"]
}

variable "db_password" {
  type        = string
  description = "DB password stored in Secrets Manager and used for RDS."
  sensitive   = true
  default     = "StrongPassword123!"
}