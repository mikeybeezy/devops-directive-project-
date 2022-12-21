terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  #   backend "s3" {
  #     bucket         = "terraform-dev-b"
  #     key            = "environment/dev/terraform.tfstate"
  #     dynamodb_table = "terraform-locks"
  #     region         = "eu-west-1"
  #     encrypt        = true
  #   }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "terraform-dev-b" {
  bucket        = var.bucket_name
  force_destroy = "true"
}


#Bucket Versioning 
resource "aws_s3_bucket_acl" "terraform-dev-b-acl" {
  bucket = aws_s3_bucket.terraform-dev-b.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "terraform-dev-b-versioning" {
  bucket = aws_s3_bucket.terraform-dev-b.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Bucket Encryption 
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-dev-b-encryption" {
  bucket = aws_s3_bucket.terraform-dev-b.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Dynamodb 
resource "aws_dynamodb_table" "terraform-locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

}

