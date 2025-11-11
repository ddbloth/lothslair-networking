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

# VM Parameters
variable "vm_admin_username" {
  type = string
}
variable "vm_size" {
  type = string
}
variable "vm_publisher" {
  type = string
}
variable "vm_offer" {
  type = string
} 
variable "vm_sku" {
  type = string
}
variable "vm_version" {
  type = string
  default = "latest"
}


variable "sql_administrator_login" {
  type = string
}
