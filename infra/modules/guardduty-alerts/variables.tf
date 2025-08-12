variable "alert_email" {
  description = "Email address to receive GuardDuty alerts."
  type        = string
}

variable "severity_threshold" {
  description = "Minimum severity to alert on (0.0–8.9 typical, 9.0+ very high)."
  type        = number
  default     = 5.0
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

