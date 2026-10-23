resource "aws_security_group" "this" {
  name        = var.security_group_name
  description = "Security group for Terraform EC2 lab"
  vpc_id      = var.vpc_id

  # No inbound rules for the initial lab.

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}