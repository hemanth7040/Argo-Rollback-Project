variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "devops-project-alb"
}

variable "vpc_id" {
  description = "ID of the custom VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = map(string)
}

variable "security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "app_instance_id" {
  description = "ID of the application EC2 instance registered with the target group"
  type        = string
}