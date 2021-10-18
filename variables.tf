variable "state_storage" {
  type        = string
  description = "Storage account created by bootstrap to hold all Terraform state"
}

variable "mgmt_res_group" {
  type        = string
  description = "Shared management resource group"
}

variable "region" {
  type        = string
  description = "Region used for all resources"
}

variable "prefix" {
  type        = string
  description = "Prefix appended to all resources"
}

#
# Azure DevOps config
#
variable "azdo_org_url" {
  type        = string
  description = "URL of the Azure DevOps org"
}

variable "azdo_project_name" {
  type        = string
  description = "Name of the project in above org"
}

variable "azdo_pat" {
  type        = string
  description = "PAT (This variable is only used during bootstrapping, terraform will use the value stored in key vault normally)"
  default = ""
  }

#
#
#
variable "azdo_pipeline_sp_role" {
  type = string
  default = "Contributor"
  description = "Role to assign to the pipeline SP on the subscription"
}

variable "acr_sku" {
  type = string
  default = "Standard"
  description = "Price tier for ACR"
}
