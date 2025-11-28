terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Local values for reuse
locals {
  common_tags = {
    Project     = "DevOps Assessment"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Iniemem Udosen"
  }

  # Compute availability zones
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

# Data source for available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = local.azs
  environment          = var.environment
  tags                 = local.common_tags
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.public_subnet_ids[0]
  instance_type     = var.ec2_instance_type
  ami_id            = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  key_name          = var.key_name
  environment       = var.environment
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  tags              = local.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  engine                = var.db_engine
  engine_version        = var.db_engine_version
  multi_az              = var.db_multi_az
  backup_retention_days = var.db_backup_retention_days
  environment           = var.environment
  allowed_sg_ids        = [module.ec2.security_group_id]
  tags                  = local.common_tags
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}