resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Terraform-VPC"
  }

  lifecycle {
    # prevent_destroy = true
  }
}

