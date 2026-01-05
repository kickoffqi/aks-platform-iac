name     = "aks-platform-dev"
location = "australiaeast"
rg_name  = "rg-aks-platform-dev"

tags = {
  project = "aks-platform"
  env     = "dev"
  owner   = "jacobqi"
}

system_vm_size = "Standard_D2s_v3"
system_count   = 1

user_pools = {
  user1 = { vm_size = "Standard_D2s_v3", node_count = 1, enable_autoscaling = true, min_count = 1, max_count = 2 }
}

