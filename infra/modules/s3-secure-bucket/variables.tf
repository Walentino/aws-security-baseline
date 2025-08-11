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

