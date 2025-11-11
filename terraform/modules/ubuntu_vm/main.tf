# Create network interface
resource "azurerm_network_interface" "tf_nic" {
  name                = "${var.env}-${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id   =   azurerm_public_ip.tf_pip.id
  }
}

# Create virtual network
resource "azurerm_virtual_network" "tf_network" {
  name                = "${var.env}-${var.name}-vnet"
  address_space       = ["10.0.0.0/24"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create subnet
resource "azurerm_subnet" "tf_subnet" {
  name                 = "${var.env}-${var.name}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.tf_network.name
  address_prefixes     = ["10.0.0.0/26"]
}
# Create public IPs
resource "azurerm_public_ip" "tf_pip" {
  name                = "${var.env}-${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label = "${var.env}-${var.name}-vm"

}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "tf_nsg" {
  name                = "${var.env}-${var.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

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
}



# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsg_as" {
  network_interface_id      = azurerm_network_interface.tf_nic.id
  network_security_group_id = azurerm_network_security_group.tf_nsg.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "tf_diag_stg" {
  name                     = "sadi${var.env}${var.name}vm"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create (and display) an SSH key
resource "tls_private_key" "tf_vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "tf_vm" {
  name                  = "${var.env}-${var.name}-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.tf_nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = "${var.env}-${var.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "${var.vm_si_publisher}"
    offer     = "${var.vm_si_offer}"
    sku       = "${var.vm_si_sku}"
    version   = "${var.vm_si_version}"
  }

  computer_name                   = "${var.env}-${var.name}-vm"
  admin_username                  = "${var.admin_username}"
  admin_password                  = "${var.admin_password}"
  disable_password_authentication = false

#  admin_ssh_key {
#    username   = "azureuser"
#    public_key = tls_private_key.tf_vm_ssh.public_key_openssh
#  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.tf_diag_stg.primary_blob_endpoint
  }
  
}