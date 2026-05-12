terraform {
  backend "s3" {
    bucket         = "tfstate-platform-prod-103242399399"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-north-1"
    use_lockfile = true
    encrypt        = true
  }
}
