output "detector_id" {
  description = "The GuardDuty detector ID."
  value       = aws_guardduty_detector.this.id
}

output "publishing_destination_id" {
  description = "ID of the publishing destination (if created), else null."
  value       = length(aws_guardduty_publishing_destination.s3) > 0 ? aws_guardduty_publishing_destination.s3[0].id : null
}

