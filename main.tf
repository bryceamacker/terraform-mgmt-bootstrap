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
  name                     = var.state_storage
  resource_group_name      = azurerm_resource_group.mgmt.name
  location                 = azurerm_resource_group.mgmt.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  allow_blob_public_access = false
}

#
# Shared container registry
#
resource "azurerm_container_registry" "shared_acr" {
  name                = "${var.prefix}logs"
  resource_group_name = azurerm_resource_group.mgmt.name
  location            = azurerm_resource_group.mgmt.location
  sku                 = var.acr_sku
  admin_enabled       = false
}

#
# Shared Log Analytics
#
resource "azurerm_log_analytics_workspace" "shared_logs" {
  name                = "${var.prefix}acr"
  resource_group_name = azurerm_resource_group.mgmt.name
  location            = azurerm_resource_group.mgmt.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}