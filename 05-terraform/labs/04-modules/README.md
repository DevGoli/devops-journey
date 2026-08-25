# Lab 04 — Terraform Modules

Builds a resource group, storage account and Windows VM by composing three
reusable **child modules** from one root configuration.

**Concepts:** modules · `source` · module inputs and outputs · composition

**Day:** 53

## Structure

```
04-modules/                    ← root module
├── main.tf                    calls the three child modules
├── variables.tf               inputs for the whole stack
├── providers.tf
├── terraform.tfvars.example
│
├── resource-group/            ← child module
│   ├── main.tf
│   ├── variables.tf
│   └── output.tf
├── storage-accounts/          ← child module
└── virtual-machines/          ← child module (vnet, subnet, pip, nic, VM)
```

The root module owns no resources of its own — it only wires modules together.

## How the modules connect

```hcl
module "resource_group" {
  source              = "./resource-group"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "storage_accounts" {
  source              = "./storage-accounts"
  resource_group_name = module.resource_group.resource_group_name   # ← output of one
  ...                                                               #   feeds input of the next
}
```

The storage account and VM modules both consume
`module.resource_group.resource_group_name`. That reference does two jobs:
it passes the value **and** creates the implicit dependency that guarantees
the resource group is built first.

For this to work the child module must **export** the value:

```hcl
# resource-group/output.tf
output "resource_group_name" {
  value = azurerm_resource_group.resourcerg.name
}
```

Without that `output` block, `module.resource_group.resource_group_name` does not
exist and the plan fails. **A module's variables are its inputs; its outputs are
the only things the caller can read back.** Everything else inside is private.

## Running it

```bash
cp terraform.tfvars.example terraform.tfvars
```

Set the password outside the file:

```bash
export TF_VAR_admin_password='<a-strong-password>'
```

```bash
terraform init
```

`init` is what installs modules — re-run it whenever you add a module or change
a `source`.

```bash
terraform plan
```

```bash
terraform apply
```

```bash
terraform destroy
```

## ⚠️ Secret handling

The working copy of this lab had a real VM admin password committed in
`terraform.tfvars`. That file is gitignored here, so it never reached the repo —
but the habit matters:

- `sensitive = true` (correctly set on `admin_password`) only masks the value in
  CLI output. **It is still stored in plain text in the state file.**
- Pass secrets via `TF_VAR_admin_password`, a CI/CD secret store, or Azure Key
  Vault — never a committed file.
- Better still, avoid passwords entirely: use SSH keys for Linux, or generate
  one with `random_password` and write it straight to Key Vault.

## Known improvements

- [ ] `virtual-machines` hardcodes `10.0.0.0/16`, `10.0.0.0/24` and
      `Standard_B1s` — a module that can only ever build one size and one
      address range is not really reusable. These should be variables with
      sensible defaults.
- [ ] `"${var.vm_name}.vnet"` uses a dot; everything else uses a hyphen
      (`-subnet`, `-pip`, `-nic`). Should be `-vnet` for consistency.
- [ ] Root `outputs.tf` is empty — the VM's public IP should be surfaced.
- [ ] No `tags` on any resource.
- [ ] Provider pinned `>= 4.0.0` rather than `~> 4.0`.

## What I learned

> Fill in as you go.
