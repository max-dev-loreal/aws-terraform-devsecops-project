provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "sqlshark-terraform-state-bucket"
  tags = {
    Name = "tf-state"
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

resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "tf_plans" {
  bucket = "sqlshark-terraform-plans"
  tags = {
    Name = "tf-plans"
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
  }
}
