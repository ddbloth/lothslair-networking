provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lothslair_rg" {
  location = var.azureRegion
  name     = local.rg_name
  tags     = local.tags
}