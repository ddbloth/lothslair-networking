## Shared Properties ##

variable "location" {
  type        = string
  description = "This is the programatic Azure DataCenter name the resources will be created in"
}
variable "tags" {
  type        = map(string)
  description = "Additional default tags to add to the resources being deployed at this layer. Application, Environment and Level are added by default"
}

## Module Properties ##
variable "storage_account_resource_group_name" {
  description = "The Storage Account Resource Group Name that will host a Storage Account V2 Private hosting blobs"
}

variable "name" {
  type        = string
  description = "The object name of the Storage Account V2 Private hosting blobs"
}

variable "storage_account_replication_type" {
  type        = string
  description = "The Storage Account Replication Type"
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "The sku must be one of: LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS."
  }
}

variable "storage_account_access_tier" {
  type        = string
  description = "The Storage Account Access Tier"
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool"], var.storage_account_access_tier)
    error_message = "The sku must be one of Hot or Cool."
  }
}

variable "storage_account_is_gen2" {
  type        = bool
  description = "Is Hierarchical Namespace or Gen2 SKU in the Storage Account.  Note this generally not have as deep of backup/soft delete options."
  default     = false
}
