# Needs to match backend config 
variable "state_storage" {
  type        = string
  description = "Storage account created by bootstrap, set with BACKEND_STORAGE_ACCOUNT"
}

variable "hub_res_group" {
  type        = string
  description = "Shared management resource group, set with BACKEND_RESGRP"
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
  description = "Access token with rights in Azure DevOps to set up service connections"
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