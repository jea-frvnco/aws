terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.53.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
resource "aws_s3_bucket" "website_bucket" {
  bucket = "nombre-unico-del-bucket"  # Cambia por un nombre único
  acl    = "public-read"              # Permite acceso público a los archivos

  # Configuración para hosting de sitio web estático
  website {
    index_document = "index.html"     # Archivo por defecto al acceder al bucket
  }

  tags = {
    Name = "Website Bucket"
  }
}

# Recurso para subir el archivo HTML al bucket
resource "aws_s3_bucket_object" "index_html" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "index.html"
  source = "index.html"  # Ruta local al archivo HTML que contiene "jean gutierrez"

  # Dependencia explícita para esperar a que se cree el bucket antes de subir el archivo
  depends_on = [aws_s3_bucket.website_bucket]
}

# Política para permitir acceso público al contenido del bucket
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = aws_s3_bucket.website_bucket.arn + "/*",
      },
    ],
  })
}
