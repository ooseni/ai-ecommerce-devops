# The S3 bucket that holds the main stack's Terraform state. Applied once, on its own,
# because a stack cannot create the bucket its own state lives in. Its own state stays local.
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region for the state bucket."
  type        = string
  default     = "us-east-1"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "state" {
  # Bucket names are global, so the account ID keeps this one unique.
  bucket = "ai-ecommerce-devops-tfstate-${data.aws_caller_identity.current.account_id}"

  # terraform destroy can then remove the bucket with its state versions at the very end.
  force_destroy = true
}

# Versioning keeps every earlier state, so a bad apply can be recovered from.
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket" {
  description = "Pass this to the main stack: terraform init -backend-config=bucket=<name>"
  value       = aws_s3_bucket.state.bucket
}
