variable "vpc_id" {
  description = "ID of the custom VPC"
  type        = string
}

variable "app_security_group_name" {
  description = "Name of the application security group"
  type        = string
  default     = "devops-project-app-sg"
}

variable "alb_security_group_id" {
  description = "Security group ID of the Application Load Balancer"
  type        = string
}