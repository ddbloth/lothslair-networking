data "azurerm_client_config" "current" {}

# SP has security issues being able to read this...
// Azure DevOps group for role assignments (parametrized)
data "azuread_group" "azure_devops" {
	object_id = var.azure_devops_group_object_id
}