variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "subnet_cidrs" {
  description = "Subnet CIDRs"
  type        = list(string)
}

variable "subnet_names" {
  description = "Subnet names"
  type        = list(string)
}

variable "instance_count" {
  description = "No of EC2 Instances"
  type        = number
}

variable "instance_type" {
  description = "EC2 instnace type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "bucket_count" {
  description = "No of S3 buckets"
  type        = number
}

variable "bucket_prefix" {
  description = "Prefix for S3 buckets"
  type        = string
}
