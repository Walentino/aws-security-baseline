variable "aws_region" { type = string }
variable "aws_profile" { type = string }

# Optional: reuse the GuardDuty SNS Topic ARN so all alerts land in the same inbox
variable "sns_topic_arn" {
  type        = string
  default     = ""
  description = "Existing SNS topic ARN for alerts (e.g., GuardDuty topic). Leave empty to skip wiring."
}

