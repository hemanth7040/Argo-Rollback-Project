variable "vpc_name" {
  description = "Name of the custom VPC"
  type        = string
  default     = "devops-project-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones for the custom VPC"
  type        = set(string)
  default     = ["ap-south-2a", "ap-south-2b"]
}


variable "public_subnets" {
  description = "Public subnet configurations"

  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    public_a = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "ap-south-2a"
    }

    public_b = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "ap-south-2b"
    }
  }
}

variable "private_subnets" {
  description = "Private subnet configurations"

  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    private_a = {
      cidr_block        = "10.0.11.0/24"
      availability_zone = "ap-south-2a"
    }

    private_b = {
      cidr_block        = "10.0.12.0/24"
      availability_zone = "ap-south-2b"
    }
  }
}

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = "terraform-lab-role"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-2"
}

variable "trusted_account_id" {
  description = "AWS account ID trusted to assume this role"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "terraform-lab"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "security_group_name" {
  description = "Name of the EC2 security group"
  type        = string
  default     = "terraform-lab-sg"
}

variable "ec2_ssm_role_name" {
  description = "Name of the IAM role for EC2 Systems Manager"
  type        = string
  default     = "terraform-lab-ssm-role"
}

variable "alb_security_group_name" {
  description = "Name of the ALB security group"
  type        = string
  default     = "devops-project-alb-sg"
}
