variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "iam_user_name" {
  description = "The IAM user name to create"
  type        = string
  default     = "dev-example-user"
}

