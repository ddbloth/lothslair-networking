resource "azurerm_resource_group" "npd_dlz_networking" {
  location = "centralus"
  name     = "rg-subnetworking"
  tags = {
    "Business Unit"    = "Application"
    DataClassification = "Cost Center"
    MaintenanceWindow  = "Owner"
  }
}
resource "azurerm_route_table" "npd_dlz_routetable" {
  disable_bgp_route_propagation = true
  location                      = "centralus"
  name                          = "rt-centralus-npd-eim-dodlh-1"
  resource_group_name           = "rg-subnetworking"
  depends_on = [
    azurerm_resource_group.npd_dlz_networking,
  ]
}
resource "azurerm_route" "npd_dlz_route" {
  address_prefix         = "0.0.0.0/0"
  name                   = "default-to-lbi-trust"
  next_hop_in_ip_address = "10.140.0.157"
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = "rg-subnetworking"
  route_table_name       = "rt-centralus-npd-eim-dodlh-1"
  depends_on = [
    azurerm_route_table.npd_dlz_routetable,
  ]
}
resource "azurerm_virtual_network" "npd_dlz_vnet" {
  address_space       = ["10.140.66.0/24"]
  location            = "centralus"
  name                = "vnet-centralus-npd-eim-dodlh-1"
  resource_group_name = "rg-subnetworking"
  depends_on = [
    azurerm_resource_group.npd_dlz_networking,
  ]
}
resource "azurerm_subnet" "npd_dlz_private-subnet" {
  address_prefixes     = ["10.140.66.64/26"]
  name                 = "private-subnet"
  resource_group_name  = "rg-subnetworking"
  virtual_network_name = azurerm_virtual_network.npd_dlz_vnet.name
  depends_on = [
    azurerm_virtual_network.npd_dlz_vnet,
  ]
}
resource "azurerm_subnet" "npd_dlz_public-subnet" {
  address_prefixes     = ["10.140.66.128/26"]
  name                 = "public-subnet"
  resource_group_name  = "rg-subnetworking"
  virtual_network_name = "vnet-centralus-npd-eim-dodlh-1"
  depends_on = [
    azurerm_virtual_network.npd_dlz_vnet,
  ]
}
resource "azurerm_subnet" "npd_dlz_transit-subnet" {
  address_prefixes     = ["10.140.66.0/26"]
  name                 = "subnet-centralus-npd-eim-dodlh-1"
  resource_group_name  = "rg-subnetworking"
  virtual_network_name = "vnet-centralus-npd-eim-dodlh-1"
  depends_on = [
    azurerm_virtual_network.npd_dlz_vnet,
  ]
}
resource "azurerm_virtual_network_peering" "npd_dlz_peer-2-core" {
  name                      = "vnetpeer-centralus-npd-eim-dodlh-1-core"
  remote_virtual_network_id = "/subscriptions/650f74e6-1373-4e94-8eac-a63e81064d9b/resourceGroups/rg-az1-core-net/providers/Microsoft.Network/virtualNetworks/vnet1-az1-core"
  resource_group_name       = "rg-subnetworking"
  virtual_network_name      = "vnet-centralus-npd-eim-dodlh-1"
  depends_on = [
    azurerm_virtual_network.npd_dlz_vnet,
  ]
}
