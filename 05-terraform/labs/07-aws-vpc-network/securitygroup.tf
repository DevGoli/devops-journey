resource "aws_security_group" "sg" {
  name        = "ec2-sg"
  description = "Security group for terraform EC2 instances"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Terrafrom-EC2-SG"
  }
}