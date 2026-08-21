variable "location" {
  description = "Default location for Azure resources"
  type        = string
  default     = "canadacentral"
}

variable "environments" {
  description = "Map of environments and VM sizes"
  type        = map(string)
  default = {
    "dev"  = "Standard_B1s"
    "qa"   = "Standard_B1s"
    "prod" = "Standard_B1s"
  }
}

variable "admin_username" {
  description = "Admin username for vm"
  type        = string
  default     = "devopsuser"
}

variable "ssh_publickey_path" {
  description = "SSH Key"
  type        = string
  default     = "C:/Users/Admin/.ssh/azure_vm_key.pub"

}