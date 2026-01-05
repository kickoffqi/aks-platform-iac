data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "${var.name}-dns"

  identity {
    type = "SystemAssigned"
  }

  # system pool
  default_node_pool {
    name       = "system"
    vm_size    = var.system_vm_size
    node_count = var.system_count

    # 生产常用：系统池尽量只跑关键组件
    only_critical_addons_enabled = true

    # 让变更 VM size 等需要 rotation 时更稳（你之前遇到过）
    # 若未来要变更 vm_size，这个字段可避免报 temporary_name_for_rotation
    temporary_name_for_rotation = "sysrot" # 需要时再打开
    vnet_subnet_id              = var.subnet_id
  }

  # ✅ 关键：启用可执行的 NetworkPolicy（Calico）
  network_profile {
    network_plugin = "azure"
    network_policy = "calico"

    # （推荐）显式写出来，避免不同默认值导致行为差异
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  tags = var.tags
}
#user node pools variables to config 1 or 2 user pools
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each              = var.user_pools
  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  mode                  = "User"
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  vnet_subnet_id        = var.subnet_id
  tags                  = var.tags

  auto_scaling_enabled = each.value.enable_autoscaling
  min_count            = each.value.enable_autoscaling ? each.value.min_count : null
  max_count            = each.value.enable_autoscaling ? each.value.max_count : null
}

moved {
  from = azurerm_kubernetes_cluster_node_pool.user1
  to   = azurerm_kubernetes_cluster_node_pool.user["user1"]
}
moved {
  from = azurerm_kubernetes_cluster_node_pool.user2
  to   = azurerm_kubernetes_cluster_node_pool.user["user2"]
}

/* # user pool 1
resource "azurerm_kubernetes_cluster_node_pool" "user1" {
  name                  = "user1"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  mode                  = "User"
  vm_size               = var.user1_vm_size
  node_count            = var.user1_count
  vnet_subnet_id        = var.subnet_id
  tags                  = var.tags

  auto_scaling_enabled = var.enable_autoscaler_user1
  min_count            = var.enable_autoscaler_user1 ? var.user1_min_count : null
  max_count            = var.enable_autoscaler_user1 ? var.user1_max_count : null
}

# user pool 2
resource "azurerm_kubernetes_cluster_node_pool" "user2" {
  name                  = "user2"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  mode                  = "User"
  vm_size               = var.user2_vm_size
  node_count            = var.user2_count
  vnet_subnet_id        = var.subnet_id
  tags                  = var.tags

  auto_scaling_enabled = var.enable_autoscaler_user2
  min_count            = var.enable_autoscaler_user2 ? var.user2_min_count : null
  max_count            = var.enable_autoscaler_user2 ? var.user2_max_count : null
} */
