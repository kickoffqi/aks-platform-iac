output "rg_name" { value = var.rg_name }
output "aks_name" { value = module.aks.aks_name }
output "acr_login_server" { value = module.acr.acr_login_server }
output "node_pools" {
  value = {
    system = module.aks.system_pool_name
    user   = module.aks.user_pool_names
  }
}
