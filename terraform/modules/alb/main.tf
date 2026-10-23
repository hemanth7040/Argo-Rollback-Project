resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"

  security_groups = [var.security_group_id]

  subnets = values(var.public_subnet_ids)

  enable_deletion_protection = false

  tags = {
    Name = var.alb_name
  }
}