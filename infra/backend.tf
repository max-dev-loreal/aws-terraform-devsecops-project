terraform {
  backend "s3" {
    bucket         = "sqlshark-terraform-state-bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}