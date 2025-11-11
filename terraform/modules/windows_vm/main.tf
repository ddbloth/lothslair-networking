resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  timezone = var.timezone
  tags     = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_storage_account_type
    name                 = "${var.name}-osdisk"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.os_version
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}

resource "azurerm_managed_disk" "datadisk" {
  name                 = "${var.name}-datadisk-01"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  tags                 = var.tags

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisk" {
  managed_disk_id    = azurerm_managed_disk.datadisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "10"
  caching            = "ReadWrite"
}
