terraform {
required_providers {
aws = {
source = "hashicorp/aws"
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
