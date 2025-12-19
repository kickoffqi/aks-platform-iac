output "rg_name" { value = var.rg_name }
output "aks_name" { value = module.aks.aks_name }
output "acr_login_server" { value = module.acr.acr_login_server }
output "node_pools" {
  value = {
    system = module.aks.system_pool_name
    user1  = module.aks.user1_pool_name
    user2  = module.aks.user2_pool_name
  }
}
