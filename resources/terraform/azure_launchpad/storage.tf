resource "azurerm_storage_account" "main" {
  for_each                 = local.storage_accounts
  name                     = "${local.global_settings.name_prefix}${local.global_settings.environment}${each.key}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  allow_blob_public_access = true
  tags                     = merge(local.tags, { (local.global_settings.discovery_tag) = each.value })
}

resource "azurerm_storage_container" "main" {
  depends_on             = [azurerm_storage_account.main]
  for_each               = local.storage_accounts
  name                   = each.value
  storage_account_name   = azurerm_storage_account.main[each.key].name
  container_access_type  = "private"
}
