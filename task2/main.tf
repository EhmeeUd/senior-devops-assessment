terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# suffix for resource names
resource "random_id" "assessment" {
  byte_length = 4
}

locals {
  common_tags = {
    Project     = "DevOps Assessment - Task 2"
    ManagedBy   = "Terraform"
    Owner       = "Iniemem Udosen"
    Security    = "High"
  }
  
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = local.azs
  enable_flow_logs     = true
  tags                 = local.common_tags
}

# Security Module (Security Groups, NACLs)
module "security" {
  source = "./modules/security"
  
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = var.vpc_cidr
  allowed_ssh_cidrs  = var.allowed_ssh_cidrs
  private_subnet_ids = module.vpc.private_subnet_ids
  tags               = local.common_tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  app_bucket_name = module.monitoring.app_bucket_name
  tags            = local.common_tags
}

# Monitoring Module (CloudTrail, CloudWatch, Config)
module "monitoring" {
  source = "./modules/monitoring"
  
  vpc_id           = module.vpc.vpc_id
  random_suffix    = random_id.assessment.hex
  account_id       = data.aws_caller_identity.current.account_id
  enable_aws_config = var.enable_aws_config
  tags             = local.common_tags
}


# Compute Module (EC2 in Private Subnet)
module "compute" {
  source = "./modules/compute"
  
  vpc_id                = module.vpc.vpc_id
  private_subnet_id     = module.vpc.private_subnet_ids[0]
  public_subnet_id      = module.vpc.public_subnet_ids[0]
  instance_type         = var.instance_type
  ami_id                = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  key_name              = var.key_name
  iam_instance_profile  = module.iam.ec2_instance_profile_name
  private_sg_id         = module.security.private_ec2_sg_id
  bastion_sg_id         = module.security.bastion_sg_id
  allowed_ssh_cidrs     = var.allowed_ssh_cidrs
  kms_key_id            = module.monitoring.kms_key_id
  tags                  = local.common_tags
}

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