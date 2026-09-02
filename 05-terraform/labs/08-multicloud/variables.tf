# aws variables
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_vm_count" {
  description = "The number of AWS EC2 instances to create"
  type        = number
}

variable "aws_instance_type" {
  description = "The type of AWS EC2 instances"
  type        = string
}

variable "aws_ami_id" {
  description = "AMI ID"
  type        = string
}

variable "aws_bucket_count" {
  description = "AWS bucket count"
  type        = number
}

variable "aws_bucket_prefix" {
  description = "AWS Bucket prefix"
  type        = string
}


# azure variables

variable "azure_resource_group_name" {
  description = "The name of the Azure resource group to deploy resources in"
  type        = string
}

variable "azure_location" {
  description = "The azure location for the resources"
  type        = string
}

variable "azure_vm_count" {
  description = "The number of azure vms to create"
  type        = number
}

variable "azure_vm_size" {
  description = "The size of azure vms"
  type        = string
}

variable "azure_admin_username" {
  description = "The admin username"
  type        = string
}

variable "azure_admin_password" {
  description = "The admin password"
  type        = string
}

variable "azure_storage_account_count" {
  description = "The number of azure storage accounts"
  type        = number
}

variable "azure_storage_account_prefix" {
  description = "The prefix for azure storage account name"
  type        = string
}