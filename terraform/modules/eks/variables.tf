variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.36"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to EKS resources"
  type        = map(string)
  default     = {}
}
