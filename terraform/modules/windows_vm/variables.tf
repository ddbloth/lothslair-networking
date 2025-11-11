variable "name" {
  type        = string
  description = "(Required) Specifies the name which should be used for this synapse Workspace. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "subnet_id" {
  type = string
}

variable "size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "timezone" {
  type = string
}

variable "os_storage_account_type" {
  type = string
}

variable "os_version" {
  type = string
}

variable "data_storage_account_type" {
  type = string
}

variable "data_disk_size_gb" {
  type = string
}


variable "tags" {
  type        = map(string)
  description = "Additional default tags to add to the resources being deployed at this layer. Application, Environment and Level are added by default"
}