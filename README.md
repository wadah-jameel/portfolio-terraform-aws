# Beginner-Friendly Guide: Portfolio Website with Terraform + AWS + GitHub

This guide walks you through building and documenting your **portfolio website** hosted on **AWS** using **Terraform** and **GitHub**. No prior experience with Terraform or AWS is required.

---

## 🧭 Overview

We will:

1. Create a **simple static portfolio website**.
2. Use **Terraform** to build AWS infrastructure (S3 + CloudFront).
3. Use **GitHub Actions** to automate deployment.
4. Document everything beautifully in your GitHub repository.

---

## 🛠️ Step 1: Set Up Your Tools

### You need:

* **GitHub account** → [https://github.com](https://github.com)
* **AWS account** → [https://aws.amazon.com](https://aws.amazon.com)
* **Terraform installed** → [Terraform Download](https://developer.hashicorp.com/terraform/downloads)
* **AWS CLI installed** → [AWS CLI Install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Once installed, configure AWS CLI:

```bash
aws configure
```

Enter your AWS access key, secret key, and region (e.g., `us-east-1`).

---

## 📁 Step 2: Create Your GitHub Repository

1. Go to GitHub → Click **New Repository** → name it `portfolio-terraform-aws`.
2. Select **Public** → check **Add a README file**.
3. Clone it locally:

```bash
git clone https://github.com/yourusername/portfolio-terraform-aws.git
cd portfolio-terraform-aws
```

4. Create this folder structure:

```
portfolio-terraform-aws/
├── site/
│   └── index.html
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── .github/
│   └── workflows/
│       └── deploy.yml
└── README.md
```

---

## 🌐 Step 3: Build Your Website (HTML)

Create `site/index.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Portfolio</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 text-gray-800">
  <div class="text-center mt-20">
    <h1 class="text-4xl font-bold mb-4">Hi, I'm [Your Name]</h1>
    <p class="text-lg">Network & Cloud Engineer | Learning Terraform + AWS</p>
    <div class="mt-6">
      <a href="mailto:youremail@example.com" class="bg-blue-500 text-white px-4 py-2 rounded">Contact Me</a>
    </div>
  </div>
</body>
</html>
```

---

## ☁️ Step 4: Create Terraform Infrastructure

Create `terraform/main.tf`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "portfolio" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.portfolio.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = ["s3:GetObject"]
        Resource = ["${aws_s3_bucket.portfolio.arn}/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = aws_s3_bucket.portfolio.id
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

output "website_endpoint" {
  value = aws_s3_bucket.portfolio.website_endpoint
}
```

Create `terraform/variables.tf`:

```hcl
variable "aws_region" {
  default = "us-east-1"
}

variable "bucket_name" {
  description = "Unique S3 bucket name"
  default = "my-terraform-portfolio-site-12345"
}
```

---

## 🚀 Step 5: Connect AWS to GitHub

In your GitHub repo:

1. Go to **Settings → Secrets and variables → Actions → New repository secret**.
2. Add:

   * `AWS_ACCESS_KEY_ID`
   * `AWS_SECRET_ACCESS_KEY`

---

## ⚙️ Step 6: Automate with GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Portfolio Website

on:
  push:
    branches: ["main"]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.6.0

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Terraform Init & Apply
        working-directory: terraform
        run: |
          terraform init
          terraform apply -auto-approve

      - name: Get bucket name
        id: tfoutput
        working-directory: terraform
        run: echo "bucket=$(terraform output -raw website_endpoint)" >> $GITHUB_OUTPUT

      - name: Upload site to S3
        run: |
          aws s3 sync site/ s3://$(terraform output -raw bucket_name) --delete
```

---

## 🌍 Step 7: Deploy and View Your Site

1. Commit and push everything:

   ```bash
   git add .
   git commit -m "Initial commit: Portfolio via Terraform"
   git push origin main
   ```
2. Go to your repo → **Actions** → watch the deployment workflow run.
3. When it completes, copy the website endpoint from Terraform output.
4. Visit it in your browser! 🎉

---

## 🧹 Step 8: Clean Up

When testing is done:

```bash
cd terraform
terraform destroy -auto-approve
```

---

## 🌟 Step 9: Enhance Your Portfolio

You can add:

* Project cards, images, and links
* A custom domain (Route53 + CloudFront + ACM for HTTPS)
* A contact form (AWS Lambda + SES)

---

