data "azurerm_client_config" "current" {}

# SP has security issues being able to read this...
data "azuread_user" "user" {
	user_principal_name = "ddbhp1227_gmail.com#EXT#@ddbhp1227gmail.onmicrosoft.com"
}

data "azurerm_key_vault_secret" "tf_kv" {
	name = var.tf_kv_name
}