provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lothslair_rg" {
  location = var.azureRegion
  name     = local.rg_name
  tags     = local.tags
}

resource "azurerm_storage_account" "sa_lothslair_1"  {
  name = "sa${var.location}${var.name}${var.environment}"
  location = var.azureRegion
  resource_group_name = azurerm_resource_group.lothslair_rg.name
  public_network_access_enabled = false
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
  
}

resource "azurerm_private_endpoint" "pep_sa_lothslair_1" {
  name                = "pep-${var.azureRegion}-sa${var.location}${var.name}${var.environment}"
  location            = var.azureRegion
  resource_group_name = azurerm_resource_group.lothslair_rg.name
  subnet_id           = data.azurerm_subnet.spoke_sub.id
  tags                = local.tags

  private_service_connection {
    name                           = "psc-${var.azureRegion}-sa${var.location}${var.name}${var.environment}"
    private_connection_resource_id = azurerm_storage_account.sa_lothslair_1.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
  
}