resource "aws_instance" "primary" {
  ami           = var.primary_ami
  instance_type = var.instance_type
  tags = {
    Name        = "Terraform-VM-Primary"
    Environment = "Development"
  }
}

resource "aws_instance" "secondary" {
  provider = aws.secondary

  ami           = var.secondary_ami
  instance_type = var.instance_type
  tags = {
    Name        = "Terraform-VM-Secondary"
    Environment = "Test"
  }
}