terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  tags       = var.tags
  bucket_arn = "arn:aws:s3:::${var.bucket_name}"
}

# S3 bucket for CloudTrail logs (private, versioned, SSE)
resource "aws_s3_bucket" "logs" {
  bucket = var.bucket_name
  tags   = local.tags
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn == "" ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_arn == "" ? null : var.kms_key_arn
    }
    bucket_key_enabled = var.kms_key_arn != ""
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy: TLS-only + CloudTrail write permissions
locals {
  bucket_policy_json = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Force TLS
      {
        Sid : "DenyInsecureTransport",
        Effect : "Deny",
        Principal : "*",
        Action : "s3:*",
        Resource : [
          local.bucket_arn,
          "${local.bucket_arn}/*"
        ],
        Condition : { Bool : { "aws:SecureTransport" : "false" } }
      },
      # CloudTrail needs to read bucket ACL
      {
        Sid : "AWSCloudTrailAclCheck20150319",
        Effect : "Allow",
        Principal : { Service : "cloudtrail.amazonaws.com" },
        Action : "s3:GetBucketAcl",
        Resource : local.bucket_arn
      },
      # CloudTrail writes logs with ACL bucket-owner-full-control
      {
        Sid : "AWSCloudTrailWrite20150319",
        Effect : "Allow",
        Principal : { Service : "cloudtrail.amazonaws.com" },
        Action : "s3:PutObject",
        Resource : "${local.bucket_arn}/AWSLogs/${local.account_id}/*",
        Condition : {
          StringEquals : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = local.bucket_policy_json
}

# CloudTrail (account-level, multi-region, global events, validation)
resource "aws_cloudtrail" "this" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.logs.id
  s3_key_prefix                 = "AWSLogs"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_arn == "" ? null : var.kms_key_arn

  depends_on = [aws_s3_bucket_policy.logs, aws_s3_bucket_server_side_encryption_configuration.logs, aws_s3_bucket_versioning.logs]

  tags = local.tags
}

