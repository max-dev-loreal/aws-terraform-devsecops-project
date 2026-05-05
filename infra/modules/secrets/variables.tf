variable "name_prefix" {
  type        = string
  description = "Prefix used for Name tags."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources."
  default     = {}
}

variable "secret_name" {
  type        = string
  description = "Secrets Manager secret name."
  default     = "db-password"
}

variable "recovery_window_in_days" {
  type        = number
  description = "Recovery window in days."
  default     = 0
}

variable "secret_string_json" {
  type        = string
  description = "JSON string to store as secret value."
  sensitive   = true
}

