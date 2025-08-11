output "break_glass_role_arn" {
  value       = aws_iam_role.break_glass.arn
  description = "ARN of the break-glass admin role (MFA required)."
}

