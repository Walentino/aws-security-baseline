variable "bucket_name" {
  description = "Name for the S3 bucket."
  type        = string
}

variable "kms_key_arn" {
  description = "Optional CMK ARN to require for object uploads (SSE-KMS). Leave empty to allow AES256."
  type        = string
  default     = ""
}

variable "enforce_kms_when_provided" {
  description = "If true and kms_key_arn is set, enforce aws:kms and the specific key-id for PutObject."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable bucket versioning."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Force destroy bucket even if it contains objects."
  type        = bool
  default     = false
}

variable "enable_cloudtrail_delivery" {
  description = "Add policy statements to allow CloudTrail to deliver to AWSLogs/<account-id>/..."
  type        = bool
  default     = false
}

variable "account_id" {
  description = "Account ID used in CloudTrail statement path. If empty, module detects it."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to bucket and related resources."
  type        = map(string)
  default     = {}
}

