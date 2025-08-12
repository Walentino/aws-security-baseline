module "alerts" {
  source = "../../infra/modules/guardduty-alerts"

  alert_email        = "YOUR_EMAIL@EXAMPLE.COM" # <-- change this
  severity_threshold = 5.0

  tags = {
    Project = "aws-security-baseline"
    Env     = "dev"
  }
}

output "sns_topic_arn" { value = module.alerts.sns_topic_arn }

