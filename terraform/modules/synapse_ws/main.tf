resource "azurerm_synapse_workspace" "ws" {
  name                                 = var.name
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = var.storage_data_lake_gen2_filesystem_id
  sql_administrator_login              = var.sql_administrator_login
  sql_administrator_login_password     = var.sql_administrator_login_password
  managed_virtual_network_enabled      = var.managed_virtual_network_enabled
  public_network_access_enabled        = var.public_network_access_enabled
  data_exfiltration_protection_enabled = false
  sql_identity_control_enabled         = true
  managed_resource_group_name          = "${var.resource_group_name}-managed"
  tags                                 = var.tags

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}

resource "azurerm_synapse_firewall_rule" "allowAll" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.ws.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}
