variable "vpc_name" {
  description = "Name of the custom VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the custom VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones for the VPC subnets"
  type        = list(string)
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