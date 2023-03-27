variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type = string
}

variable "public_network_access_enabled" {
  type = bool
}

variable "network_security_group_rules_required" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "public_subnet_name" {
  type = string
}

variable "public_subnet_network_security_group_association_id" {
  type = string
}

variable "private_subnet_name" {
  type = string
}

variable "private_subnet_network_security_group_association_id" {
  type = string
}

variable "virtual_network_id" {
  type = string
}