variable "organisation" {
  default     = "asmigar"
  type        = string
  description = "org name to use as s3 bucket prefix"
}

variable "envs" {
  default     = ["dev"]
  type        = list(string)
  description = "list of environments to be created"
}

variable "cli_user" {
  type = string
  description = "the admin cli user you created mentioned in prereuisites of README.md"
}