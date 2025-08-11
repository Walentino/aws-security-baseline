variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
}

variable "force_destroy" {
  description = "Whether to force destroy the S3 bucket (delete even if it contains objects)"
  type        = bool
  default     = true
}

