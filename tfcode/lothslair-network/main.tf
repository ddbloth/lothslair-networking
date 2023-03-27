provider "azurerm" {

  features {}
}

# Create a Resource Groups
#  One for networking, and another for the base resoures for LothsLair
resource "azurerm_resource_group" "networking_rg" {
  name     = var.network_rg_name
  location = var.azureRegion
  tags = local.tags
}

# Create the VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.azureRegion}-${var.environment}-${var.name}"
  address_space       = [var.vnet_cidr]
  location              = azurerm_resource_group.networking_rg.location
  resource_group_name   = azurerm_resource_group.networking_rg.name
  tags = local.tags
}

# Create a Gateway Subnet
resource "azurerm_subnet" "gateway-subnet" {
  name                 = "GatewaySubnet" # do not rename
  address_prefixes     = [var.subnet_cidr]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.networking_rg.name
}

# Create the Azure Key Vault - globally unique - 24 characters max
resource "azurerm_key_vault" "kv_lothslair" {
  name                            = "kv-${var.location}-${var.environment}-${var.name}"
  location                        = azurerm_resource_group.networking_rg.location
  resource_group_name             = azurerm_resource_group.networking_rg.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
  enable_rbac_authorization       = true
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  
  tags = local.tags

}

# Key Vault RBAC Assignments
resource "azurerm_role_assignment" "kv_spn_rbac" {
  scope                = azurerm_key_vault.kv_lothslair.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
resource "azurerm_role_assignment" "kv_admin_rbac" {
  scope                = azurerm_key_vault.kv_lothslair.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azuread_user.user.object_id
}


# Create a Secret for the VPN Root certificate
resource "azurerm_key_vault_secret" "vpn-root-certificate" {
  depends_on=[ azurerm_role_assignment.kv_spn_rbac ]
  name = "vpn-root-certificate"
  value = filebase64(var.certificate-name)
  key_vault_id = azurerm_key_vault.kv_lothslair.id
}


