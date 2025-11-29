output "cloudtrail_name" {
  description = "CloudTrail name"
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_bucket" {
  description = "CloudTrail S3 bucket"
  value       = aws_s3_bucket.cloudtrail.id
}

output "app_bucket_name" {
  description = "Application S3 bucket name"
  value       = aws_s3_bucket.app.id
}

output "kms_key_id" {
  description = "KMS key ID (ARN format for EBS encryption)"
  value       = aws_kms_key.main.arn
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.main.arn
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "config_recorder_name" {
  description = "AWS Config recorder name"
  value       = var.enable_aws_config ? aws_config_configuration_recorder.main[0].name : null
}