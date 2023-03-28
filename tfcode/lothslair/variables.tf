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

# Terraform KV Name & RG
variable "tf_kv_name" {
  description = "The resource name of the terraform key vault"
  type        = string
}  
variable "tf_kv_rg_name" {
  description = "The resource name of the terraform key vault"
  type        = string
} 

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
  default = "0001-com-ubuntu-minimal-kinetic"
} 
variable "vm_si_sku" {
  type = string
  default = "minimal-22_10"
}
variable "vm_si_version" {
  type = string
  default = "latest"
}


variable "sql_administrator_login" {
  type = string
}
