# infra/envs/dev/s3.tf

resource "random_id" "suffix" {
  byte_length = 4
}

module "secure_kms" {
  source     = "../../modules/kms-cmk"
  alias_name = "nino-dev-logs-cmk"

  tags = {
    Project = "aws-security-baseline"
    Env     = "dev"
  }
}

module "logs_bucket" {
  source      = "../../modules/s3-secure-bucket"
  bucket_name = "nino-dev-logs-${random_id.suffix.hex}"

  # Use the CMK we just created. If you want to keep it optional, delete this line.
  kms_key_arn = module.secure_kms.key_arn
}

