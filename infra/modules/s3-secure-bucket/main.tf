##############################################
# Secure S3 Bucket Module (TLS + KMS enforced)
##############################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# The bucket itself
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning (good hygiene)
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Default encryption (SSE-KMS). If kms_key_id is "", AWS-managed KMS is used.
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id != "" ? var.kms_key_id : null
    }
    bucket_key_enabled = true
  }
}

# Bucket policy to enforce TLS and encrypted uploads
data "aws_iam_policy_document" "bucket_policy" {
  # Deny any request not using TLS
  statement {
    sid     = "DenyRequestsNotUsingTLS"
    effect  = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  # Deny object uploads without SSE header
  statement {
    sid     = "DenyUnencryptedObjectUploadsMissingHeader"
    effect  = "Deny"
    actions = ["s3:PutObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["${aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  # Deny object uploads that are not using aws:kms
  statement {
    sid     = "DenyUnencryptedObjectUploadsWrongAlgo"
    effect  = "Deny"
    actions = ["s3:PutObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["${aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
}

# If you want to force a specific CMK, set var.kms_key_id and uncomment this block:
# statement {
#   sid     = "DenyWrongKMSKey"
#   effect  = "Deny"
#   actions = ["s3:PutObject"]
#   principals { type = "*", identifiers = ["*"] }
#   resources = ["${aws_s3_bucket.this.arn}/*"]
#   condition {
#     test     = "StringNotEquals"
#     variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
#     values   = [var.kms_key_id]
#   }
# }

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

