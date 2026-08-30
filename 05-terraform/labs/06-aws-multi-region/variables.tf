variable "primary_region" {
  description = "AWS Primary Region"
  type        = string
  default     = "ap-southeast-4"
}

variable "secondary_region" {
  description = "AWS Secondary Region"
  type        = string
  default     = "ap-southeast-2"
}

variable "bucket_name" {
  description = "Name of S3 bucket"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "primary_ami" {
  description = "AMI ID for primary region"
  type        = string
}

variable "secondary_ami" {
  description = "AMI ID for secondary region"
  type        = string
}