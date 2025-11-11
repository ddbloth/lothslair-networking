resource "azurerm_private_dns_zone" "pdns_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.networking_rg.name
}

# Linking DNS Zone to the configured VNET
resource "azurerm_private_dns_zone_virtual_network_link" "blob_dns_zone_vnet_link" {
  name                  = "vnet_link"
  resource_group_name   = azurerm_resource_group.networking_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pdns_blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}