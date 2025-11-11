output "id" {
  description = "The ID of the Synapse Workspace."
  value       = azurerm_synapse_workspace.ws.id
}

output "connectivity_endpoints" {
  description = "A list of Connectivity endpoints for this Synapse Workspace."
  value       = azurerm_synapse_workspace.ws.connectivity_endpoints
}

output "managed_resource_group_name" {
  description = "Workspace managed resource group."
  value       = azurerm_synapse_workspace.ws.managed_resource_group_name
}
output "principal_id" {
  value = azurerm_synapse_workspace.ws.identity[0].principal_id

}