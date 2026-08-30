# Terraform on AWS: Providers, Aliases & Multi-Region

> Days 56–57 · Topic: Terraform

**In one line:** in AWS the *provider* carries the region, so deploying to two
regions means declaring two providers — unlike Azure, where region is just an
argument on each resource.

---

## The AWS model vs the Azure model

This is the conceptual shift.

| | Azure | AWS |
|---|---|---|
| Region set on | each **resource** (`location = "canadacentral"`) | the **provider** (`region = "ap-southeast-4"`) |
| Grouping | resource group | VPC / tags (no direct equivalent) |
| Two regions | pass a different `location` | declare a **second provider** |

In Azure you can change one argument and the resource moves region. In AWS the
region is bound to the provider connection, so a single provider can only build
in one region. This mirrors the console: you switch region in the top-right
before creating anything.

## Provider aliases

```hcl
provider "aws" {
  region = var.primary_region        # default provider
}

provider "aws" {
  alias  = "secondary"               # named alternative
  region = var.secondary_region
}
```

Resources use the default provider unless told otherwise. To target the other
one, use the `provider` **meta-argument** (from Day 52):

```hcl
resource "aws_instance" "secondary" {
  provider = aws.secondary           # note: aws.secondary, not "aws.secondary"

  ami           = var.secondary_ami
  instance_type = var.instance_type
}
```

Note the reference is **unquoted** — `aws.secondary` is a provider reference, not
a string.

### AMIs are region-specific

An AMI ID identifies an image **within one region**. `ami-01f9e32add5a43171` in
Melbourne is not the same image in Sydney, and usually doesn't exist there at
all. That's why the config carries `primary_ami` and `secondary_ami` separately.

Passing the wrong one gives `InvalidAMIID.NotFound` — a very common first AWS
error, and a good reason to look AMIs up per region rather than copying them.

---

## Answering the questions left in the code

> ```hcl
> vpc_id = aws_vpc.vpc.id   # Why is it like this and why not aws_vpc.vpc?
> ```

Because `aws_vpc.vpc` is the **whole resource object**, not a value. It holds
many attributes:

```
aws_vpc.vpc = {
  id                 = "vpc-0a1b2c3d"
  cidr_block         = "10.0.0.0/16"
  arn                = "arn:aws:ec2:..."
  default_route_table_id = "rtb-..."
  ...
}
```

The AWS API needs a specific string — the VPC's ID — so you must say **which
attribute** you want. Handing over the object would be like passing a whole
folder where a filename was expected.

Same reasoning for `gateway_id = aws_internet_gateway.igw.id`.

**Why `.id` on AWS but often `.name` on Azure?** Because the APIs identify
resources differently. AWS uses opaque generated IDs (`vpc-0a1b2c3d`); Azure
frequently accepts a resource group *name*. Which attribute a field wants is in
the provider docs under "Attributes Reference" — always check rather than guess.

The important part is unchanged from Azure: **referencing an attribute creates
the implicit dependency.** `aws_vpc.vpc.id` is unknown until the VPC exists, so
Terraform must build the VPC first.

---

## Variable precedence

Terraform resolves a variable's value in this order — **later wins**:

1. `default` in the `variable` block
2. `terraform.tfvars` (loaded automatically)
3. `*.auto.tfvars`
4. `-var-file="dev.tfvars"` on the command line
5. `-var="name=value"` on the command line
6. `TF_VAR_name` environment variable

So a variable with no `default` and no value anywhere prompts interactively —
which is why `bucket_name` and the AMI IDs must be in `terraform.tfvars`.

---

## `count` with lists

The VPC lab drives four subnets from two parallel lists:

```hcl
resource "aws_subnet" "subnet" {
  count      = length(var.subnet_cidrs)
  cidr_block = var.subnet_cidrs[count.index]
  tags       = { Name = var.subnet_names[count.index] }
}
```

`length()` means adding a fifth CIDR creates a fifth subnet with no code change.

Ternaries derive the rest from the index:

```hcl
map_public_ip_on_launch = count.index < 2                 # first two are public
Type                    = count.index < 2 ? "Public" : "Private"
availability_zone       = "${var.aws_region}${count.index == 0 || count.index == 2 ? "a" : "b"}"
```

> This is a legitimate `count` use — the subnets are positional and defined by
> ordered lists. But it carries the Day 52 caveat: **removing a CIDR from the
> middle of the list shifts every later index and Terraform will destroy and
> recreate those subnets.** A `map` with `for_each` keyed by subnet name would be
> safer, at the cost of more verbose tfvars.

---

## Day 57: watching a replacement happen

Changing the AMI from Ubuntu to Amazon Linux forces `-/+` — **destroy and
recreate**:

```
-/+ resource "aws_instance" "instance" {
      ~ ami = "ami-01f9e32..." -> "ami-0abc123..." # forces replacement
```

`ami` is an **immutable** attribute: AWS cannot swap the image on a running
instance, so Terraform must terminate and launch a new one. The plan says
`# forces replacement` explicitly.

This is the Day 50 symbol seen for real. On a stateless demo instance it costs
nothing; on a database or anything with local disk it means **data loss and
downtime**. Always read a plan for `-/+` before applying.

`create_before_destroy` in a `lifecycle` block can soften this where the resource
supports it — build the replacement first, then remove the old one.

---

## Key takeaways

- AWS binds region to the **provider**; Azure sets it per resource.
- Multi-region = multiple providers, one aliased, selected via
  `provider = aws.secondary`.
- AMI IDs are region-specific — never copy one between regions.
- `resource.name.id` — always name the attribute; the bare resource is an object.
- References create implicit dependencies on AWS exactly as on Azure.
- `-/+` means destroy and recreate, triggered by immutable attributes like `ami`.
- Variable precedence: default → tfvars → `-var-file` → `-var` → `TF_VAR_`.

Labs: [06 — AWS multi-region](../labs/06-aws-multi-region/) ·
[07 — AWS VPC network](../labs/07-aws-vpc-network/)
