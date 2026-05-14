data "aws_caller_identity" "current" {}

locals {
  ecr_repo_arn = "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/webapp-prod"
  ecr_registry = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"

  app_user_data = base64encode(<<EOF
#!/bin/bash
set -e

# Install AWS CLI
apt-get update -y
apt-get install -y curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install Docker
apt-get install -y docker.io
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu || true

# Login to ECR
aws ecr get-login-password --region ${var.region} | \
  docker login --username AWS --password-stdin ${local.ecr_registry}

# Pull and run
docker pull ${local.ecr_registry}/webapp-prod:${var.app_image_tag}

docker run -d \
  --name app \
  -p 80:8000 \
  -e APP_VERSION=${var.app_image_tag} \
  -e DEPLOY_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
  -e ENVIRONMENT=${local.environment} \
  --restart always \
  ${local.ecr_registry}/webapp-prod:${var.app_image_tag}
EOF
  )
}

module "network" {
  source = "./modules/network"

  name_prefix = local.prefix
  tags        = local.common_tags
  region      = var.region

  azs = ["${var.region}a", "${var.region}b"]

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  db_subnet_cidrs      = ["10.0.20.0/24", "10.0.21.0/24"]
}

module "security" {
  source = "./modules/security"

  name_prefix = local.prefix
  tags        = local.common_tags
  vpc_id      = module.network.vpc_id

  bastion_ssh_cidrs = var.bastion_ssh_cidrs
}

module "secrets" {
  source = "./modules/secrets"

  name_prefix = local.prefix
  tags        = local.common_tags

  secret_name             = "rds-master-credentials-${local.environment}-v2"
  recovery_window_in_days = 7
  secret_string_json = jsonencode({
    username = "postgres"
    password = var.db_password
  })
}

module "iam" {
  source = "./modules/iam"

  role_name             = "${local.environment}-platform-ec2-role"
  instance_profile_name = "${local.environment}-platform-ec2-profile"
  secret_arn            = module.secrets.secret_arn
  ecr_repository_arn    = local.ecr_repo_arn
}

module "alb" {
  source = "./modules/alb"

  name_prefix           = local.prefix
  tags                  = local.common_tags
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security.alb_sg_id
  target_port           = 80
  healthcheck_path      = "/health"
  certificate_arn       = var.certificate_arn
}

module "compute" {
  source = "./modules/compute"

  name_prefix = local.prefix
  tags        = local.common_tags

  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  instance_profile_name     = module.iam.instance_profile_name
  private_security_group_id = module.security.private_sg_id
  bastion_security_group_id = module.security.bastion_sg_id
  public_subnet_ids         = module.network.public_subnet_ids
  private_subnet_ids        = module.network.private_subnet_ids
  target_group_arn          = module.alb.target_group_arn
  user_data_base64          = local.app_user_data
}

module "endpoints" {
  source = "./modules/endpoints"

  name_prefix = local.prefix
  tags        = local.common_tags

  region            = var.region
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.private_subnet_ids
  security_group_id = module.security.private_sg_id
}

module "rds" {
  source = "./modules/rds"

  name_prefix          = local.prefix
  tags                 = local.common_tags
  db_subnet_ids        = module.network.db_subnet_ids
  db_security_group_id = module.security.db_sg_id

  instance_class = var.db_instance_class
  password       = var.db_password
}

module "monitoring" {
  source = "./modules/monitoring"

  name_prefix = local.prefix
  asg_name    = module.compute.asg_name
}

module "lambda_bot" {
  source = "./modules/lambda_bot"

  name_prefix           = local.prefix
  telegram_bot_token    = var.telegram_bot_token
  telegram_chat_id      = var.telegram_chat_id
  github_owner          = var.github_owner
  github_repo           = var.github_repo
  github_pat_secret_arn = var.github_pat_secret_arn
  plans_s3_bucket       = "tfplans-platform-prod-${data.aws_caller_identity.current.account_id}"
}

resource "aws_ecr_repository" "webapp" {
  name                 = "webapp-prod"
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.common_tags
}
