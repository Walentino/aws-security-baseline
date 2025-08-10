module "secure_bucket" {
  source      = "./infra/modules/s3-secure-bucket"
  bucket_name = var.bucket_name
}

