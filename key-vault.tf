# 
# Shared KeyVault & policy to allow Azure DevOps SP to access
#
resource "azurerm_key_vault" "shared_kv" {
  name                       = "${var.prefix}keyvault"
  location                   = azurerm_resource_group.mgmt.location
  resource_group_name        = azurerm_resource_group.mgmt.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 90

  sku_name = "standard"
}

# Add the AzDO SP to an access policy so it can read and list secrets
resource "azurerm_key_vault_access_policy" "azdo_keyvault_access_policy" {
  key_vault_id = azurerm_key_vault.shared_kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azuread_service_principal.azdo_keyvault_sp.id

  secret_permissions = [
    "get", "list"
  ]
}
# Add running user and give full rights to secrets
resource "azurerm_key_vault_access_policy" "user_keyvault_access_policy" {
  key_vault_id = azurerm_key_vault.shared_kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "get", "list", "set", "delete", "purge", "recover", "restore"
  ]
}

# Store the Pipeline SP details as secrets in KeyVault
resource "azurerm_key_vault_secret" "pipeline-sp-secret" {
  name         = "pipeline-sp-secret"
  value        = azuread_service_principal_password.azdo_pipeline_sp.value
  key_vault_id = azurerm_key_vault.shared_kv.id
  depends_on   = [azurerm_key_vault_access_policy.user_keyvault_access_policy]
}
resource "azurerm_key_vault_secret" "pipeline-sp-clientid" {
  name         = "pipeline-sp-clientid"
  value        = azuread_service_principal.azdo_pipeline_sp.application_id
  key_vault_id = azurerm_key_vault.shared_kv.id
  depends_on   = [azurerm_key_vault_access_policy.user_keyvault_access_policy]
}
resource "azurerm_key_vault_secret" "azure-tenant" {
  name         = "azure-tenant-id"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.shared_kv.id
  depends_on   = [azurerm_key_vault_access_policy.user_keyvault_access_policy]
}
resource "azurerm_key_vault_secret" "azure-subid" {
  name         = "azure-sub-id"
  value        = data.azurerm_client_config.current.subscription_id
  key_vault_id = azurerm_key_vault.shared_kv.id
  depends_on   = [azurerm_key_vault_access_policy.user_keyvault_access_policy]
}

output "keyvault_name" {
  value = azurerm_key_vault.shared_kv.name
}