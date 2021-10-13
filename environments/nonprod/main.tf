provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

terraform {
    backend "s3" {}
}

module "foundation" {
  source = "../../resources/terraform/aws_launchpad"
  global_settings = {
    environment = "nonprod"
  }
}
