######
# required provider versions 
######
terraform {
  required_version = ">= 0.13.3"

  required_providers {
    azurerm = ">= 2.28"
    azuread = ">= 1.0.0"
  }
}