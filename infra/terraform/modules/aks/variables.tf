variable "name" { type = string }
variable "location" { type = string }
variable "rg_name" { type = string }
variable "subnet_id" { type = string }
variable "tags" { type = map(string) }

variable "system_vm_size" { type = string }
variable "system_count" { type = number }

variable "user_pools" {
  type = map(object({
    vm_size            = string
    node_count         = number
    enable_autoscaling = bool
    min_count          = number
    max_count          = number
  }))
  validation {
    condition     = length(var.user_pools) >= 1 && length(var.user_pools) <= 2
    error_message = "user_pools must contain 1 or 2 pools."
  }
}
