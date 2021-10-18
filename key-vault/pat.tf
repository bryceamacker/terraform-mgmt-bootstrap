variable "parent_key_vault" {
  # List each field in `azurerm_route_table` that your module will access
  type = object({
    shared_kv_id = string
  })
} 


data "azurerm_key_vault_secret" "azdo_pat_kv" {
  name      = "azdo-pat"
  key_vault_id = var.parent_key_vault.shared_kv_id
}

output "azdo_pat" {
  value = nonsensitive(data.azurerm_key_vault_secret.azdo_pat_kv.value)
}