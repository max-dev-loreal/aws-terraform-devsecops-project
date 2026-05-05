variable "name_prefix" {
  type        = string
  description = "Prefix used for resource names."
}

variable "asg_name" {
  type        = string
  description = "Autoscaling group name to attach alarms/policies to."
}

variable "high_cpu_threshold" {
  type    = number
  default = 70
}

variable "low_cpu_threshold" {
  type    = number
  default = 30
}

