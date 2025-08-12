variable "aws_region" {
  description = "AWS region to use for the example."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS named profile for credentials."
  type        = string
  default     = null
}

variable "allowed_regions" {
  description = "List of AWS regions allowed by the SCP."
  type        = list(string)
  default     = ["us-east-1"]
}

variable "attach_to_root" {
  description = "Whether to attach the SCP to the org root."
  type        = bool
  default     = true
}

variable "root_id" {
  description = "Explicit Organizations root ID (e.g., r-abcd). Leave empty to auto-discover (requires mgmt-account creds)."
  type        = string
  default     = ""
}

variable "policy_name_prefix" {
  description = "Prefix for the SCP policy name."
  type        = string
  default     = "baseline-"
}

