resource "azurerm_key_vault" "vault" {
  name                      = var.name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  tenant_id                 = var.tenant_id
  sku_name                  = var.sku_name
  enable_rbac_authorization = var.enable_rbac_authorization
  tags                      = var.tags

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}
