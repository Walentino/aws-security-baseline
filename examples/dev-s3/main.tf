# random suffix so bucket name is globally unique
resource "random_id" "suffix" {
  byte_length = 4
}

# KMS CMK for the bucket
module "secure_kms" {
  source     = "../../infra/modules/kms-cmk"
  alias_name = "nino-dev-logs-cmk"

  tags = {
    Project = "aws-security-baseline"
    Env     = "dev"
  }
}

# Secure S3 logs bucket using the module
module "logs_bucket" {
  source      = "../../infra/modules/s3-secure-bucket"
  bucket_name = "nino-dev-logs-${random_id.suffix.hex}"
  kms_key_arn = module.secure_kms.key_arn # remove this line if you want SSE-S3 instead

  tags = {
    Project = "aws-security-baseline"
    Env     = "dev"
  }
}

