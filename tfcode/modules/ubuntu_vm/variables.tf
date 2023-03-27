variable "name" {
  type        = string
  description = "(Required) Specifies the name which should be used for resources to be created."
}

variable "env" {
  type        = string
  description = "(Required) Specifies the Enviroinment Name tp be used in resource names."
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

# VM Parameters
variable "admin_username" {
  type = string
}
variable "admin_password" {
  type = string
}
variable "vm_size" {
  type = string
}
variable "tags" {
  type        = map(string)
  description = "Additional default tags to add to the resources being deployed at this layer. Application, Environment and Level are added by default"
}

# VM Source Image
variable "vm_si_publisher" {
  type = string
  default = "Canonical"
}
variable "vm_si_offer" {
  type = string
  default = "0001-com-ubuntu-minimal-bionic"
} 
variable "vm_si_sku" {
  type = string
  default = "minimal-18_04-lts"
}
variable "vm_si_version" {
  type = string
  default = "latest"
}
    