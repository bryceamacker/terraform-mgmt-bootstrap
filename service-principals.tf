#
# SP used by Azure DevOps to access the management KV
#
resource "azuread_application" "azdo_keyvault_app" {
  display_name = "${var.prefix}-keyvault-sp"
}

resource "azuread_service_principal" "azdo_keyvault_sp" {
  application_id = azuread_application.azdo_keyvault_app.application_id
}

resource "azuread_service_principal_password" "azdo_keyvault_sp" {
  service_principal_id = azuread_service_principal.azdo_keyvault_sp.id
}

resource "azurerm_role_assignment" "azdo_keyvault_sp" {
  scope                            = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name             = "Key Vault Reader"
  principal_id                     = azuread_service_principal.azdo_keyvault_sp.id
  skip_service_principal_aad_check = true
}

#
# Create a SP to be used by Azure DevOps Pipelines to access Azure
#
resource "azuread_application" "azdo_pipeline_app" {
  display_name = "${var.prefix}-pipeline-sp"
}

resource "azuread_service_principal" "azdo_pipeline_sp" {
  application_id = azuread_application.azdo_pipeline_app.application_id
}

resource "azuread_service_principal_password" "azdo_pipeline_sp" {
  service_principal_id = azuread_service_principal.azdo_pipeline_sp.id
}

resource "azurerm_role_assignment" "azdo_pipeline_sp" {
  scope                            = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name             = var.azdo_pipeline_sp_role
  principal_id                     = azuread_service_principal.azdo_pipeline_sp.id
  skip_service_principal_aad_check = true
}
