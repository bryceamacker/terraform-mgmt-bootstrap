terraform {
  required_version = ">= 0.15.3"

  backend "azurerm" {
    key = "management.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.80.0"
    }

    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }
}
