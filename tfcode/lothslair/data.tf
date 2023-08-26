data "azurerm_client_config" "current" {}

# SP has security issues being able to read this...
data "azuread_user" "user" {
	user_principal_name = "ddbhp1227_gmail.com#EXT#@ddbhp1227gmail.onmicrosoft.com"
}

data "azurerm_key_vault" "tf_kv" {
	name = local.tf_kv_name
	resource_group_name = local.tf_rg_name
}

data "azurerm_resource_group" "network_rg" {
	name = var.spoke_vnet_rg_name
}

data "azurerm_virtual_network" "spoke_vnet" {
	name = var.spoke_vnet_name
	resource_group_name = data.azurerm_resource_group.network_rg.name
}

data "azurerm_subnet" "spoke_sub" {
	name = var.spoke_subnet_name
	virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
	resource_group_name = data.azurerm_resource_group.network_rg.name
}