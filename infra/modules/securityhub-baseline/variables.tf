variable "aws_region" {
  type        = string
  description = "Region where Security Hub is configured."
}

variable "enable_afsbp" {
  type        = bool
  description = "Whether to enable the AWS Foundational Security Best Practices standard."
  default     = true
}

