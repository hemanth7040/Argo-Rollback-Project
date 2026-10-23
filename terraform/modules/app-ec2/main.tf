resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = false
  iam_instance_profile        = var.iam_instance_profile_name

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
    dnf install -y python3
    mkdir -p /opt/app
    cat > /opt/app/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
      <head><title>DevOps Project</title></head>
      <body>
        <h1>Application is running!</h1>
        <p>Request served through the AWS Application Load Balancer.</p>
      </body>
    </html>
    HTML

    cat > /etc/systemd/system/devops-app.service <<'SERVICE'
    [Unit]
    Description=DevOps Project Web Application
    After=network.target

    [Service]
    Type=simple
    WorkingDirectory=/opt/app
    ExecStart=/usr/bin/python3 -m http.server 8080 --bind 0.0.0.0
    Restart=always

    [Install]
    WantedBy=multi-user.target
    SERVICE

    systemctl daemon-reload
    systemctl enable --now devops-app
  EOF

  tags = {
    Name = var.instance_name
  }
}