provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

#
# Core management resources
#
resource "azurerm_resource_group" "mgmt" {
  name     = var.mgmt_res_group
  location = var.region
}

# Holds Terraform shared state (already exists, created by bootstrap.sh)
resource "azurerm_storage_account" "state_storage" {
  name                     = var.state_sa_name
  resource_group_name      = azurerm_resource_group.mgmt.name
  location                 = azurerm_resource_group.mgmt.location
  account_tier             = "Standard"
  account_kind             = "BlobStorage"
  account_replication_type = "RAGRS"
  allow_blob_public_access = false
}

#
# Shared container registry
#
resource "azurerm_container_registry" "shared_acr" {
  name                = var.shared_acr_name
  resource_group_name = azurerm_resource_group.mgmt.name
  location            = azurerm_resource_group.mgmt.location
  sku                 = "Standard"
  admin_enabled       = false
}

#
# Shared KeyVault & policy to allow Azure DevOps SP to access
#
resource "azurerm_key_vault" "shared_kv" {
  name                       = var.shared_keyvault_name
  location                   = azurerm_resource_group.mgmt.location
  resource_group_name        = azurerm_resource_group.mgmt.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled        = true
  soft_delete_retention_days = 30

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "azdo_keyvault_access_policy" {
  key_vault_id = azurerm_key_vault.shared_kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azuread_service_principal.azdo_keyvault_sp.id

  secret_permissions = [
    "get", "list"
  ]
}

