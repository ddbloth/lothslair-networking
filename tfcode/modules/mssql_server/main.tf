resource "azurerm_mssql_server" "mssql" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.sqlversion
  administrator_login           = var.administrator_login
  administrator_login_password  = var.administrator_login_password
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = "1.2"
  tags                          = var.tags

  azuread_administrator {
    login_username = var.aad_login_username
    object_id      = var.aad_object_id
  }

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }

}
