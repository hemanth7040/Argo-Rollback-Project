variable "security_group_name" {
  description = "Name of the EC2 security group"
  type        = string
}

variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}