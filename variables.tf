variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = { Project = "aws-security-baseline" }
}

