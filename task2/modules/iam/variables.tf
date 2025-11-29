variable "environment" {
  description = "Environment name"
  type        = string
}

variable "app_bucket_name" {
  description = "S3 bucket name for application data"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}