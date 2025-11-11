terraform {
  required_providers {
    # Set provider & version
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.71.0"
    }
  }

  backend "azurerm" {
  }
}

