locals {
  project     = "platform"
  environment = terraform.workspace == "default" ? "prod" : terraform.workspace
  prefix      = "${local.environment}-${local.project}"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "terraform"
    Workspace   = terraform.workspace
  }
}
