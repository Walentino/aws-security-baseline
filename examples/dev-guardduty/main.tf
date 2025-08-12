module "guardduty" {
  # Adjust the path if your tree differs; this assumes examples/ and infra/ are siblings.
  source = "../../infra/modules/guardduty-baseline"

  # Feature toggles
  enable_s3_protection          = true
  enable_eks_audit_logs         = false
  enable_ebs_malware_protection = true

  # Leave these empty to SKIP S3 export of findings for now
  findings_bucket_arn = ""
  kms_key_arn         = ""

  tags = {
    Project = "aws-security-baseline"
    Env     = "dev"
  }
}

output "detector_id" {
  value = module.guardduty.detector_id
}

