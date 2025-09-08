############################################
# Terraform & Provider Configuration
############################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

############################################
# Data Sources
############################################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

############################################
# Random Suffix for Resource Names
############################################

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

############################################
# Local Variables
############################################

locals {
  # VPC 1 Configuration
  name      = "cltest1"
  base_name = "${local.name}-${random_string.suffix.result}"

  # Common tags
  suffix = random_string.suffix.result

  tags = {
    Environment = "dev"
  }
}

# Get current user's public IP
data "http" "my_public_ip" {
  url = "https://checkip.amazonaws.com/"
}

############################################
# VPC Configuration
############################################

module "vpc" {
  source = "cloudbuildlab/vpc/aws"

  vpc_name           = local.base_name
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Enable Internet Gateway & NAT Gateway
  create_igw       = true
  nat_gateway_type = "single"

  tags = local.tags
}

############################################
# Security Groups
############################################

resource "aws_security_group" "jumphost_sg" {
  name        = "${local.base_name}-jumphost-sg"
  description = "Security group for jumphost"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.base_name}-jumphost-sg"
  })
}

resource "aws_security_group" "lambda_sg" {
  name        = "${local.base_name}-lambda-sg"
  description = "Security group for lambda"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = module.vpc.private_subnet_cidrs
  }

  egress {
    description = "HTTPS to AWS services"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP to AWS services"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS resolution"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.base_name}-jumphost-sg"
  })
}

############################################
# Jumphosts
############################################

module "jumphost" {
  source = "tfstack/jumphost/aws"

  name      = "${local.base_name}-jumphost"
  subnet_id = module.vpc.private_subnet_ids[0]
  vpc_id    = module.vpc.vpc_id

  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.jumphost_sg.id]
  allowed_cidr_blocks    = ["${trimspace(data.http.my_public_ip.response_body)}/32"]
  assign_eip             = false

  user_data_extra = <<-EOT
    hostname ${local.base_name}-jumphost
    yum install -y mtr nc
  EOT

  tags = local.tags
}

############################################
# Lambda Function
############################################

# Convert code to zip file
data "archive_file" "vpc_test" {
  type        = "zip"
  output_path = "${path.module}/external/vpc-connectivity-test.zip"

  source {
    content  = file("${path.module}/external/lambda/vpc-connectivity-test.js")
    filename = "vpc-connectivity-test.js"
  }
}

module "s3_bucket" {
  source = "tfstack/s3/aws"

  bucket_name       = "lambda-zips"
  bucket_suffix     = random_string.suffix.result
  enable_versioning = true

  tags = local.tags
}

resource "aws_s3_object" "vpc_test" {
  bucket = module.s3_bucket.bucket_id
  key    = "vpc-connectivity-test.zip"
  source = data.archive_file.vpc_test.output_path
  etag   = data.archive_file.vpc_test.output_md5
}

module "lambda" {
  source = "../../"

  function_name = "vpc-connectivity-test-${random_string.suffix.result}"
  handler       = "vpc-connectivity-test.handler"
  runtime       = "nodejs20.x"

  s3_bucket         = module.s3_bucket.bucket_id
  s3_key            = aws_s3_object.vpc_test.key
  s3_object_version = aws_s3_object.vpc_test.version_id

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  environment_variables = {
    ENVIRONMENT = local.tags.Environment
  }

  vpc_config = {
    vpc_id             = module.vpc.vpc_id
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  # Enable Function URL for HTTP access
  create_function_url = true

  tags = local.tags
}
output "lambda" {
  value = module.lambda
}
