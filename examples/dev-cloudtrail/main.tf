resource "random_id" "suffix" {
  byte_length = 4
}

# Optional KMS CMK for log encryption (reuses your module)
module "kms" {
  source     = "../../infra/modules/kms-cmk"
  alias_name = "nino-cloudtrail-cmk-${random_id.suffix.hex}"
}

module "cloudtrail" {
  source      = "../../infra/modules/cloudtrail-baseline"
  trail_name  = "account-trail"
  bucket_name = "nino-cloudtrail-logs-${random_id.suffix.hex}"
  kms_key_arn = module.kms.key_arn

  tags = {
    Project = "aws-security-baseline"
    Env     = "dev"
  }
}

output "trail_arn" { value = module.cloudtrail.trail_arn }
output "bucket_name" { value = module.cloudtrail.bucket_name }

