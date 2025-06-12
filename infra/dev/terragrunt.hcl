terraform {
  source = "../../modules//nginx"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  env = "dev"
}

iam_role = "arn:aws:iam::${get_aws_account_id()}:role/GithubAction"