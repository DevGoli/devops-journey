# Terraform: Multi-Cloud Deployment & the S3 Backend

> Day 58 · Topic: Terraform

**In one line:** one `terraform apply` provisions infrastructure on Azure and
AWS simultaneously, with state held remotely in S3 — the clearest demonstration
of what "cloud-agnostic" actually buys you.

---

## The S3 remote backend

The AWS equivalent of Day 51's Azure Storage backend.

```hcl
terraform {
  backend "s3" {
    bucket       = "netflix-s3-backendtf-english"
    key          = "mc/terraform.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
```

| Setting | Purpose |
|---|---|
| `bucket` | the S3 bucket holding state |
| `key` | path to the state object — the per-environment separator |
| `region` | where the bucket lives |
| `encrypt` | server-side encryption at rest |
| `use_lockfile` | **state locking** |

As on Azure, the bucket must exist **before** you configure the backend —
Terraform cannot create the place it stores its own state. Create it in the
console or with a separate bootstrap config.

Same benefits as any remote backend: state out of Git, locking, team sharing,
and versioning (enable bucket versioning for rollback).

### `use_lockfile` vs DynamoDB

Worth knowing, because it dates you in an interview.

**Historically** the S3 backend couldn't lock on its own, so it required a
separate **DynamoDB table** with a `LockID` key, configured as `dynamodb_table`.
You'll see this in most tutorials and older codebases.

**Since Terraform 1.10**, `use_lockfile = true` uses S3 **conditional writes** to
hold the lock as an object alongside the state — no DynamoDB table needed. Fewer
moving parts, one less thing to provision and pay for.

If asked, mention both: the DynamoDB pattern is what exists in the wild, the
lockfile is the current approach.

---

## Multi-cloud in one configuration

Terraform's real advantage over ARM/Bicep or CloudFormation isn't syntax — it's
that a single workflow drives every provider.

```hcl
provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}
```

Two providers, two clouds, one `terraform apply`, **one state file** recording
both. The dependency graph spans providers, so Terraform can build Azure and AWS
resources in parallel where nothing links them.

### Structure

```
terraform-multicloud/
├── backend.tf          remote state in S3
├── providers.tf        both providers
├── main.tf             calls both modules
├── variables.tf        aws_* and azure_* inputs
├── terraform.tfvars
└── modules/
    ├── aws/            VPC, subnet, SG, EC2 ×N, S3 ×N
    └── azure/          RG, vnet, subnet, PIP, NIC, VM ×N, storage ×N
```

One module per cloud keeps each provider's resources together while the root
module stays a thin orchestrator. Variables are prefixed `aws_` / `azure_` so
there's no ambiguity about which cloud an input belongs to.

### Child modules inherit providers

Note what the child modules **don't** contain: any `provider` block. Providers
are configured once in the root module and inherited by every child.

Configuring providers inside a reusable module is an anti-pattern — it stops the
caller choosing the region or credentials, and prevents the module being used
twice with different providers. Pass values in as variables instead.

> The `aws` module declares an `aws_region` variable that nothing inside it
> uses — a leftover from this. The region reaches AWS via the root provider,
> not the module.

---

## Splat expressions

The modules surface lists of created resources:

```hcl
output "vm_ids" {
  value = aws_instance.ec2[*].id
}
```

`[*]` is the **splat operator** — "the `id` of every instance in this collection".
It's shorthand for:

```hcl
value = [for i in aws_instance.ec2 : i.id]
```

Works with `count` and `for_each`. With `count` you get a list; with `for_each`
you'd usually want `values(...)` or a `for` expression to keep the keys.

### Outputs have to be re-exported

A module's outputs are **not** automatically visible at the root. `terraform
output` shows only the root module's outputs, so a child's output must be
forwarded:

```hcl
output "aws_vm_ids" {
  value = module.aws.vm_ids
}

output "azure_vm_names" {
  value = module.azure.vm_names
}
```

Without that, the module outputs exist but nobody can see them.

---

## Passwords vs SSH keys

The Azure module uses `disable_password_authentication = false` with an
`admin_password`. That works, but it's a step back from Day 52's SSH key setup:

- The password sits in `terraform.tfvars` in plain text
- It ends up in **state** in plain text regardless of `sensitive = true`
- Password auth on an internet-facing Linux VM invites brute-force attempts

Prefer `admin_ssh_key` with `disable_password_authentication = true`. Where a
password is genuinely required, mark the variable `sensitive = true` and supply
it via `TF_VAR_azure_admin_password` or Key Vault — never a committed file.

---

## Key takeaways

- S3 backend mirrors the Azure Storage backend; `key` separates environments.
- `use_lockfile = true` replaces the older DynamoDB locking table (TF 1.10+).
- One config can drive multiple clouds — one apply, one state, one graph.
- One module per cloud; the root module orchestrates.
- **Child modules inherit providers** — never declare providers inside them.
- `[*]` is the splat operator for collecting an attribute across instances.
- Module outputs must be re-exported at the root to be visible.

Lab: [08 — Multi-cloud](../labs/08-multicloud/)
