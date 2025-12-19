variable "name" { type = string }
variable "location" { type = string }
variable "rg_name" { type = string }
variable "subnet_id" { type = string }
variable "tags" { type = map(string) }

variable "system_vm_size" { type = string }
variable "system_count" { type = number }

variable "user1_vm_size" { type = string }
variable "user1_count" { type = number }
variable "user2_vm_size" { type = string }
variable "user2_count" { type = number }

variable "enable_autoscaler_user1" { 
  type    = bool
  default = true
}

variable "user1_min_count" { type = number }
variable "user1_max_count" { type = number }

variable "enable_autoscaler_user2" { 
  type    = bool
  default = true
}

variable "user2_min_count" { type = number }
variable "user2_max_count" { type = number }
