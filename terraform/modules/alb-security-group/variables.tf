variable "vpc_id" {
  description = "ID of the custom VPC for the ALB"
  type        = string
}

variable "security_group_name" {
  description = "Name of the ALB security group"
  type        = string
  default     = "devops-project-alb-sg"
}