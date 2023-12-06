#
# Import standardization module
#
module "context" {
  source    = "../../../tf-context"
  providers = { aws = aws }

  prefix   = var.prefix
  client   = var.client
  project  = var.project
  accounts = [var.account]
  env      = var.env
  region   = var.region
  name     = "tfstate"
  function = var.name
}

locals {
  context     = jsondecode(jsonencode(module.context.accounts))
  bucket_name = local.context.aws[0].prefix.dash.full.default.function
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

  # Allow deletion of non-empty bucket
  # force_destroy = true
}

#
# DynamoDB lock table
# https://developer.hashicorp.com/terraform/language/settings/backends/s3#dynamodb-table-permissions
#
resource "aws_dynamodb_table" "this" {
  name           = local.bucket_name
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}