module "azure" {
  source                       = "./modules/azure"
  azure_resource_group_name    = var.azure_resource_group_name
  azure_location               = var.azure_location
  azure_vm_count               = var.azure_vm_count
  azure_vm_size                = var.azure_vm_size
  azure_admin_username         = var.azure_admin_username
  azure_admin_password         = var.azure_admin_password
  azure_storage_account_count  = var.azure_storage_account_count
  azure_storage_account_prefix = var.azure_storage_account_prefix
}


module "aws" {
  source            = "./modules/aws"
  aws_region        = var.aws_region
  aws_vm_count      = var.aws_vm_count
  aws_instance_type = var.aws_instance_type
  aws_ami_id        = var.aws_ami_id
  aws_bucket_count  = var.aws_bucket_count
  aws_bucket_prefix = var.aws_bucket_prefix
}