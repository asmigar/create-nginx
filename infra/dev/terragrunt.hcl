terraform {
  source = "../../modules//nginx"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  env = "dev"
}

iam_role = "arn:aws:iam::303946138843:role/GithubAction"