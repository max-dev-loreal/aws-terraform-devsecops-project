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

  tags = {
    Name        = "webapp-prod"
    Environment = "prod"
    Project     = "platform"
    ManagedBy   = "terraform"
  }
}
