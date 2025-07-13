output "artifact_bucket" {
  value = aws_s3_bucket.artifact_bucket.bucket
}

output "pipeline_role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}