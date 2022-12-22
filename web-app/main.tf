


terraform {

  backend "s3" {
    bucket         = "terraform-dev-b"
    key            = "environment/dev/terraform.tfstate"
    dynamodb_table = "terraform-locks"
    region         = "eu-west-1"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

}

variable "db_pass_1" {
  description = "db password"
  type        = string
  sensitive   = true

}


variable "db_pass_2" {
  description = "db password"
  type        = string
  sensitive   = true

}


module "web_app_1" {
  source = "../web-app-module"

  #input  variables

  bucket_name      = "devopsdeploy-bucket-web-app-1"
  domain           = "scaletificdevops.com"
  app_name         = "web-app-1"
  environment_name = "dev"
  instance_type    = "t2.micro"
  create_dns_zone  = true
  db_name          = "webappdb1"
  db_pass          = var.db_pass_1
  db_user          = "foo"

}



module "web_app_2" {
  source = "../web-app-module"

  #input  variables

  bucket_name      = "devopsdeploy-bucket-web-app-2"
  domain           = "scaletificdevops.com"
  app_name         = "web-app-1"
  environment_name = "dev"
  instance_type    = "t2.micro"
  create_dns_zone  = true
  db_name          = "webappdb1"
  db_pass          = var.db_pass_2
  db_user          = "foo"

}


# Route53 zone is shared across staging and production
resource "aws_route53_zone" "primary" {
  name = "devopsdeployed.com"
}

