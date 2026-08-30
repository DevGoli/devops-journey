resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Terraform-IGW"
  }

  depends_on = [aws_vpc.vpc]
}