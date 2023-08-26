# Basic Deployment Variables
variable "name" {
  type = string
  default = "lothslair"
  
}
variable "environment" {
  description = "The environment name that will be used in the RG Name and in Tags."
  type        = string
  default     = "dev"
}
variable "location" {
  description = "The Azure Region the resources will be deployed to."
  type        = string
  default     = "eus"
}
variable "azureRegion" {
  description = "The Azure Region the resources will be deployed to."
  type        = string
  default     = "eastus"
}

# Vnet/Subnet vars
variable "spoke_vnet_rg_name" {
  description = "The name of the Netowrking Resource Group"
  type        = string
  
}
variable "spoke_vnet_name" {
  description = "The name of the vNet"
  type        = string
}

variable "spoke_subnet_name" {
  description = "The name of the subnet in the vNet"
  type        = string
  
}

# Terraform KV Name & RG
/* Made them locals
variable "tf_kv_name" {
  description = "The resource name of the terraform key vault"
  type        = string
}  
variable "tf_rg_name" {
  description = "The resource name of the terraform resources"
  type        = string
} 
*/

# VM Parameters
variable "vm_adminuser" {
  type = string
}

variable "vm_size" {
  type = string
}

# VM Source Image
variable "vm_si_publisher" {
  type = string
  default = "Canonical"
}
variable "vm_si_offer" {
  type = string
  default = "0001-com-ubuntu-server-jammy"
} 
variable "vm_si_sku" {
  type = string
  default = "22_04-lts"
}
variable "vm_si_version" {
  type = string
  default = "latest"
}


variable "sql_administrator_login" {
  type = string
}
