output "aks_name" { value = azurerm_kubernetes_cluster.aks.name }

output "kubelet_object_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "system_pool_name" { value = "system" }
output "user1_pool_name" { value = azurerm_kubernetes_cluster_node_pool.user1.name }
output "user2_pool_name" { value = azurerm_kubernetes_cluster_node_pool.user2.name }
