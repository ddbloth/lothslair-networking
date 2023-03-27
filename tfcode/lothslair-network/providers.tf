terraform {
  required_providers {
    # Set provider & version
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.21.0"
    }
  }

  backend "azurerm" {
  }
}

