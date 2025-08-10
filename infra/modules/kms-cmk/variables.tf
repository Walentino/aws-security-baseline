variable "alias_name" {
  description = "KMS alias name WITHOUT the 'alias/' prefix (we add it)."
  type        = string
  default     = "nino-secure-cmk"
}

variable "description" {
  description = "Description for the KMS key."
  type        = string
  default     = "CMK for S3 server-side encryption"
}

variable "deletion_window_in_days" {
  description = "Days before the KMS key is scheduled for deletion."
  type        = number
  default     = 7
}

variable "enable_key_rotation" {
  description = "Enable annual key rotation."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the KMS resources."
  type        = map(string)
  default     = {}
}

