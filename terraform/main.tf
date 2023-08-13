locals {
  project     = "ld-ats"
  region      = "euw1"
  environment = "dev"

  env    = substr(local.environment, 0, 1)
  prefix = "${local.project}-${local.env}-${local.region}"
  tags = {
    Project     = local.project
    Region      = local.region
    Environment = local.environment
  }
}

resource "aws_s3_bucket" "landing" {
  bucket = "${local.prefix}-landing-data"
  tags   = local.tags
}

resource "aws_s3_bucket_ownership_controls" "landing" {
  bucket = aws_s3_bucket.landing.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "landing" {
  depends_on = [aws_s3_bucket_ownership_controls.landing]

  bucket = aws_s3_bucket.landing.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "landing" {
  bucket = aws_s3_bucket.landing.id

  rule {
    id     = "intelligent-tier"
    status = "Enabled"
    filter {} # applied to all objects
    transition {
      days          = 7
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}
