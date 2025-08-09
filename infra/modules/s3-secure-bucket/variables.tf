variable "bucket_name" {
  description = "Name of the S3 bucket."
  type        = string
}

variable "kms_key_id" {
  description = "Optional KMS key ID/ARN for SSE-KMS. Leave empty to use the AWS-managed key."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

