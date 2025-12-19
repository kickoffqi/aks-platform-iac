variable "name" {
  type        = string
  description = "Base name for resources (e.g. aks-platform-dev)"
}

variable "location" {
  type    = string
  default = "australiaeast"
}

variable "rg_name" {
  type        = string
  description = "Resource group name"
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Node pools
variable "system_vm_size" { type = string }
variable "system_count" { type = number }

variable "user1_vm_size" { type = string }
variable "user1_count" { type = number }

variable "user2_vm_size" { type = string }
variable "user2_count" { type = number }

# Autoscaler（建议 user pools 开，system 不开）
variable "enable_autoscaler_user1" {
  type    = bool
  default = true
}
variable "user1_min_count" {
  type    = number
  default = 1
}
variable "user1_max_count" {
  type    = number
  default = 3
}

variable "enable_autoscaler_user2" {
  type    = bool
  default = true
}
variable "user2_min_count" {
  type    = number
  default = 1
}
variable "user2_max_count" {
  type    = number
  default = 3
}
