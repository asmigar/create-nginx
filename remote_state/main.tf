data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  count  = 2
  bucket = format("%s-%s-create-nginx-tfstate-%s-%s-an", var.organisation, var.envs[count.index], data.aws_caller_identity.current.account_id, data.aws_region.current.region )
  bucket_namespace = "account-regional"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  count  = 2
  bucket = aws_s3_bucket.terraform_state[count.index].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable versioning so we can see the full revision history of our state files
resource "aws_s3_bucket_versioning" "terraform_state" {
  count  = 2
  bucket = aws_s3_bucket.terraform_state[count.index].id

  versioning_configuration {
    status = "Enabled"
  }
}