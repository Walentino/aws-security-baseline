module "iam_baseline" {
  source = "../.."

  tags = {
    Project = "aws-security-baseline"
    Env     = "dev"
  }
}

output "break_glass_role_arn" {
  value = module.iam_baseline.break_glass_role_arn
}

