# Terraform State

The Terraform State module is designed for generating a range of state file resources, tailored to specific inputs. Presently, it exclusively supports AWS S3 backends, offering a robust solution for managing state files in AWS environments. Future updates aim to broaden this support, encompassing a diverse array of cloud providers and storage options. For more detailed information about state files, you can visit [Terraform's state file documentation](https://developer.hashicorp.com/terraform/language/state). To learn more about AWS S3 backends, see [Terraform's documentation on S3 backends](https://developer.hashicorp.com/terraform/language/settings/backends/s3).

## Usage

```terraform
module "s3_backend" {
  source    = "https://github.com/clearscale/tf-state.git"

  accounts = [
    { name = "shared", provider = "aws", key = "shared"}
  ]

  prefix   = "ex"
  client   = "example"
  project  = "git"
  env      = "dev"
  region   = "us-east-1"
  name     = "helloworld"
}
```