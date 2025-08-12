variable "allowed_regions" {
  description = "List of AWS regions allowed by the region SCP."
  type        = list(string)
  default     = ["us-east-1"]
}

variable "policy_name_prefix" {
  description = "Prefix for created SCP names."
  type        = string
  default     = "baseline"
}

variable "root_id" {
  description = "Organizations Root ID (e.g., r-xxxx). Required if attach_to_root = true."
  type        = string
  default     = ""
}

variable "attach_to_root" {
  description = "Attach SCPs to the org root target."
  type        = bool
  default     = true
}

variable "enable_deny_cloudtrail_modify" {
  description = "Create SCP denying disabling/modifying CloudTrail."
  type        = bool
  default     = true
}

variable "enable_deny_iam_users" {
  description = "Create SCP denying creation/management of IAM users."
  type        = bool
  default     = true
}

