provider "aws" {
  region  = "us-east-1"
  profile = "asmigar"
  default_tags {
    tags = {
      Organisation = "Asmigar"
    }
  }
}