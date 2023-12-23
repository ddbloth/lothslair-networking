###
# Misc Parameters
###
variable "environment" {
  description = "The environment name that will be used in the RG Name and in Tags."
  type        = string
}

variable "azureRegion" {
  description = "The Azure Region the resources will be deployed to."
  type        = string
  default     = "centralus"
}

variable "tags" {
  description = "Tags to add to deployed resource"
  type        = map
}

###
# Resource Group
###
variable "rg_name" {
  description = "Required: SubNet Resource ID where VM will be deployed"
  type        = string
}

###
# Network Parameters
###
variable "subnet_id" {
  description = "Required: SubNet Resource ID where VM will be deployed"
  type        = string
}

###
# Keyvault
###
variable "keyvault_id" {
  description = "Required: KeyVault Resource ID where Admin Passwrd is stored"
  type        = string
}

###
# VM Resource Parameters
###
variable "admin_username" {
  description = "Username for the VM Administration User"
  type = string
  default = "vmadminuser"
}

variable "vm_name" {
  description = "Required: Name of the VM:  Naming STandard --> region-environment-*app-identifiers*"
  type        = string
}


###
# VM Physical Parameters
###
variable "vm_size" {
  description = "VM Size String, as detemined here: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes"
  type = string
  default = "Standard_B1ms"
}


# VM Image Parameters
# parameters privded from :
#     az vm image list
#
# Default: 20.04 LTS Ubuntu
###
variable "vm_publisher" {
  description = "Image Publisher"
  type = string
  default = "Canonical"
}

variable "vm_offer" {
  description = "Azure Image Offer String"
  type = string
  default = "0001-com-ubuntu-server-focal"
} 

variable "vm_sku" {
  description = "Azure Image SKU"
  type = string
  default = "20_04-lts"
}

variable "vm_version" {
  description = "Image Version"
  type = string
  default = "latest"
}

variable "vm_storage_account_type" {
  description = "Storage account type to use for VM Disk"
  type = string
  default = "Premium_LRS"

}


