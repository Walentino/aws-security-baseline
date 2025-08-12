# infra/modules/securityhub-baseline/outputs.tf

# Whether we asked to enable AFSBP
output "afsbp_enabled" {
  description = "True if the AWS Foundational Security Best Practices standard is enabled."
  value       = var.enable_afsbp
}

# The AFSBP standard ARN (null if disabled)
output "afsbp_subscription_arn" {
  description = "AFSBP standard ARN when enabled; null otherwise."
  value       = var.enable_afsbp ? local.afsbp_arn : null
}

