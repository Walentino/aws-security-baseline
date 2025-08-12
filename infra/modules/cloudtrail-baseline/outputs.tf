output "trail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.this.arn
}

output "bucket_name" {
  description = "Name of the CloudTrail logs bucket"
  value       = aws_s3_bucket.logs.id
}

