iam_role = "arn:aws:iam::${get_aws_account_id()}:role/applier"

generate "backend" {
  path      = "remote_backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "s3" {
    bucket         = "asmigar-${path_relative_to_include()}-create-nginx-terraform-state-${get_aws_account_id()}"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "create-nginx-state-locks"
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
locals {
  project_name = reverse(split("/", path.cwd))[0]
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Organisation = var.organisation
      Environment  = var.env
      Managed_By   = "Terraform"
      Project      = "create-nginx"
    }
  }
}
EOF
}
