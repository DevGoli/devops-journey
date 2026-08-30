resource "aws_subnet" "subnet" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id # Question: Why is it like this and why not aws_vpc.vpc`    
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = "${var.aws_region}${count.index == 0 || count.index == 2 ? "a" : "b"}"
  map_public_ip_on_launch = count.index < 2
  tags = {
    Name = var.subnet_names[count.index]
    Type = count.index < 2 ? "Public" : "Private"
  }
}