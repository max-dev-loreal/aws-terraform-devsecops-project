locals {
  project     = "devsecops-portfolio"
  environment = "dev"

  prefix = "${local.environment}-${local.project}"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}