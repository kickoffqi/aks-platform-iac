module "network" {
  source   = "../../modules/network"
  name     = var.name
  location = var.location
  rg_name  = var.rg_name
  tags     = var.tags
}

module "acr" {
  source   = "../../modules/acr"
  name     = var.name
  location = var.location
  rg_name  = var.rg_name
  tags     = var.tags

  depends_on = [module.network]
}

module "aks" {
  source   = "../../modules/aks"
  name     = var.name
  location = var.location
  rg_name  = var.rg_name

  subnet_id = module.network.subnet_id

  system_vm_size = var.system_vm_size
  system_count   = var.system_count

  user_pools = var.user_pools
  tags       = var.tags

  depends_on = [module.network]
}

# 让 AKS kubelet identity 能从 ACR 拉镜像（平台必备）
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_object_id
}
