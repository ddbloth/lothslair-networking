provider "azurerm" {

  features {}
}

locals {
  tags = {
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

resource "random_password" "vm_admin_pw" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "kv_vm_admin_pw" {
  name         = "vm-admin-pw"
  value        = random_password.vm_admin_pw.result
  content_type = "Password for VM Admin ${var.vm_adminuser}"
  key_vault_id = data.azurerm_key_vault.tf_kv.id
  tags         = local.tags
}

# Create network interface
resource "azurerm_network_interface" "tf_vm_nic" {
  name                = "tfvm-${var.location}${var.environment}-dpo-nic"
  location            = var.azureRegion
  resource_group_name = local.tf_rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.spoke_sub.id
    private_ip_address_allocation = "Dynamic"
  }

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "tf_vm_nsg" {
  name                = "nsg-${var.location}${var.environment}-dpo-tf"
  location            = var.azureRegion
  resource_group_name = local.tf_rg_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsg_as" {
  network_interface_id      = azurerm_network_interface.tf_vm_nic.id
  network_security_group_id = azurerm_network_security_group.tf_vm_nsg.id
}

# Create the VM
resource "azurerm_linux_virtual_machine" "tf_vm" {
  name                  = "vm-${var.azureRegion}-${var.environment}-dpo"
  location              = var.azureRegion
  resource_group_name   = local.tf_rg_name
  network_interface_ids = [azurerm_network_interface.tf_vm_nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = "${var.environment}-dpo-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "${var.vm_si_publisher}"
    offer     = "${var.vm_si_offer}"
    sku       = "${var.vm_si_sku}"
    version   = "${var.vm_si_version}"
  }

  computer_name                   = "vm-${var.azureRegion}-${var.environment}-dpo"
  admin_username                  = "${var.vm_adminuser}"
  admin_password                  = azurerm_key_vault_secret.kv_vm_admin_pw.value
  disable_password_authentication = false
/* Code Save - Specific to HealthPartners

  provisioner "file" {
    source      = "../cachain/hpcacertchain.crt"
    destination = "hpcacert.crt"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv hpcacert.crt /usr/local/share/ca-certificates/hpcacert.crt",
      "sudo update-ca-certificates",
      "sudo apt install unzip -y",
    ]
  }
*/

 connection {
    host     = "${self.private_ip_address}"
    type     = "ssh"
    user     = "${var.vm_adminuser}"
    password = azurerm_key_vault_secret.kv_vm_admin_pw.value
    agent    = "false"
    timeout  = "1m"
  }

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }

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

resource "azurerm_container_registry" "acr" {
  name  = "acr${var.name}${var.environment}"
  resource_group_name = azurerm_resource_group.lothslair_rg.name
  location = var.azureRegion
  sku = "Standard"
  admin_enabled = true
}

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
*/
