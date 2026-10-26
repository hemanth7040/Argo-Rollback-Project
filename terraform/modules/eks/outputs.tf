output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Security group created for the EKS cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_role_arn" {
  description = "IAM role ARN for EKS worker nodes"
  value       = module.iam.node_role_arn
}

output "node_group_name" {
  description = "Name of the EKS managed node group"
  value       = aws_eks_node_group.this.node_group_name
}

output "node_group_status" {
  description = "Status of the EKS managed node group"
  value       = aws_eks_node_group.this.status
}
