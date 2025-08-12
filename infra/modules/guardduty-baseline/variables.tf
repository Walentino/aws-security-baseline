variable "enable_s3_protection" {
  description = "Enable GuardDuty S3 protection."
  type        = bool
  default     = true
}

variable "enable_eks_audit_logs" {
  description = "Enable GuardDuty Kubernetes audit logs."
  type        = bool
  default     = false
}

variable "enable_ebs_malware_protection" {
  description = "Enable EBS volume malware protection (EC2 scans)."
  type        = bool
  default     = true
}

variable "findings_bucket_arn" {
  description = "Optional: S3 bucket ARN to publish GuardDuty findings. Leave empty to skip."
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "Optional: KMS CMK ARN for encrypting findings in S3. Required if findings_bucket_arn is set."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to created resources."
  type        = map(string)
  default     = {}
}

