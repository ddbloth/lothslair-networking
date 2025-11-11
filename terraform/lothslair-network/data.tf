data "azurerm_client_config" "current" {}

# SP has security issues being able to read this...
data "azuread_user" "user" {
	user_principal_name = "ddbrown@ddbhpyahoo.onmicrosoft.com"
}