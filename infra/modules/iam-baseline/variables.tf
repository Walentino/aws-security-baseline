variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "break_glass_role_name" {
  description = "Name of the emergency administrator role"
  type        = string
  default     = "BreakGlassAdmin"
}

