output "custom_vpc_id" {
  description = "ID of the custom VPC"
  value       = module.vpc.vpc_id
}

output "custom_vpc_cidr" {
  description = "CIDR block of the custom VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Map of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Map of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = module.iam_role.role_name
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = module.iam_role.role_arn
}

output "aws_account_id" {
  description = "AWS account ID used by Terraform"
  value       = data.aws_caller_identity.current.account_id
}


output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = module.security_group.security_group_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}
# EKS Cluster Outputs
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "Name of the EKS managed node group"
  value       = module.eks.node_group_name
}
