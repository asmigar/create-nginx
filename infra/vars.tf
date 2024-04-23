variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}


variable "shh_key_name" {
  type        = string
  default     = "nginx"
  description = "ssh key name to be created in EC2 and store in ~/.ssh folder"
}

variable "organisation" {
  type        = string
  default     = "asmigar"
  description = "org name"
}
