terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = false
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}

# Default encryption: require KMS; use specific CMK only if provided.
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Base policy: TLS only + require aws:kms header for PutObject
data "aws_iam_policy_document" "base" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid       = "DenyIncorrectEncryptionHeader"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
}

# If a specific CMK is provided, add an extra guard to force that exact key
data "aws_iam_policy_document" "with_cmk" {
  count = var.kms_key_arn == "" ? 0 : 1

  # IMPORTANT: must be a list
  source_policy_documents = [data.aws_iam_policy_document.base.json]

  statement {
    sid       = "DenyWrongKmsKey"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [var.kms_key_arn]
    }
  }
}


locals {
  # Base statements (always applied)
  base_statements = [
    {
      Sid    = "DenyInsecureTransport"
      Effect = "Deny"
      Action = "s3:*"
      Resource = [
        "${aws_s3_bucket.this.arn}",
        "${aws_s3_bucket.this.arn}/*",
      ]
      Principal = "*"
      Condition = {
        Bool = { "aws:SecureTransport" = "false" }
      }
    }
  ]

  # Extra statements if a CMK is provided (var.kms_key_arn not empty)
  kms_statements = var.kms_key_arn == "" ? [] : [
    {
      Sid       = "DenyIncorrectEncryptionHeader"
      Effect    = "Deny"
      Action    = "s3:PutObject"
      Principal = "*"
      Resource  = "${aws_s3_bucket.this.arn}/*"
      Condition = {
        StringNotEquals = {
          "s3:x-amz-server-side-encryption" = "aws:kms"
        }
      }
    },
    {
      Sid       = "DenyWrongKMSKey"
      Effect    = "Deny"
      Action    = "s3:PutObject"
      Principal = "*"
      Resource  = "${aws_s3_bucket.this.arn}/*"
      Condition = {
        StringNotEquals = {
          "s3:x-amz-server-side-encryption-aws-kms-key-id" = var.kms_key_arn
        }
      }
    },
  ]

  # Final bucket policy JSON (single definition!)
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

