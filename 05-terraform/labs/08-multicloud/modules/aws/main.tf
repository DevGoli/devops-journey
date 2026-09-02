resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "MultiCloudTF"
    }  
}

resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
        Name = "MultiCloudTF"
    }  
}

resource "aws_security_group" "sg" {
    name = "multicloud-sg"
    description = "Allow SSH"
    vpc_id = aws_vpc.vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

resource "aws_instance" "ec2" {
    count = var.aws_vm_count
    ami = var.aws_ami_id
    instance_type = var.aws_instance_type
    subnet_id = aws_subnet.subnet.id
    vpc_security_group_ids = [aws_security_group.sg.id]

    tags = {
        Name = "MultiCloudTF-${count.index+1}"
    }
  
}

resource "aws_s3_bucket" "bucket" {
    count = var.aws_bucket_count
    bucket = "${var.aws_bucket_prefix}-${count.index+1}"
    tags = {
        Name = "MultiCloudTF-Bucket-${count.index+1}"
    }
}