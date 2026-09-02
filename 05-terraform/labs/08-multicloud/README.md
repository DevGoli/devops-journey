# Lab 08 — Multi-Cloud: Azure + AWS in One Apply

Provisions infrastructure on **both clouds simultaneously** from a single
configuration, with remote state in an S3 bucket.

**Concepts:** multiple providers · module per cloud · S3 backend · state
locking · splat expressions

**Day:** 58

## What it builds

| Azure | AWS |
|---|---|
| resource group | VPC `10.0.0.0/16` |
| vnet + subnet | subnet `10.0.1.0/24` |
| 2 × public IP + NIC | security group |
| 2 × Linux VM (Ubuntu 22.04) | 2 × EC2 (t3.micro) |
| 2 × storage account | 2 × S3 bucket |

One `terraform apply`. One state file recording both clouds.

## Structure

```
08-multicloud/
├── backend.tf              state in S3, with locking
├── providers.tf            aws + azurerm
├── main.tf                 calls both modules
├── variables.tf            aws_* and azure_* inputs
└── modules/
    ├── aws/
    └── azure/
```

The root module owns no resources — it wires the two cloud modules together.
Variables are prefixed by cloud so there's never ambiguity about where an input
lands.

## Remote state in S3

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

`use_lockfile = true` (Terraform 1.10+) does state locking with S3 conditional
writes. Older setups needed a separate **DynamoDB table** via `dynamodb_table` —
still common in existing codebases, worth recognising.

The bucket must be created **before** `init` — Terraform can't create the place
it stores its own state.

## Running it

Authenticate to both clouds:

```bash
az login --use-device-code
```

```bash
aws configure
```

Supply the password out of band rather than in a file:

```bash
export TF_VAR_azure_admin_password='<a-strong-password>'
```

```bash
cp terraform.tfvars.example terraform.tfvars
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

- [ ] **Root `outputs.tf` is empty.** Both modules define outputs (`vm_ids`,
      `bucket_names`, `vm_names`, `storage_account_names`) but they aren't
      re-exported, so `terraform output` shows nothing. Needs
      `value = module.aws.vm_ids` etc. at the root.
- [ ] **AWS security group has no `egress` block** — Terraform managing the
      group removes AWS's default allow-all outbound rule, so the EC2 instances
      have no internet access.
- [ ] **SSH open to `0.0.0.0/0`** on the AWS security group, and no key pair on
      the instances.
- [ ] **Azure VMs use password auth** (`disable_password_authentication = false`).
      SSH keys would be better; the password is also stored in plain text in
      state regardless.
- [ ] `azure_admin_password` variable isn't marked `sensitive = true`, so it can
      appear in CLI output.
- [ ] The `aws` module declares an unused `aws_region` variable — providers are
      inherited from the root, so the child never needs it.
- [ ] Providers pinned `>=` rather than `~>`.
- [ ] No tags on the AWS VPC/subnet beyond `Name`, and no environment tagging
      scheme across either cloud.

## What I learned

> Fill in as you go. Worth capturing: whether Azure and AWS resources were
> created in parallel, and what the S3 lock object looked like during the apply.
