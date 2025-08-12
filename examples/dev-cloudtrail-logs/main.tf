resource "random_id" "suffix" {
  byte_length = 4
}

# If you already have a KMS CMK module, reuse it.
# This module must output "key_arn".
module "cloudtrail_kms" {
  source     = "../../infra/modules/kms-cmk"
  alias_name = "nino-cloudtrail-cmk"
  tags = {
    Project = "aws-security-baseline"
    Env     = "dev"
  }
}

module "logs_bucket" {
  source                     = "../../infra/modules/s3-secure-bucket"
  bucket_name                = "nino-cloudtrail-logs-${random_id.suffix.hex}"
  kms_key_arn                = module.cloudtrail_kms.key_arn # or your KMS module output
  enable_cloudtrail_delivery = true
  force_destroy              = true
  tags = {
    Project = "aws-security-baseline"
    Env     = "dev"
  }
}

output "cloudtrail_logs_bucket_name" {
  value = module.logs_bucket.bucket_name
}

output "cloudtrail_kms_key_arn" {
  value = module.cloudtrail_kms.key_arn
}

