terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# ----------------------------
# Core S3 bucket
# ----------------------------
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# One resource, choose algorithm dynamically based on kms_key_arn
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      # If kms_key_arn is provided use KMS, otherwise AES256
      sse_algorithm = var.kms_key_arn != "" ? "aws:kms" : "AES256"
      # Only set the key id when using KMS; null makes Terraform omit the arg
      kms_master_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null
    }
    bucket_key_enabled = true
  }
}


# ----------------------------
# CloudTrail-related policy statements (locals)
# ----------------------------
locals {
  # Deny PutObject unless ACL is bucket-owner-full-control
  cloudtrail_acl_check = {
    Sid       = "DenyIncorrectAcl"
    Effect    = "Deny"
    Principal = "*"
    Action    = "s3:PutObject"
    Resource  = "${aws_s3_bucket.this.arn}/*"
    Condition = {
      StringNotEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
    }
  }

  # Deny PutObject unless SSE-KMS is used
  cloudtrail_write = {
    Sid       = "DenyUnencryptedObjectUploads"
    Effect    = "Deny"
    Principal = "*"
    Action    = "s3:PutObject"
    Resource  = "${aws_s3_bucket.this.arn}/*"
    Condition = {
      StringNotEquals = { "s3:x-amz-server-side-encryption" = "aws:kms" }
    }
  }

  # ✅ This must be an assignment INSIDE locals
  cloudtrail_statements = (
    var.enable_cloudtrail_delivery
    ? [local.cloudtrail_acl_check, local.cloudtrail_write]
    : []
  )
}

# Attach the policy only when CloudTrail delivery is enabled
resource "aws_s3_bucket_policy" "cloudtrail_enforcement" {
  count  = length(local.cloudtrail_statements) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.cloudtrail_statements
  })
}

