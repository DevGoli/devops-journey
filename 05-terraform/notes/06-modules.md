# Terraform: Modules

> Day 53 · Topic: Terraform

**In one line:** a module is a reusable, parameterised set of Terraform config
files — write the pattern once, call it many times.

---

## The problem modules solve

Creating a VM is never one resource. It needs a resource group, a virtual
network, a subnet, a public IP and a NIC. Written by hand each time, every
engineer in the company does it slightly differently — different naming, different
sizes, different defaults. **No consistency, no standards, no reuse.**

A module packages that pattern once. The team then calls the module instead of
rewriting the resources, so organisation-wide conventions — naming, tagging,
allowed SKUs, security defaults — are baked into the template and applied
everywhere automatically.

Think of it as a buffet: a menu of prepared modules (VM, storage account,
resource group, app service plan, web app) that teams pick from as needed.

---

## Root module vs child module

Every Terraform configuration is already a module. The directory you run
`terraform apply` in is the **root module**. A module it calls is a **child
module**.

```
04-modules/                 ← root module
├── main.tf                 calls the children
├── variables.tf
└── resource-group/         ← child module
    ├── main.tf
    ├── variables.tf
    └── output.tf
```

A typical child module holds three files:

| File | Role |
|---|---|
| `main.tf` | the resources |
| `variables.tf` | **inputs** — what the caller must supply |
| `output.tf` | **outputs** — what the caller can read back |

---

## Calling a module

```hcl
module "resource_group" {
  source              = "./resource-group"
  resource_group_name = var.resource_group_name
  location            = var.location
}
```

- `module` is the block type, `"resource_group"` is the local name.
- **`source` is the only required argument** — where the module lives.
- Everything else maps to a `variable` declared inside the child module.

### Where modules can come from

| Source | Example |
|---|---|
| Local path | `"./resource-group"` |
| Terraform Registry | `"Azure/naming/azurerm"` |
| Git | `"git::https://github.com/org/modules.git//vm"` |

Registry and Git sources take a `version` argument. **Always pin it** — an
unpinned shared module can change under you between runs.

---

## Inputs and outputs are the module's contract

This is the core idea.

```hcl
# inside resource-group/output.tf
output "resource_group_name" {
  value = azurerm_resource_group.resourcerg.name
}
```

```hcl
# in the root module
resource_group_name = module.resource_group.resource_group_name
```

A module is a **black box**. The caller cannot reach inside and read
`azurerm_resource_group.resourcerg.name` directly — that resource is private to
the module. The only values that escape are the ones declared as `output`.

So: **variables in, outputs out.** Forget the `output` block and the caller gets
"Unsupported attribute", even though the resource plainly exists inside.

### Chaining modules

```hcl
module "storage_accounts" {
  source              = "./storage-accounts"
  resource_group_name = module.resource_group.resource_group_name
}
```

One module's output feeds the next module's input. That reference also creates
the **implicit dependency**, so Terraform builds the resource group first —
the same mechanism as referencing resources directly.

---

## `terraform init` installs modules

`init` does two jobs: download providers **and** install modules. Add a module
or change a `source`, and you must re-run `init` before `plan` will work.

---

## What makes a module actually reusable

A module that hardcodes its values is just a folder. If the VM module fixes
`10.0.0.0/16` and `Standard_B1s`, it can only ever build that one VM — the
second caller has to fork it, and consistency is lost again.

**Anything a caller might reasonably want to change should be a variable, with
a sensible default.** Anything that should never change — the org's naming
convention, mandatory tags, security baselines — stays hardcoded on purpose.
That tension is the whole design skill in module writing.

See: [Lab 04 — Modules](../labs/04-modules/)

---

## Key takeaways

- Modules turn a repeated pattern into a reusable, parameterised template.
- Root module = where you run `apply`; child module = what it calls.
- `source` is the only required argument; pin `version` for remote modules.
- Inputs are `variable`s, outputs are `output`s — nothing else escapes.
- Module outputs feed other modules' inputs, creating implicit dependencies.
- Re-run `terraform init` after adding or changing a module.
- Parameterise what varies; hardcode what must not.
