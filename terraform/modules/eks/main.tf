resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = module.iam.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = var.tags

  depends_on = [
    module.iam
  ]
}

module "iam" {
  source = "./iam"

  cluster_name = var.cluster_name
  tags         = var.tags
}
