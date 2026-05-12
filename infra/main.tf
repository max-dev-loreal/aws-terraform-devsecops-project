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

  secret_name             = "db-password"
  recovery_window_in_days = 0
  secret_string_json = jsonencode({
    username = "postgres"
    password = var.db_password
  })
}

module "iam" {
  source = "./modules/iam"

  role_name             = "ec2-secrets-role"
  instance_profile_name = "ec2-profile"
  secret_arn            = module.secrets.secret_arn
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
}

locals {
  app_user_data = base64encode(<<EOF
#!/bin/bash
yum update -y

# Install and enable Docker (Amazon Linux 2)
yum install -y docker
systemctl enable docker
systemctl start docker

# Allow the default user to run docker without sudo
usermod -aG docker ec2-user || true
EOF
  )
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
  github_owner          = "max-dev-loreal"
  github_repo           = "High-Availability-Cloud-Architecture-IaC"
  github_pat_secret_arn = "arn:aws:secretsmanager:eu-north-1:103242399399:secret:github-terraform-bot-pat-phnqN3"
}
