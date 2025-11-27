terraform {
    required_version = ">= 1.0"
    required_provided {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider = "aws" {
    region = var.aws_region
}

locals {
    common_tags = {
        Project = "DevOps Assessment"
        Environment = var.environment
        ManagedBy = "Terraform"
    }
}

module "vpc" {
    source = "./modules/vpc"
    
    vpc_cidr = var.vpc_cidr
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    availability_zones   = var.availability_zones
    environment          = var.environment
    tags                 = local.common_tags
}

module "ec2" {
    source = "./modules/ec2"

    vpc_id            = module.vpc.vpc_id
    subnet_id         = module.vpc.public_subnet_ids[0]
    instance_type     = var.ec2_instance_type
    key_name          = var.key_name
    environment       = var.environment
    allowed_ssh_cidrs = var.allowed_ssh_cidrs
    tags              = local.common_tags 
}

module "rds" {
    source = "./modules/rds"
    
    vpc_id               = module.vpc.vpc_id
    subnet_ids           = module.vpc.private_subnet_ids[0]
    db_name              = var.db_name
    db_username          = var.db_username
    db_password          = var.db_password
    allocated_storage    = var.db_allocated_storage
    environment          = var.environment
    allowed_sg_ids       = [module.ec2.security_group_id]
    tags                 = local.common_tags 
}