variable "cluster_name" {
  description = "Name used to identify EKS IAM roles"
  type        = string
}

variable "tags" {
  description = "Tags applied to EKS IAM roles"
  type        = map(string)
  default     = {}
}
