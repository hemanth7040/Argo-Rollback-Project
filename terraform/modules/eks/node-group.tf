resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = module.iam.node_role_arn
  subnet_ids      = var.private_subnet_ids

  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = var.tags

  depends_on = [
    module.iam,
    aws_eks_cluster.this
  ]
}
