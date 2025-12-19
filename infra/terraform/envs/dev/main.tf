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

  user1_vm_size = var.user1_vm_size
  user1_count   = var.user1_count
  user2_vm_size = var.user2_vm_size
  user2_count   = var.user2_count

  enable_autoscaler_user1 = var.enable_autoscaler_user1
  user1_min_count         = var.user1_min_count
  user1_max_count         = var.user1_max_count

  enable_autoscaler_user2 = var.enable_autoscaler_user2
  user2_min_count         = var.user2_min_count
  user2_max_count         = var.user2_max_count

  tags = var.tags

  depends_on = [module.network]
}

# 让 AKS kubelet identity 能从 ACR 拉镜像（平台必备）
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_object_id
}
