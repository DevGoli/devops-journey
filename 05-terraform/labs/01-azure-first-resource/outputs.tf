output "resource_group_id" {
  description = "The Azure resource ID of the created resource group"
  value       = azurerm_resource_group.lab.id
}

output "resource_group_location" {
  description = "Region the resource group was created in"
  value       = azurerm_resource_group.lab.location
}
