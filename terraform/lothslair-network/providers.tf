terraform {
  required_providers {
    # Set provider & version
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.52.0"
    }
  }

  backend "azurerm" {
  }
}

