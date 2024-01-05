module "aws_s3" {
  source    = "./aws/s3"
  # providers = { aws = aws }

  count = length([
    for a in try(var.accounts, []) : a
      if lower(trimspace(a.provider)) == "aws" && lower(trimspace(a.backend)) == "s3"
  ])

  prefix  = var.prefix
  client  = var.client
  project = var.project
  account = var.accounts[count.index]
  env     = var.env
  region  = var.region
  name    = var.name
}