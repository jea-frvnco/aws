terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

# Creación del bucket
resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name = "My bucket"
  }
}

# Permitir el acceso público al bucket
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Esperar antes de aplicar la política de acceso público
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject"],
      "Resource": [
        "${aws_s3_bucket.example.arn}/*"
      ]
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.example]
}

# Crear objeto dentro del bucket
resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.example.id
  key    = "index.html"
  source = "index.html" # Esto asume que tienes un archivo index.html en tu directorio actual

  depends_on = [aws_s3_bucket_policy.bucket_policy]
}
