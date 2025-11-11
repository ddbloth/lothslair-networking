variable "name" {
  type = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "sqlversion" {
  type = string
}

variable "administrator_login" {
  type = string
}

variable "administrator_login_password" {
  type      = string
  sensitive = true
}

variable "public_network_access_enabled" {
  type = bool
}

variable "aad_login_username" {
  type = string
}

variable "aad_object_id" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "Additional default tags to add to the resources being deployed at this layer. Application, Environment and Level are added by default"
}
