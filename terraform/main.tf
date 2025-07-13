# S3 bucket for artifacts
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "devops2025-artifacts-subhojeet123-0713"
  force_destroy = true
}

# 🔒 Secure S3: block public access
resource "aws_s3_bucket_public_access_block" "artifact_block" {
  bucket = aws_s3_bucket.artifact_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 🔒 Enable bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "artifact_encryption" {
  bucket = aws_s3_bucket.artifact_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 🔒 Enable versioning
resource "aws_s3_bucket_versioning" "artifact_versioning" {
  bucket = aws_s3_bucket.artifact_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 📝 Enable access logging (to same bucket)
resource "aws_s3_bucket_logging" "artifact_logging" {
  bucket = aws_s3_bucket.artifact_bucket.id

  target_bucket = aws_s3_bucket.artifact_bucket.id
  target_prefix = "logs/"
}

# CodeBuild project
resource "aws_codebuild_project" "devops_build" {
  name          = "devops-build"
  description   = "Build project for DevOps-Masters-2025"
  build_timeout = 5
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/subho-279/Devops_Subhojeet.git"
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
  }
}

# EC2 instance for deployment
resource "aws_instance" "devops_ec2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key_name      = "devops-key"

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "DevOpsEC2"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y ruby wget
              cd /home/ec2-user
              wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto
              systemctl start codedeploy-agent
              systemctl enable codedeploy-agent
              EOF
}
# CodeDeploy application & group
resource "aws_codedeploy_app" "devops_app" {
  name             = "DevOpsApp"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "devops_group" {
  app_name              = aws_codedeploy_app.devops_app.name
  deployment_group_name = "DevOpsGroup"
  service_role_arn      = aws_iam_role.codepipeline_role.arn

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "DevOpsEC2"
    }
  }
}

# CodePipeline: source → build → deploy
resource "aws_codepipeline" "devops_pipeline" {
  name     = "devops-masters-2025-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "subho-279"
        Repo       = "Devops_Subhojeet"
        Branch     = "main"
        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildAction"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.devops_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployAction"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.devops_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.devops_group.deployment_group_name
      }
    }
  }
}