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


resource "aws_instance" "instance_1" {
  ami             = var.ami # eu-west-1
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instances_sg.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World 1" > index.html
              python3 -m http.server 8080 &
              EOF

}

resource "aws_instance" "instance_2" {
  ami             = var.ami # eu-west-1
  instance_type   = var.instance_type
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


# data "aws_subnets" "default_subnet" {
#   vpc_id = data.aws_vpc.default_vpc.id

# }


data "aws_subnets" "default_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
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


#Loadblalancer 

resource "aws_lb" "web_app_front_end_lb" {
  name               = "web-app-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default_subnet.ids
  security_groups    = [aws_security_group.alb_sg.id]
}

#Loadblalancer Target Group
resource "aws_lb_target_group" "web_app_lb_target_group" {
  name     = "web-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {
    port                = 80
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#Loadblalancer Listner
resource "aws_lb_listener" "web_app_front_end_lb_listner" {
  load_balancer_arn = aws_lb.web_app_front_end_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = "404"
    }
  }
}


#Loadblalancer Targets
resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.web_app_lb_target_group.arn
  target_id        = aws_instance.instance_1.id
  port             = 8080
}



resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.web_app_lb_target_group.arn
  target_id        = aws_instance.instance_2.id
  port             = 8080
}

#Loadblalancer Listner Rule
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.web_app_front_end_lb_listner.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_lb_target_group.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_lb_target_group.arn
  }
}

#ALB security Groups
resource "aws_security_group" "alb_sg" {
  name = "alb-security-group"

}

resource "aws_security_group_rule" "alb_sg_rule_ingress" {
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "alb_sg_rule_egress" {
  from_port         = 0
  to_port           = 0
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_sg.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]

}


resource "aws_db_instance" "db_instance" {
  allocated_storage = 20
  # This allows any minor version within the major engine_version
  # defined below, but will also result in allowing AWS to auto
  # upgrade the minor version of your DB. This may be too risky
  # in a real production environment.
  auto_minor_version_upgrade = true
  storage_type               = "standard"
  engine                     = "postgres"
  engine_version             = "12"
  instance_class             = "db.t2.micro"
  db_name                    = var.db_name
  username                   = var.db_user
  password                   = var.db_pass
  skip_final_snapshot        = true
}
