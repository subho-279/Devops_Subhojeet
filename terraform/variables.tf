variable "region" {
  description = "AWS region"
  default     = "us-east-1"  # or "ap-south-1"
}

variable "artifact_bucket_name" {
  description = "Name of S3 bucket to store artifacts"
  default     = "devops2025-artifacts-subhojeet123"  # must be globally unique
}

variable "github_token" {
  description = "GitHub access token for CodePipeline"
  type        = string
  sensitive   = true
}