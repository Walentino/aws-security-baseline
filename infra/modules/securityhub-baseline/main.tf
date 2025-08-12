terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Variables are defined in variables.tf — do not redeclare them here.

# AFSBP standard ARN (avoid deprecated region.name)
locals {
  afsbp_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

# Enable Security Hub for the account (no tags supported on this resource)
resource "aws_securityhub_account" "this" {}

# Subscribe to AFSBP
resource "aws_securityhub_standards_subscription" "afsbp" {
  count         = var.enable_afsbp ? 1 : 0
  standards_arn = local.afsbp_arn
  depends_on    = [aws_securityhub_account.this]
}

