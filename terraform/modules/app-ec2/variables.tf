variable "instance_name" {
  description = "Name of the application EC2 instance"
  type        = string
  default     = "devops-project-app"
}

variable "ami_id" {
  description = "AMI ID for the application EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Private subnet ID for the application EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "Application security group ID"
  type        = string
}
variable "iam_instance_profile_name" {
  description = "IAM instance profile for SSM access"
  type        = string
}