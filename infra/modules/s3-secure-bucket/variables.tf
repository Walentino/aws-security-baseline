variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the bucket"
  type        = map(string)
  default     = {}
}

variable "versioning" {
  description = "Enable S3 bucket versioning (true for Enabled, false for Suspended)"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow bucket to be deleted even if it contains objects"
  type        = bool
  default     = false
}


variable "kms_key_arn" {
  description = "Optional CMK ARN. If set, bucket policy enforces this exact key for PutObject."
  type        = string
  default     = ""
}

