variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
  default     = "rg-terraform-lab"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "australiaeast"
}

variable "tags" {
  description = "Tags applied to every resource"
  type        = map(string)
  default = {
    environment = "learning"
    managed_by  = "terraform"
  }
}
