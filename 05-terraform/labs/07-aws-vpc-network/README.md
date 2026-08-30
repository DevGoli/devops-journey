# Lab 07 — AWS VPC with Public and Private Subnets

A complete network built from scratch: VPC, four subnets across two
availability zones, internet gateway, route table, security group, four EC2
instances and four S3 buckets.

**Concepts:** VPC networking · `count` with lists · ternaries · route tables ·
implicit dependencies

**Day:** 56–57

## What it builds

```
VPC  10.0.0.0/16
├── Public-1   10.0.1.0/24  (AZ a)  ──┐
├── Public-2   10.0.2.0/24  (AZ b)  ──┤── route table ──► internet gateway
├── Private-1  10.0.3.0/24  (AZ a)    │
└── Private-2  10.0.4.0/24  (AZ b)    │
     └── 4 × t3.micro EC2, one per subnet
4 × S3 bucket
```

Public and private differ by two things: `map_public_ip_on_launch`, and whether
the subnet is associated with the route table that points at the internet
gateway. There is no "public subnet" resource type in AWS — public is a
consequence of routing.

## Driving four subnets from two lists

```hcl
resource "aws_subnet" "subnet" {
  count                   = length(var.subnet_cidrs)
  cidr_block              = var.subnet_cidrs[count.index]
  map_public_ip_on_launch = count.index < 2
  availability_zone       = "${var.aws_region}${count.index == 0 || count.index == 2 ? "a" : "b"}"
  tags = {
    Name = var.subnet_names[count.index]
    Type = count.index < 2 ? "Public" : "Private"
  }
}
```

`length()` means adding a CIDR to `terraform.tfvars` adds a subnet — no code
change. The ternaries derive AZ and public/private from position.

## The dependency chain

Every reference creates ordering, so nothing needs explicit `depends_on`:

```
aws_vpc.vpc.id
  └─► aws_subnet.subnet[*]
  └─► aws_internet_gateway.igw.id
        └─► aws_route_table.rtb.id
              └─► aws_route_table_association.public[*]
  └─► aws_security_group.sg.id
        └─► aws_instance.instance[*]  ◄── aws_subnet.subnet[count.index].id
```

`aws_vpc.vpc.id` rather than `aws_vpc.vpc` because a resource is an **object** —
you have to name which attribute you want, and the AWS API needs the ID string.

## Running it

```bash
terraform init
```

```bash
terraform plan
```

Expect 15 resources: 1 VPC + 4 subnets + 1 IGW + 1 route table + 2 associations
+ 1 security group + 4 EC2 + 4 S3... (buckets are global, so check the plan).

```bash
terraform apply
```

```bash
terraform destroy
```

## ⚠️ Known issues

- [ ] **The security group has no `egress` block.** When Terraform manages a
      security group, omitting egress **removes** AWS's default allow-all
      outbound rule — so instances can't reach the internet, install packages,
      or call AWS APIs. Needs an explicit egress rule allowing `0.0.0.0/0`.
- [ ] **SSH open to `0.0.0.0/0`** — the whole internet can reach port 22.
      Acceptable in a throwaway lab, never in real use. Should be restricted to
      a known IP, or replaced with SSM Session Manager.
- [ ] Instances have **no key pair**, so SSH isn't actually possible anyway.
- [ ] `depends_on` on the IGW, route table and instances is redundant — the
      `.id` references already create those dependencies.
- [ ] Private subnets have no NAT gateway, so private instances have no outbound
      internet at all.
- [ ] `count` on subnets is positional: removing a CIDR from the middle of the
      list shifts every later index and forces recreation. `for_each` over a map
      keyed by subnet name would be safer.
- [ ] Empty `lifecycle {}` block in `vpc.tf` with `prevent_destroy` commented
      out — remove or enable.

## What I learned

Changing the AMI from Ubuntu to Amazon Linux produced `-/+` in the plan —
**destroy and recreate**. `ami` is immutable: AWS can't swap the image on a
running instance, so Terraform terminates and relaunches. The plan says
`# forces replacement` explicitly. Harmless here; on anything with local state
it means data loss.

> Add your own observations.
