output "sns_topic_arn" {
  value       = aws_sns_topic.gd_alerts.arn
  description = "SNS topic for GuardDuty alerts"
}

