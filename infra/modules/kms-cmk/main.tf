#############################################
# infra/modules/kms-cmk/main.tf
# CMK for CloudTrail with proper key policy
#############################################

# (Optional) It's fine to omit this block if you already pin providers at root.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Discover current account for policy ARNs/conditions
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  # Allows CloudTrail service to use this CMK, restricted by the trail ARN
  cloudtrail_kms_statement = {
    Sid       = "AllowCloudTrailUseOfTheKey"
    Effect    = "Allow"
    Principal = { Service = "cloudtrail.amazonaws.com" }
    Action = [
      "kms:GenerateDataKey*",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    Resource = "*"
    Condition = {
      # CloudTrail sets this encryption context; limit to trails in this account
      "StringLike" = {
        "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:aws:cloudtrail:*:${local.account_id}:trail/*"
      }
    }
  }

  # Standard "enable IAM user (root) permissions" statement
  admin_full_access_statement = {
    Sid       = "EnableIAMUserPermissions"
    Effect    = "Allow"
    Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }
    Action    = "kms:*"
    Resource  = "*"
  }

  # Assemble the full key policy
  key_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      local.admin_full_access_statement,
      local.cloudtrail_kms_statement
    ]
  })
}

# Single CMK resource (ensure there is only ONE in this module)
resource "aws_kms_key" "this" {
  description             = var.description
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = local.key_policy_json
}

# Friendly alias for the key
resource "aws_kms_alias" "this" {
  name          = "alias/${var.alias_name}"
  target_key_id = aws_kms_key.this.key_id
}

