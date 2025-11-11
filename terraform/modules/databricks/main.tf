# Declare creation & modification of resources

resource "azurerm_databricks_workspace" "databricks" {
  name                                  = var.name
  resource_group_name                   = var.resource_group_name
  location                              = var.location
  sku                                   = var.sku
  managed_resource_group_name           = "${var.resource_group_name}-managed"
  public_network_access_enabled         = var.public_network_access_enabled
  network_security_group_rules_required = var.network_security_group_rules_required
  tags                                  = var.tags

  custom_parameters {
    no_public_ip                                         = true
    public_subnet_name                                   = var.public_subnet_name
    public_subnet_network_security_group_association_id  = var.public_subnet_network_security_group_association_id
    private_subnet_name                                  = var.private_subnet_name
    private_subnet_network_security_group_association_id = var.private_subnet_network_security_group_association_id
    virtual_network_id                                   = var.virtual_network_id
  }

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}
