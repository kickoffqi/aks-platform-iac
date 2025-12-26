output "subnet_id" {
  description = "AKS subnet ID"
  value       = azurerm_subnet.aks.id
}

output "vnet_id" {
  description = "VNet ID"
  value       = azurerm_virtual_network.vnet.id
}

output "resource_group_name" {
  description = "Resource group name created for the network"
  value       = azurerm_resource_group.rg.name
}
