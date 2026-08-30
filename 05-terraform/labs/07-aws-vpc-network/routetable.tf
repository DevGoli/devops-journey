resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id # AGain why not  gateway_id = aws_internet_gateway.igw
  }

  tags = {
    Name = "Public-Route-Table"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.rtb.id
}