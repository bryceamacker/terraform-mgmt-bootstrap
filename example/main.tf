provider "azurerm" {
  features {}
}

resource "azurecaf_name" "res_group" {
  name          = var.name
  resource_type = "azurerm_resource_group"
  random_length = 5
  clean_input   = true
}

resource "azurecaf_name" "storage" {
  name          = var.name
  resource_type = "azurerm_storage_account"
  random_length = 5
  clean_input   = true
}

resource "azurerm_resource_group" "example" {
  name     = azurecaf_name.res_group.result
  location = var.region
}

# Holds Terraform shared state (already exists, created by bootstrap.sh)
resource "azurerm_storage_account" "example" {
  name                     = azurecaf_name.storage.result
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  allow_blob_public_access = false
}
