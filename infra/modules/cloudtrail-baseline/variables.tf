variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
  default     = "account-trail"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to store CloudTrail logs"
  type        = string
}

variable "kms_key_arn" {
  description = "Optional KMS CMK ARN for encrypting CloudTrail logs"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

