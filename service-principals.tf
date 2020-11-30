# SP used by Azure DevOps to access the management KV

resource "azuread_application" "azdo_keyvault_app" {
  name = var.azdo_keyvault_sp_name
}

resource "azuread_service_principal" "azdo_keyvault_sp" {
  application_id = azuread_application.azdo_keyvault_app.application_id
}

resource "random_password" "password" {
  length      = 16
  special     = true
  min_numeric = 1
  min_special = 1
  min_lower   = 1
  min_upper   = 1
}

resource "azuread_application_password" "azdo_keyvault_sp_password" {
  application_object_id = azuread_application.azdo_keyvault_app.id
  value                 = random_password.password.result
  end_date              = "2040-01-01T00:00:00Z"
  description           = "TF generated password"
}

resource "azurerm_role_assignment" "azdo_keyvault_sp" {
  scope                            = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name             = "Key Vault Reader (preview)"
  principal_id                     = azuread_service_principal.azdo_keyvault_sp.id
  skip_service_principal_aad_check = true
}


# SP used by Azure DevOps Pipelines to access Azure

resource "azuread_application" "azure_pipeline_app" {
  name = var.azdo_keyvault_sp_name
}

resource "azuread_service_principal" "azure_pipeline_sp" {
  application_id = azuread_application.azure_pipeline_app.application_id
}

resource "random_password" "password" {
  length      = 16
  special     = true
  min_numeric = 1
  min_special = 1
  min_lower   = 1
  min_upper   = 1
}

resource "azuread_application_password" "azdo_keyvault_sp_password" {
  application_object_id = azuread_application.azure_pipeline_app.id
  value                 = random_password.password.result
  end_date              = "2040-01-01T00:00:00Z"
  description           = "TF generated password"
}

resource "azurerm_role_assignment" "azdo_keyvault_sp" {
  scope                            = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name             = "Contributor"
  principal_id                     = azuread_service_principal.azdo_pipeline_sp.id
  skip_service_principal_aad_check = true
}
