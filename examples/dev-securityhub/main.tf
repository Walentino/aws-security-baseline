module "securityhub" {
  source       = "../../infra/modules/securityhub-baseline"
  aws_region   = var.aws_region
  enable_afsbp = true
}

