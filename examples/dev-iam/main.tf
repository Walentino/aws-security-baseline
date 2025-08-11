resource "aws_iam_user" "this" {
  name = var.iam_user_name
  tags = {
    Project = "aws-security-baseline"
    Env     = "dev"
  }
}

resource "aws_iam_user_policy" "readonly" {
  name = "ReadOnlyAccess"
  user = aws_iam_user.this.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

