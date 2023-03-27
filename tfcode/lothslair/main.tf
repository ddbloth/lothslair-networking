provider "azurerm" {

  features {}
}

locals {
  tags = {
    "Business Unit"    = "Application"
    DataClassification = "Cost Center"
    MaintenanceWindow  = "Owner"
    Owner              = "Loth's Lair"
    Project            = "Loths Lair"
    Environment        = var.environment
    Toolkit            = "terraform"
  }

  rg_name = "rg-${var.azureRegion}-${var.environment}-lothslair"

}

resource "azurerm_resource_group" "lothslair_rg" {
  location = var.azureRegion
  name     = local.rg_name
  tags     = local.tags
}

resource "azurerm_container_registry" "acr" {
  name  = "acr${var.name}${var.environment}"
  resource_group_name = azurerm_resource_group.lothslair_rg.name
  location = var.azureRegion
  sku = "Standard"
  admin_enabled = true
}

module "lothslair_vm" {
  source = "../modules/ubuntu_vm"

  location                            = var.azureRegion
  resource_group_name                 = azurerm_resource_group.lothslair_rg.name
  name                                = "${var.name}"
  env                                 = "${var.environment}"
  tags                                = local.tags
  vm_size                             = "${var.vm_size}"
  vm_si_offer                         = "${var.vm_si_offer}"
  vm_si_sku                           = "${var.vm_si_sku}"
  admin_username					  = "${var.vm_adminuser}"
  admin_password					  = random_password.vm_admin_pw.result
}

/*
# Deploy MS SQL Server & DB
resource "azurerm_mssql_server" "piwigo_mssql_svr" {
  count     =   
  name                          = "${var.environment}-${var.name}-db-svr"
  resource_group_name           = azurerm_resource_group.lothslair_rg.name
  location                      = var.azureRegion
  version                       = "12.0"
  administrator_login           = "sqladminuser"
  administrator_login_password  = random_password.sql_admin_pw.result
  public_network_access_enabled = true
  tags                          = local.tags
}
resource "azurerm_mssql_database" "piwigo_db" {
  name                 = "${var.environment}-${var.name}-db"
  server_id            = azurerm_mssql_server.piwigo_mssql_svr.id
  storage_account_type = "Local"
}
*/

# Key Vault Deployment
resource "azurerm_key_vault" "keyvault" {
  name                       = "kv-${var.environment}-${var.name}"
  location                   = azurerm_resource_group.lothslair_rg.location
  resource_group_name        = azurerm_resource_group.lothslair_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = true
    
}

# Key Vault RBAC Assignments
resource "azurerm_role_assignment" "kv_ado_rbac" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
resource "azurerm_role_assignment" "kv_admin_rbac" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azuread_user.user.object_id
}

# Rando Password Generation
resource "random_password" "sql_admin_pw" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "random_password" "vm_admin_pw" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store Randos in the Vault
resource "azurerm_key_vault_secret" "kv_sql_admin_pw" {
  depends_on = [
    azurerm_role_assignment.kv_ado_rbac
  ]
  name         = "sql-admin-pw"
  value        = random_password.sql_admin_pw.result
  content_type = "Password for sqladminuser"
  key_vault_id = azurerm_key_vault.keyvault.id
  tags         = local.tags
}
resource "azurerm_key_vault_secret" "kv_vm_admin_pw" {
  depends_on = [
    azurerm_role_assignment.kv_ado_rbac
  ]
  name         = "vm-admin-pw"
  value        = random_password.vm_admin_pw.result
  content_type = "Password for VM Admin ${var.vm_adminuser}"
  key_vault_id = azurerm_key_vault.keyvault.id
  tags         = local.tags
}

resource "azurerm_virtual_machine_extension" "vm-ado-install" {
  name                 = module.lothslair_vm.name
  virtual_machine_id   = module.lothslair_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "commandToExecute": "hostname && uptime"
 }
SETTINGS


  tags = {
    environment = "${var.environment}"
  }
}