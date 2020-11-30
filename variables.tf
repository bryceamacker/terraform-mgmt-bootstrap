# Needs to match backend config 
variable "state_storage" {
  type    = string
}

variable "mgmt_res_group" {
  type    = string
}

variable "region" {
  type    = string
}

variable "prefix" {
  type        = string
  description = "Prefix appended to all resources"
}

# variable "shared_acr_name" {
#   type    = string
#   default = "acrmgmt"
# }

# variable "shared_keyvault_name" {
#   type    = string
#   default = "mgmt-kv"
# }

# variable "azdo_keyvault_sp_name" {
#   type    = string
#   default = "azdo-keyvault-sp"
# }

#
# Azure DevOps config
#

variable "azdo_org_url" {
  type    = string
  default = "https://dev.azure.com/15bladesdeep"
}

variable "azdo_project_name" {
  type    = string
  default = "broadside"
}

# No default, user should enter this
variable "azdo_pat" {
  type = string
}
