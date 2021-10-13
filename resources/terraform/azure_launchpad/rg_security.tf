######
# AzureAD Group creation for RG
######
resource "azuread_group" "owner" {
  name = "${local.global_settings.name_prefix}-${local.global_settings.environment}-fc"
}

resource "azuread_group" "contributor" {
  name = "${local.global_settings.name_prefix}-${local.global_settings.environment}-rw"
}

resource "azuread_group" "readonly" {
  name = "${local.global_settings.name_prefix}-${local.global_settings.environment}-ro"
}

######
# Resource Group Configuration
######
resource "azurerm_resource_group" "main" {
  name     = "${local.global_settings.name_prefix}-${local.global_settings.environment}"
  location = local.global_settings.location
  tags = local.tags
}

resource "azurerm_role_assignment" "contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.contributor.id
}

resource "azurerm_role_assignment" "owner" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.owner.id
}

resource "azurerm_role_assignment" "readonly" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.readonly.id
}