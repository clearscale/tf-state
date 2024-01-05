locals {
  # context     = jsondecode(jsonencode(module.context.accounts))
  # bucket_name = local.context.aws[0].prefix.dash.full.default.function

  # bucket_name = format("%s-%s",var.prefix,var.client,var.env)
  bucket_name = join("-", [var.prefix, var.client, var.project, var.name, var.env, var.region])
}

#
# S3 Bucket for Terraform state files
# https://developer.hashicorp.com/terraform/language/settings/backends/s3
#
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = local.bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Allow deletion of non-empty bucket
  # force_destroy = true
}

#
# DynamoDB lock table
# https://developer.hashicorp.com/terraform/language/settings/backends/s3#dynamodb-table-permissions
#
resource "aws_dynamodb_table" "this" {
  name           = local.bucket_name
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}