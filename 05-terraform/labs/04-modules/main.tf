module "resource_group" {
  source              = "./resource-group"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "storage_accounts" {
  source               = "./storage-accounts"
  location             = var.location
  storage_account_name = var.storage_account_name
  resource_group_name  = module.resource_group.resource_group_name
}

module "virtual_machine" {
  source              = "./virtual-machines"
  vm_name             = var.vm_name
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
  admin_password      = var.admin_password
  admin_username      = var.admin_username
}