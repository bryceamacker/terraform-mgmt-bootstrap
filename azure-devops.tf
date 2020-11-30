provider "azuredevops" {
  version               = ">= 0.0.1"
  org_service_url       = var.azdo_org_url
  personal_access_token = var.azdo_pat
}

data "azuredevops_project" "project" {
  project_name = var.azdo_project_name
}

resource "azuredevops_serviceendpoint_azurerm" "keyvault_access" {
  project_id            = data.azuredevops_project.project.id
  service_endpoint_name = "keyvault-access"
  credentials {
    serviceprincipalid  = azuread_application.azdo_keyvault_app.application_id
    serviceprincipalkey = random_password.password.result
  }
  lifecycle {
    ignore_changes = [credentials]
  }
  azurerm_spn_tenantid      = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id   = data.azurerm_client_config.current.subscription_id
  azurerm_subscription_name = "Management Subscription"
}
