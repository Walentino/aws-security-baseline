module "secure_bucket" {
  source      = "./infra/modules/s3-secure-bucket"
  bucket_name = var.bucket_name
  kms_key_id  = ""
  tags = {
    Project = "aws-security-baseline"
  }
}

