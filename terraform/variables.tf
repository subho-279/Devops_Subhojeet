variable "region" {
  default = "us-east-1" # or ap-south-1 for Mumbai
}

variable "artifact_bucket_name" {
  default = "devops2025-artifacts-yourname123" # MUST BE GLOBALLY UNIQUE
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}