variable "name_prefix" {
  type        = string
  description = "Prefix used for resource names."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources."
  default     = {}
}

variable "alb_arn" {
  type        = string
  description = "ARN of the ALB to associate with the WAF."
}

variable "rate_limit" {
  type        = number
  description = "Requests per 5 minutes per IP"
  default     = 2000
}
