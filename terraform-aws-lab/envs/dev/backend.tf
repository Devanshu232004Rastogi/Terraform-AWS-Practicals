terraform {
  backend "s3" {
    bucket       = "terraform-aws-labs-backend-01-10-2026-tfstate"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # S3 native locking (Terraform >= 1.10)
  }
}