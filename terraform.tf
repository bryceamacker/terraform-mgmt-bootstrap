terraform {
  required_version = ">= 0.13"

  backend "azurerm" {
    key = "management.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.35.0"
    }

    azuredevops = {
      source = "terraform-providers/azuredevops"
    }
  }
}
