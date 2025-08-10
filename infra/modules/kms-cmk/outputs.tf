output "key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.this.id
}

output "key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.this.arn
}

output "alias_arn" {
  description = "KMS alias ARN"
  value       = aws_kms_alias.this.arn
}
