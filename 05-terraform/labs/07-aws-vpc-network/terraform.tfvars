aws_region = "ap-southeast-4"
vpc_cidr   = "10.0.0.0/16"
subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24",
  "10.0.4.0/24"
]

subnet_names = [
  "Public-1",
  "Public-2",
  "Private-1",
  "Private-2"
]

instance_count = 4

instance_type = "t3.micro"

ami_id = "ami-01f9e32add5a43171"

bucket_count = 4

bucket_prefix = "netflix-english-adelaide-demo"