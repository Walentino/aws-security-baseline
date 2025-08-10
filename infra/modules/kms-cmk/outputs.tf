output "key_id" {
  value       = aws_kms_key.this.id
  description = "KMS key ID"
}

output "key_arn" {
  value       = aws_kms_key.this.arn
  description = "ARN of the KMS key"
}

output "alias_arn" {
  value       = aws_kms_alias.this.arn
  description = "KMS alias ARN"
}

