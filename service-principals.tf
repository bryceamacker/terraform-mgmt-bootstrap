#
# SP used by Azure DevOps to access the management KV
#
resource "azuread_application" "azdo_keyvault_app" {
  display_name = "${var.prefix}-keyvault-sp"
}

resource "azuread_service_principal" "azdo_keyvault_sp" {
  application_id = azuread_application.azdo_keyvault_app.application_id
}

resource "random_password" "azdo_keyvault_password" {
  length      = 16
  special     = true
  min_numeric = 1
  min_special = 1
  min_lower   = 1
  min_upper   = 1
}

resource "azuread_application_password" "azdo_keyvault_sp_password" {
  application_object_id = azuread_application.azdo_keyvault_app.id
  end_date              = "2040-01-01T00:00:00Z"
  display_name          = "keyvault_sp_password"
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

resource "random_password" "azdo_pipeline_password" {
  length      = 16
  special     = true
  min_numeric = 1
  min_special = 1
  min_lower   = 1
  min_upper   = 1
}

resource "azuread_application_password" "azdo_pipeline_sp_password" {
  application_object_id = azuread_application.azdo_pipeline_app.id
  end_date              = "2040-01-01T00:00:00Z"
  display_name          = "pipeline_sp_password"
}

resource "azurerm_role_assignment" "azdo_pipeline_sp" {
  scope                            = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name             = var.azdo_pipeline_sp_role
  principal_id                     = azuread_service_principal.azdo_pipeline_sp.id
  skip_service_principal_aad_check = true
}
