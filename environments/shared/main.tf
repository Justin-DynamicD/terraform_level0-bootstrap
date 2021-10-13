provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

terraform {
  backend "s3" {}
}

module "foundation" {
  source = "../../resources/terraform/azure_launchpad"
  global_settings = {
    environment = "shared"
  }
}
