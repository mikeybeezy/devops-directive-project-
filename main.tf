terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-dev-b"
    key            = "environment/dev/terraform.tfstate"
    dynamodb_table = "terraform-locks"
    region         = "eu-west-1"
    encrypt        = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "terraform-dev-b" {
  bucket        = "terraform-dev-b"
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


resource "aws_instance" "instance_1" {
  ami             = "ami-01cae1550c0adea9c" # eu-west-1
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instances_sg.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World 1" > index.html
              python3 -m http.server 8080 &
              EOF

}

resource "aws_instance" "instance_2" {
  ami             = "ami-01cae1550c0adea9c" # eu-west-1
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instances_sg.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World 1" > index.html
              python3 -m http.server 8080 &
              EOF

}



data "aws_vpc" "default_vpc" {
  default = true
}


data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id

}

resource "aws_security_group" "instances_sg" {
  name = "instances-sg"

}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instances_sg.id
}
