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

variable "storage_data_lake_gen2_filesystem_id" {
  description = "The ID of the Datalake filesystem to be used by Synapse."
}

variable "sql_administrator_login" {
  type        = string
  description = "(Required) Specifies The Login Name of the SQL administrator. Changing this forces a new resource to be created."
}

variable "sql_administrator_login_password" {
  type        = string
  description = "(Required) The Password associated with the sql_administrator_login for the SQL administrator."
}

variable "managed_virtual_network_enabled" {
  type        = bool
  description = "(Optional) Is Virtual Network enabled for all computes in this workspace? Defaults to false. Changing this forces a new resource to be created."
  default     = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "(Optional) Whether public network access is allowed for the Cognitive Account. Defaults to true."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Additional default tags to add to the resources being deployed at this layer. Application, Environment and Level are added by default"
}