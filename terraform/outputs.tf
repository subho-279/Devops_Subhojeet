output "artifact_bucket" {
  value = aws_s3_bucket.artifact_bucket.bucket
}

output "pipeline_role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}

output "build_project_name" {
  value = aws_codebuild_project.devops_build.name
}