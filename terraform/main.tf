module "vpc" {
  source = "./modules/vpc"

  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
}

module "iam_role" {
  source = "./modules/iam-role"

  role_name          = var.role_name
  trusted_account_id = var.trusted_account_id
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "app_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "security_group" {
  source = "./modules/security-group"

  security_group_name = var.security_group_name
  vpc_id              = data.aws_vpc.default.id
}


module "ec2_ssm_role" {
  source = "./modules/ec2-ssm-role"

  role_name = var.ec2_ssm_role_name
}

# ALB Security Group
module "alb_security_group" {
  source = "./modules/alb-security-group"

  vpc_id              = module.vpc.vpc_id
  security_group_name = var.alb_security_group_name
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"

  alb_name          = "devops-project-alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.alb_security_group.security_group_id
  app_instance_id   = module.app_ec2.instance_id
}

# Application Security Group
module "app_security_group" {
  source = "./modules/app-security-group"

  vpc_id                  = module.vpc.vpc_id
  app_security_group_name = "devops-project-app-sg"
  alb_security_group_id   = module.alb_security_group.security_group_id
}

# Application EC2 Instance
module "app_ec2" {
  source = "./modules/app-ec2"

  instance_name             = "devops-project-app"
  ami_id                    = data.aws_ami.app_amazon_linux.id
  instance_type             = "t3.micro"
  subnet_id                 = module.vpc.private_subnet_ids["private_a"]
  security_group_id         = module.app_security_group.security_group_id
  iam_instance_profile_name = module.ec2_ssm_role.instance_profile_name
}

# Amazon ECR Repository
module "ecr" {
  source = "./modules/ecr"

  repository_name = "devops-project-app"
}
# Amazon EKS Cluster
module "eks" {
  source = "./modules/eks"

  cluster_name       = "devops-project-eks"
  kubernetes_version = "1.36"

  private_subnet_ids = values(module.vpc.private_subnet_ids)

  tags = {
    Project     = "DevOps-Rollback-Project"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
