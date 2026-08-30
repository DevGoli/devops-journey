resource "aws_instance" "instance" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "Terraform-VM-${count.index + 1}"
  }

  depends_on = [aws_route_table.rtb]

}