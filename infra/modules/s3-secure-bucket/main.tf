#############################################
# S3 secure bucket (TLS-only + SSE)
#############################################

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}

# Default encryption: AES256 by default; use KMS if kms_key_arn is provided
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn == "" ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_arn == "" ? null : var.kms_key_arn
    }

    # S3 bucket key optimizes KMS costs; enable only when using CMK
    bucket_key_enabled = var.kms_key_arn != ""
  }
}

# Block all public access (account-level controls)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################################
# Bucket policy: TLS-only and encryption enforcement
# - Always deny non-TLS
# - Always deny incorrect SSE header (requires AES256 or aws:kms)
# - If KMS is used, also deny missing SSE and wrong KMS key
############################################################

locals {
  # Policies that apply in all cases
  base_statements = [
    {
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        "arn:aws:s3:::${aws_s3_bucket.this.id}",
        "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
      ]
      Condition = {
        Bool = { "aws:SecureTransport" = "false" }
      }
    },
    {
      Sid       = "DenyIncorrectEncryptionHeader"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:PutObject"
      Resource  = "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
      Condition = {
        StringNotEquals = {
          # If not using CMK, enforce AES256; if using CMK, enforce aws:kms
          "s3:x-amz-server-side-encryption" = var.kms_key_arn == "" ? "AES256" : "aws:kms"
        }
      }
    }
  ]

  # Extra statements only when a KMS CMK is supplied
  kms_statements = var.kms_key_arn == "" ? [] : [
    {
      Sid       = "DenyUnencryptedObjectUploads"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:PutObject"
      Resource  = "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
      Condition = {
        Null = { "s3:x-amz-server-side-encryption" = "true" }
      }
    },
    {
      Sid       = "DenyWrongKMSKey"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:PutObject"
      Resource  = "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
      Condition = {
        StringNotEquals = {
          "s3:x-amz-server-side-encryption-aws-kms-key-id" = var.kms_key_arn
        }
      }
    }
  ]

  bucket_policy_json = jsonencode({
    Version   = "2012-10-17"
    Id        = "S3BucketPolicy"
    Statement = concat(local.base_statements, local.kms_statements)
  })
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = local.bucket_policy_json
}

