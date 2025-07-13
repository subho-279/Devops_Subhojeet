# 🚀 DevOps-Masters-2025: CI/CD Pipeline with Terraform & GitHub Actions

This project implements a fully automated **DevSecOps pipeline** using **Terraform**, **GitHub Actions**, and AWS services like **CodePipeline**, **CodeBuild**, **CodeDeploy**, and **S3**. Security scanning tools like `tfsec` and `Trivy` are integrated for infrastructure and container scanning. The infrastructure is defined as code (IaC) and deployed using CI/CD best practices.

---

## 📦 Tech Stack

- **Terraform** (AWS Provider)
- **GitHub Actions** (CI/CD)
- **AWS CodePipeline**, **CodeBuild**, **CodeDeploy**
- **EC2** as deployment target
- **S3** as artifact store
- **tfsec** for Terraform security scanning
- **Trivy** for Docker image vulnerability scanning
- **Sealed Secrets** for secret management (Kubernetes-ready)
- **Docker**

---

## 🛠️ Infrastructure Provisioning (Terraform)

The following AWS resources are provisioned via Terraform:

- ✅ `aws_codepipeline` – end-to-end deployment pipeline
- ✅ `aws_codebuild_project` – builds the Docker app
- ✅ `aws_codedeploy_app` & `aws_codedeploy_deployment_group` – for EC2 deployment
- ✅ `aws_iam_role` – for CodePipeline, CodeBuild, and EC2 with correct permissions
- ✅ `aws_s3_bucket` – artifact bucket with:
  - Server-side encryption (AES-256)
  - Public access blocks
  - Logging
  - Versioning
- ✅ `aws_instance` – EC2 with CodeDeploy agent installed

---

## 🧪 CI/CD Pipeline (GitHub Actions)

The workflow runs on every push to `main`:

### Stages:

1. ✅ **Checkout Code**
2. ✅ **Terraform Initialization**
3. ✅ **tfsec Scan** – Detects IaC security misconfigurations
4. ✅ **Docker Build**
5. ✅ **Trivy Scan** – Scans image for vulnerabilities
6. ✅ **Sealed Secret Apply** – Handles encrypted secrets (optional)
7. ✅ **Terraform Apply** – Deploys infrastructure

> All secrets (AWS keys, GitHub token) are securely stored in GitHub Secrets and injected at runtime.

---

## 🔐 GitHub Secrets Required

| Name                 | Purpose                        |
|----------------------|--------------------------------|
| `AWS_ACCESS_KEY_ID`  | AWS IAM user access key        |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM user secret          |
| `GITHUB_TOKEN_VAL`   | GitHub PAT for CodePipeline    |

---

## 📁 Project Structure

```bash
.
├── .github/workflows/
│   └── ci-cd.yml                 # CI/CD GitHub Actions workflow
├── terraform/
│   ├── main.tf                   # Infrastructure resources
│   ├── variables.tf              # Input variables
│   ├── outputs.tf                # Output values
│   ├── provider.tf               # AWS provider config
│   └── .terraform.lock.hcl       # Provider lockfile
├── buildspec.yml                 # For CodeBuild
├── appspec.yml                  # For CodeDeploy
└── Dockerfile                   # App container definition
