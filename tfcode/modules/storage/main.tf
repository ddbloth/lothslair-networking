
provider "azurerm" {
  features {}
}

resource "azurerm_storage_account" "storage_account" {

  name                     = var.name
  location                 = var.location
  resource_group_name      = var.storage_account_resource_group_name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication_type
  access_tier              = var.storage_account_access_tier
  min_tls_version          = "TLS1_2"
  is_hns_enabled           = var.storage_account_is_gen2
  tags                     = var.tags

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}