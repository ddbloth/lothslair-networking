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
  default     = "cus"
}
variable "azureRegion" {
  description = "The Azure Region the resources will be deployed to."
  type        = string
  default     = "centralus"
}

variable "vnet_cidr" {
  description = "The VNet CIDR to use"
  type        = string
}

variable "subnet_cidr" {
  description = "The subnet CIDR to use"
  type        = string 
}

variable "network_rg_name" {
  description = "The subnet CIDR to use"
  type        = string 
  default     = "rg-subnetworking"

}
