######
# merge defaults to populate unassigned params
# and create complete local settings reference
######

locals {
  defaults = {
    global_settings = {
      discovery_tag = "tfstate"
      environment   = "nonprod",
      location      = "West US 2"
      name_prefix   = "devops"
    }
    storage_accounts = {
      statefiles0 = "level0"
      statefiles1 = "level1"
      statefiles2 = "level2"
      statefiles3 = "level3"
      statefiles4 = "level4"
    }
    tags = {
      Project   = "sdlc"
      Terraform = true
    }
  }
  global_settings  = merge(local.defaults.global_settings, var.global_settings)
  storage_accounts = merge(local.defaults.storage_accounts, var.storage_accounts)
  tags             = merge(local.defaults.tags, { "Environment" = local.global_settings.environment }, var.tags)
}

######
# Data lookups
######

# import current Azure Data
data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current" {}
