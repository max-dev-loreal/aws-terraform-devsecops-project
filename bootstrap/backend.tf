provider "aws" {
  region = "eu-north-1"
}

# S3 bucket for terraform state
resource "aws_s3_bucket" "tf_state" {
  bucket = "sqlshark-terraform-state-bucket"

  tags = {
    Name = "tf-state"
  }
}

# versioning
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB for locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}