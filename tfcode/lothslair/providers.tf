terraform {
  required_providers {
    # Set provider & version
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.69.0"
    }
  }

  backend "azurerm" {
  }
}

