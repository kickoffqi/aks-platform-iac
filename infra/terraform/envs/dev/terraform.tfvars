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

user1_vm_size = "Standard_D2s_v3"
user1_count   = 1

user2_vm_size = "Standard_D2s_v3"
user2_count   = 1

enable_autoscaler_user1 = true
user1_min_count         = 1
user1_max_count         = 3

enable_autoscaler_user2 = true
user2_min_count         = 1
user2_max_count         = 3
