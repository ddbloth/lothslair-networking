### PASSED IN FROM PARAMETERS
variable "location" {
  description = "(optional) region for the deployment; default -> centralus"
  type        = string
  default     = "cus"
}

variable "name" {
  description = "Name of the resource group creation, this is passed in from the rg_names list"
  type        = string

}

variable "tags" {
  description = "Map of tags to add to RG"
  type        = map(string)
}