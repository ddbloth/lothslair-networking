variable "name" {
  description = "name of the private endpoint"
  type        = string
}

variable "location" {
  description = "location of deployment"
  type        = string
}

variable "resource_group" {
  description = "resource group that the pe should be deployed to"
  type        = string
}

variable "pe_subnet_id" {
  description = "subnet to deploy the private endpoint to"
  type        = string
}

variable "resource_id" {
  type = string
}

variable "subresource_names" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}