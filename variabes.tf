
# EC2 Variables 
variable "region" {
  description = ""
  type        = string
  default     = "us-east-1" #eu-west-1
}


variable "instance_name" {
  description = ""
  type        = string
}

variable "ami" {
  description = ""
  type        = string
  default     = "ami-01cae1550c0adea9c" # eu-west-1
}

variable "instance_type" {
  description = "description of instance type"
  type        = string
  default     = "t2.micro"
}

#RDS

variable "db_user" {
  description = "username for database"
  type        = string
  default     = "foo"
}


variable "db_pass" {
  description = "password for database"
  type        = string
  default     = true
}

variable "db_name" {
  description = "password for database"
  type        = string
  default     = "mydb"
}


variable "bucket_name" {
  description = "naem of s3 bucket"
  type        = string
}

# Route 53 Variables

variable "domain" {
  description = "Domain for Website"
  type        = string
}

# RDS Variables 



variable "environment_name" {
  description = "Name of environment"
  type        = string
  default     = "dev"
}


variable "app_name" {
  description = "name of app"
  type        = string
  default     = "web-app"
}

