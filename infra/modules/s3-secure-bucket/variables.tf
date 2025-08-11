variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "versioning" {
  description = "Enable S3 bucket versioning (true=Enabled, false=Suspended)"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Optional CMK ARN to enforce for PutObject. Leave empty to allow any KMS CMK."
  type        = string
  default     = ""
}

variable "enable_kms_enforcement" {
  type        = bool
  description = "If true, add bucket policy statements that require aws:kms and the provided KMS key ARN."
  default     = false
}

variable "force_destroy" {
  description = "Whether to force destroy the S3 bucket (delete even if it contains objects)"
  type        = bool
  default     = false
}

