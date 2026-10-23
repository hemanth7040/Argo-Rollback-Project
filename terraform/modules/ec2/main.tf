resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile = var.iam_instance_profile

  user_data = <<-EOF
  #!/bin/bash
  set -euxo pipefail

  exec > >(tee /var/log/ssm-bootstrap.log) 2>&1

  dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

  systemctl enable amazon-ssm-agent
  systemctl start amazon-ssm-agent

  systemctl status amazon-ssm-agent --no-pager
EOF

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = var.instance_name
  }
}