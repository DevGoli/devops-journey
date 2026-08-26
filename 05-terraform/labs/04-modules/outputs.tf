output "resource_group_name" {
  value = module.resource_group.resource_group_name
}

output "storage_account_name" {
  value = module.storage_accounts.storage_account_name
}

output "vm_name" {
  value = module.virtual_machine.vm_name
}