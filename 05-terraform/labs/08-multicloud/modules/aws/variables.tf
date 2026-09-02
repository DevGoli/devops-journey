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
    type = string  
}

variable "aws_ami_id" {
    description = "AMI ID"
    type = string
}

variable "aws_bucket_count" {
    description = "AWS bucket count"
    type = number
}

variable "aws_bucket_prefix" {
    description = "AWS Bucket prefix"
    type = string
}
