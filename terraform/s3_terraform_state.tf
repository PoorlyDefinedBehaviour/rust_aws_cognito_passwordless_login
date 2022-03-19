# Provides the AWS account ID to other resources
# Interpolate: data.aws_caller_identity.current.account_id
data "aws_caller_identity" "current" {}

resource "aws_kms_key" "terraform_state_kms_key" {
  description = "Used to encrypt and decrypt the Terraform state S3 bucket"
  tags = {
    Name = "terraform-state-s3-bucket-key"
  }
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Effect": "Allow",
    "Principal" {
      "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:terraform"
    },
    "Action": "kms:*",
    "Resource": "*"
  }
  EOF
}

resource "aws_s3_bucket" "terraform_state_s3_bucket" {
  bucket = "terraform-state-${var.region}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.terraform_state_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    Name = "terraform-state-${var.region}"
  }
}

resource "aws_s3_bucket_public_access_block" "this_public_access_block" {
  bucket                  = aws_s3_bucket.terraform_state_s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
