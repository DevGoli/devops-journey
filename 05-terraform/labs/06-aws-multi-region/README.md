# Lab 06 — AWS Multi-Region with Provider Aliases

An EC2 instance in each of two AWS regions, plus an S3 bucket, from one
configuration.

**Concepts:** provider aliases · the `provider` meta-argument · region-specific
AMIs

**Day:** 56

## What it builds

| Resource | Region | Provider |
|---|---|---|
| `aws_instance.primary` | `ap-southeast-4` (Melbourne) | default |
| `aws_instance.secondary` | `ap-southeast-2` (Sydney) | `aws.secondary` |
| `aws_s3_bucket.s3` | `ap-southeast-4` | default |

## The pattern

```hcl
provider "aws" {
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}
```

```hcl
resource "aws_instance" "secondary" {
  provider = aws.secondary      # unquoted - a provider reference, not a string
  ami      = var.secondary_ami  # region-specific!
}
```

In AWS the region belongs to the **provider**, not the resource — the opposite of
Azure, where `location` is an argument on each resource. So a second region means
a second provider.

## Running it

```bash
aws configure
```

```bash
aws sts get-caller-identity
```

```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply
```

```bash
terraform destroy
```

## Known improvements

- [ ] Only **one** S3 bucket is created, in the primary region. The exercise
      called for one per region — the second needs
      `provider = aws.secondary` and its own globally-unique name.
- [ ] `bucket_name` is a single variable, so a second bucket can't reuse it.
- [ ] S3 bucket has no versioning, encryption or public-access block.
- [ ] Instances have no security group, key pair or subnet — they land in the
      default VPC. Lab 07 addresses this properly.
- [ ] Provider pinned `>= 5.0` rather than `~> 5.0`.
- [ ] Tag casing is inconsistent (`name` on the bucket, `Name` on instances).
      AWS treats tag keys as case-sensitive, and the console displays `Name`.

## What I learned

> Fill in as you go.
