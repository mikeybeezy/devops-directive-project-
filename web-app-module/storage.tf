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
