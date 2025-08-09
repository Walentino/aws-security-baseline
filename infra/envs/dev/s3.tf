module "logs_bucket" {
  source        = "../../modules/s3-secure-bucket"
  bucket_name   = "nino-dev-logs-${random_id.suffix.hex}"
  versioning    = true
  force_destroy = false
}

resource "random_id" "suffix" {
  byte_length = 4
}

