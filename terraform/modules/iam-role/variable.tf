variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "trusted_account_id" {
  description = "AWS account ID trusted to assume this role"
  type        = string
}