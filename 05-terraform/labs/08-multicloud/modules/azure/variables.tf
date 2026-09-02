variable "azure_resource_group_name" {
    description = "The name of the Azure resource group to deploy resources in"
    type        = string
}

variable "azure_location" {
    description = "The azure location for the resources"
    type = string
}

variable "azure_vm_count" {
    description = "The number of azure vms to create"
    type = number
}

variable "azure_vm_size" {
    description = "The size of azure vms"
    type = string
}

variable "azure_admin_username" {
    description = "The admin username"
    type = string
}

variable "azure_admin_password" {
    description = "The admin password"
    type = string
}

variable "azure_storage_account_count" {
    description = "The number of azure storage accounts"
    type = number
}

variable "azure_storage_account_prefix" {
    description = "The prefix for azure storage account name"
    type = string
}