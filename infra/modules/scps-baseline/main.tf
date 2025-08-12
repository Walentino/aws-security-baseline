terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

##############################################
# Targets
##############################################

locals {
  root_id_to_attach = (var.attach_to_root && var.root_id != "") ? var.root_id : null
  attach_targets    = local.root_id_to_attach != null ? toset([local.root_id_to_attach]) : toset([])
}

##############################################
# SCP: Deny actions in disallowed regions
##############################################

resource "aws_organizations_policy" "deny_disallowed_regions" {
  name        = "${var.policy_name_prefix}-deny-disallowed-regions"
  description = "Deny actions in regions not in the allowed list."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyNotAllowedRegions"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.allowed_regions
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "deny_disallowed_regions_root" {
  for_each  = local.attach_targets
  policy_id = aws_organizations_policy.deny_disallowed_regions.id
  target_id = each.value
}

##############################################
# SCP: Deny disabling/modifying CloudTrail
##############################################

resource "aws_organizations_policy" "deny_cloudtrail_modify" {
  count       = var.enable_deny_cloudtrail_modify ? 1 : 0
  name        = "${var.policy_name_prefix}-deny-cloudtrail-modify"
  description = "Deny disabling or modifying CloudTrail."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyCloudTrailStopOrUpdate",
        Effect = "Deny",
        Action = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail",
          "cloudtrail:UpdateTrail",
          "cloudtrail:PutEventSelectors",
          "cloudtrail:RemoveTags"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "deny_cloudtrail_modify_root" {
  for_each  = var.enable_deny_cloudtrail_modify ? local.attach_targets : toset([])
  policy_id = aws_organizations_policy.deny_cloudtrail_modify[0].id
  target_id = each.value
}

##############################################
# SCP: Deny IAM user creation/management
##############################################

resource "aws_organizations_policy" "deny_iam_users" {
  count       = var.enable_deny_iam_users ? 1 : 0
  name        = "${var.policy_name_prefix}-deny-iam-users"
  description = "Deny creating/managing IAM users (prefer roles/SSO)."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyIamUserMgmt",
        Effect = "Deny",
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:PutUserPolicy",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:AddUserToGroup",
          "iam:RemoveUserFromGroup",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:CreateLoginProfile",
          "iam:UpdateLoginProfile",
          "iam:DeleteLoginProfile"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "deny_iam_users_root" {
  for_each  = var.enable_deny_iam_users ? local.attach_targets : toset([])
  policy_id = aws_organizations_policy.deny_iam_users[0].id
  target_id = each.value
}

