terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# In case you want account-id for policies later
data "aws_caller_identity" "current" {}

resource "aws_guardduty_detector" "this" {
  enable = true

  # Feature toggles
  datasources {
    s3_logs {
      enable = var.enable_s3_protection
    }

    kubernetes {
      audit_logs {
        enable = var.enable_eks_audit_logs
      }
    }

    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.enable_ebs_malware_protection
        }
      }
    }
  }

  tags = var.tags
}

# OPTIONAL: publish findings to S3 (requires proper bucket policy and KMS permissions)
resource "aws_guardduty_publishing_destination" "s3" {
  count           = var.findings_bucket_arn != "" && var.kms_key_arn != "" ? 1 : 0
  detector_id     = aws_guardduty_detector.this.id
  destination_arn = var.findings_bucket_arn
  kms_key_arn     = var.kms_key_arn
}

