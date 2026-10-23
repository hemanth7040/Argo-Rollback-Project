resource "aws_security_group" "this" {
  name        = var.app_security_group_name
  description = "Security group for application instances"
  vpc_id      = var.vpc_id

  # Allow application traffic only from the ALB
  ingress {
    description     = "Allow HTTP traffic from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # Allow outbound traffic
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.app_security_group_name
  }
}