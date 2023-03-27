# Create a Resource Group
resource "azurerm_resource_group" "networking_rg" {
  name     = "rg-${var.region}-${var.environment}-${var.name}"
  location = var.location
  tags = {
    environment = var.environment
  }
}

# Create the VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.region}-${var.environment}-${var.name}"
  address_space       = [var.vnet_cidr]
  location              = azurerm_resource_group.networking_rg.location
  resource_group_name   = azurerm_resource_group.networking_rg.name
  tags = {
    environment = var.environment
  }
}

# Create a Gateway Subnet
resource "azurerm_subnet" "gateway-subnet" {
  name                 = "GatewaySubnet" # do not rename
  address_prefixes     = [var.subnet_cidr]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.networking_rg.name
}
