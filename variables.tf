variable "bucket_name" {
  type        = string
  description = "Name for the secure S3 bucket"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy to"
}

