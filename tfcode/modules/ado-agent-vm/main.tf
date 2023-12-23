provider "azurerm" {
  features {}
}

###
# Azure DevOps Self-Hosted VM Deployment Module
###

###
# Generate Admin Password
###
resource "random_password" "admin_pw" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

###
# Store Admin Password in KeyVault
###
resource "azurerm_key_vault_secret" "vm_admin_pw" {
  name         = "vm-${var.vm_name}-admin-pw"
  value        = random_password.admin_pw.result
  content_type = "Password for ${var.admin_username}"  # default: vmadminuser
  key_vault_id = var.keyvault_id   # --> Required
  tags         = var.tags

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}


resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-vm-${var.vm_name}"
  location            = var.azureRegion
  resource_group_name = var.rg_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

    lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}


resource "azurerm_network_security_group" "vm_nsg" {
  name                = "nsg-${var.vm_name}"
  location            = var.azureRegion
  resource_group_name = var.rg_name
  tags                = var.tags

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


resource "azurerm_network_interface_security_group_association" "vm_nsg_as" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-${var.vm_name}"
  location              = var.azureRegion
  resource_group_name   = var.rg_name
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  size                  = var.vm_size
  tags                  = var.tags

  os_disk {
    name                 = "vm-osdisk-${var.vm_name}"
    caching              = "ReadWrite"
    storage_account_type = var.vm_storage_account_type  # Default "Premium_LRS"
  }

  source_image_reference {
    publisher = "${var.vm_publisher}"
    offer     = "${var.vm_offer}"
    sku       = "${var.vm_sku}"
    version   = "${var.vm_version}"
  }

  computer_name                   = "vm-${var.vm_name}"
  admin_username                  = "${var.admin_username}"
  admin_password                  = azurerm_key_vault_secret.vm_admin_pw.value
  disable_password_authentication = false

  provisioner "file" {
    source      = "${path.module}/cachain/hpcacertchain.crt"
    destination = "hpcacert.crt"
  }

  provisioner "file" {
    source      = "${path.module}/cachain/azcacert.pem"
    destination = "azcacert.pem"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/environment"
    destination = "environment"
  }

  provisioner "remote-exec" {
    inline = [
      "#sudo mv hpcacert.crt /usr/local/share/ca-certificates/hpcacert.crt",
      "#sudo update-ca-certificates",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install unzip -y",
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
      "sudo apt-get install python3-pip -y",
      "#sudo mv azcacert.pem /opt/az/lib/python*/site-packages/certifi/cacert.pem",
      "#sudo mv environment /etc/environment",
      "sudo apt-get install -y wget apt-transport-https software-properties-common",
      "wget --no-check-certificate https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb",
      "sudo dpkg -i packages-microsoft-prod.deb",
      "rm packages-microsoft-prod.deb",
      "sudo apt-get update",
      "sudo apt-get install -y powershell"
    ]
  }

  connection {
    host     = "${self.private_ip_address}"
    type     = "ssh"
    user     = "${var.admin_username}"
    password = azurerm_key_vault_secret.vm_admin_pw.value
    agent    = "false"
    timeout  = "10m"
  }

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
  
}


resource "azurerm_virtual_machine_extension" "vm_install_agent" {
  name                 = "vm_install_agent"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  tags                 = var.tags

  settings = <<SETTINGS
    {
        "script": "${filebase64("${path.module}/scripts/ado-agent-install.sh")}"
    }
SETTINGS

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}
