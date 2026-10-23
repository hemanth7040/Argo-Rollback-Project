resource "aws_iam_role" "terraform_lab" {
  name        = var.role_name
  description = "IAM role for AWS DevOps hands-on practice"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"

      Principal = {
        AWS = "arn:aws:iam::${var.trusted_account_id}:root"
      }
    }]
  })
}

resource "aws_iam_role_policy" "terraform_lab_policy" {
  name = "terraform-lab-rolePolicy"
  role = aws_iam_role.terraform_lab.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets"
        ]

        Resource = "*"
      }
    ]
  })
}