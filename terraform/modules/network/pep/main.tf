locals {
  psc_name = replace(var.name, "pep", "psc")
}

resource "azurerm_private_endpoint" "privateendpoint" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.pe_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = local.psc_name
    private_connection_resource_id = var.resource_id
    is_manual_connection           = false
    subresource_names              = var.subresource_names
  }

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}