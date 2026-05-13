provider "aws" {
  region = "eu-north-1"
}

locals {
  account_id = "103242399399"
}

# ─── State Bucket ───
resource "aws_s3_bucket" "tf_state" {
  bucket = "tfstate-platform-prod-${local.account_id}"

  tags = {
    Name        = "terraform-state-prod"
    Environment = "prod"
    Project     = "platform"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ─── Plans Bucket ───
resource "aws_s3_bucket" "tf_plans" {
  bucket = "tfplans-platform-prod-${local.account_id}"

  tags = {
    Name        = "terraform-plans-prod"
    Environment = "prod"
    Project     = "platform"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "tf_plans" {
  bucket                  = aws_s3_bucket.tf_plans.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_plans" {
  bucket = aws_s3_bucket.tf_plans.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tf_plans" {
  bucket = aws_s3_bucket.tf_plans.id
  rule {
    id     = "expire-plans"
    status = "Enabled"
    expiration {
      days = 7
    }
    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}

# ─── DynamoDB Lock ───
resource "aws_dynamodb_table" "tf_lock" {
  name         = "platform-prod-tflock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-lock-prod"
    Environment = "prod"
    Project     = "platform"
    ManagedBy   = "terraform"
  }
}
