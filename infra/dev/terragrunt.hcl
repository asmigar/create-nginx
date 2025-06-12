terraform {
  source = "../../modules//nginx"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  env = "dev"
}