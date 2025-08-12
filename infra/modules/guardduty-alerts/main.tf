terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# SNS topic for alerts
resource "aws_sns_topic" "gd_alerts" {
  name = "guardduty-high-severity-alerts"
  tags = var.tags
}

# Email subscription (you must confirm the email)
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.gd_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# EventBridge rule: GuardDuty findings with severity >= threshold
# EventBridge supports numeric matching:
# https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns-content-based-filtering.html#eb-filtering-numeric
resource "aws_cloudwatch_event_rule" "gd_high" {
  name        = "guardduty-high-severity"
  description = "Alert on GuardDuty findings with severity >= threshold"
  event_pattern = jsonencode({
    "source" : ["aws.guardduty"],
    "detail-type" : ["GuardDuty Finding"],
    "detail" : {
      "severity" : [{ "numeric" : [">=", var.severity_threshold] }]
    }
  })
  tags = var.tags
}

# EventBridge target: send to SNS, with a readable message
resource "aws_cloudwatch_event_target" "to_sns" {
  rule = aws_cloudwatch_event_rule.gd_high.name
  arn  = aws_sns_topic.gd_alerts.arn

  input_transformer {
    input_paths = {
      type     = "$.detail.type"
      id       = "$.detail.id"
      account  = "$.detail.accountId"
      region   = "$.region"
      time     = "$.time"
      sev      = "$.detail.severity"
      res_json = "$.detail" # full detail payload (JSON)
    }

    # Make the template a valid JSON object using jsonencode()
    input_template = jsonencode({
      subject = "GuardDuty High Severity Alert (sev <sev>)"
      message = "GuardDuty Alert (sev <sev>)\nType: <type>\nFindingId: <id>\nAccount: <account>\nRegion: <region>\nTime: <time>\n\nResource:\n<res_json>"
    })
  }
}

