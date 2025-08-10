variable "alias" {
  description = "Alias for the KMS key (without the 'alias/' prefix)"
  type        = string
  default     = "example-key"
}

variable "description" {
  description = "Description for the KMS CMK"
  type        = string
  default     = "KMS key for secure S3 bucket"
}

variable "deletion_window_in_days" {
  description = "The waiting period before KMS key deletion"
  type        = number
  default     = 7
}
