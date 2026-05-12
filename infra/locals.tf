locals {
  project     = "platform"
  environment = "prod"
  prefix      = "${local.environment}-${local.project}"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}
