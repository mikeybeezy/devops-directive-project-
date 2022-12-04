terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-dev-bucket-a"
    key            = "environment/dev/terraform.tfstate"
    dynamodb_table = "terraform-locks"
    region         = "eu-west-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "terraform-dev-bucket-a" {
  bucket        = "terraform-dev-bucket-a"
  force_destroy = "true"
}


#Bucket Versioning 
resource "aws_s3_bucket_acl" "terraform-dev-bucket-a-acl" {
  bucket = aws_s3_bucket.terraform-dev-bucket-a.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "terraform-dev-bucket-a-versioning" {
  bucket = aws_s3_bucket.terraform-dev-bucket-a.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Bucket Encryption 
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-dev-bucket-a-encryption" {
  bucket = aws_s3_bucket.terraform-dev-bucket-a.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Dynamodb 
resource "aws_dynamodb_table" "terraform-locks" {
  name         = "value"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

}

