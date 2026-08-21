# Terraform: Virtual Machines & Meta-Arguments

> Day 52 · Topic: Terraform

**In one line:** meta-arguments are special arguments that control *how* Terraform
manages a resource, rather than describing the infrastructure itself.

---

## What meta-arguments are

Every resource block takes arguments that describe the thing being built — a
VM's `size`, a resource group's `location`. **Meta-arguments are different:**
they are understood by Terraform itself rather than passed to the cloud
provider, and they change how the resource is created, ordered, or protected.

They map to nothing in Azure or AWS. Think of them as instructions to Terraform,
not to the cloud.

The problem they solve: so far each resource block created exactly *one*
resource. If you need ten resource groups, you do not want ten copy-pasted
blocks.

---

## The five common meta-arguments

### 1. `count` — create N identical instances

```hcl
resource "azurerm_resource_group" "rg" {
  count    = 10
  name     = "rg-${count.index}"
  location = "canadacentral"
}
```

Creates `rg-0` through `rg-9`. Instances are addressed by index:
`azurerm_resource_group.rg[0]`.

### 2. `for_each` — loop over a map or set

```hcl
variable "environments" {
  type = map(string)
  default = {
    dev  = "Standard_B1s"
    qa   = "Standard_B1s"
    prod = "Standard_B2s"
  }
}

resource "azurerm_resource_group" "rg" {
  for_each = var.environments
  name     = "rg-${each.key}"
  location = "canadacentral"
}
```

Inside the block, `each.key` is the map key (`dev`) and `each.value` is the
value (`Standard_B1s`). Instances are addressed by key:
`azurerm_resource_group.rg["dev"]`.

> **`count` and `for_each` cannot both be used on the same resource.**

### ⚠️ Prefer `for_each` over `count`

This is the most important practical point of the day. `count` addresses
instances **by position**. If you have `["dev", "qa", "prod"]` and remove `dev`,
everything shifts down an index — `qa` moves from `[1]` to `[0]`, `prod` from
`[2]` to `[1]`. Terraform sees this as *every* resource changing identity and
plans to **destroy and recreate all of them**.

With `for_each`, each instance is keyed by name. Removing `dev` destroys exactly
`rg["dev"]` and leaves the others untouched.

**Use `count` only for genuinely identical, interchangeable instances.**
Use `for_each` whenever instances have distinct identities.

### 3. `depends_on` — force ordering

```hcl
depends_on = [azurerm_resource_group.rg]
```

Note the syntax: an **assignment to a list**, not a block.

Terraform normally works out dependencies **implicitly**. If a storage account
references `azurerm_resource_group.rg.name`, Terraform already knows the group
must exist first — no `depends_on` needed.

`depends_on` is only for **hidden** dependencies Terraform cannot see from
references — for example a VM that needs an IAM role assignment to exist before
its startup script runs, where nothing in the VM config references the role.

Adding it where an implicit dependency already exists is harmless but redundant,
and it makes the graph coarser (Terraform waits for *all* instances rather than
the specific one it needs).

### 4. `lifecycle` — control create/destroy behaviour

```hcl
lifecycle {
  prevent_destroy = true
  ignore_changes  = [tags]
}
```

| Setting | Effect |
|---|---|
| `prevent_destroy` | Terraform errors rather than destroying this resource |
| `ignore_changes` | Ignore drift on the listed attributes |
| `create_before_destroy` | Build the replacement before removing the old one |

`ignore_changes = [tags]` is common in real environments where a governance
policy or another team adds tags automatically — without it, every `plan` shows
drift Terraform wants to revert.

### 5. `provider` — pick a non-default provider

```hcl
provider = azurerm.secondary
```

Used with aliased providers when deploying to more than one subscription or
region from the same configuration.

---

## Lab: three environments, fully isolated

Build `dev`, `qa` and `prod` VMs — each in its own resource group, virtual
network and subnet.

**Resources per environment:** resource group → virtual network → subnet →
public IP → network interface → Linux VM.

### Generating the SSH key

```bash
ssh-keygen -t rsa -b 4096 -C "devopsuser" -f "$HOME\.ssh\azure_vm_key"
```

This produces `azure_vm_key` (private) and `azure_vm_key.pub` (public). Only the
**public** key goes to the VMs:

```hcl
admin_ssh_key {
  username   = var.admin_username
  public_key = file(var.ssh_publickey_path)
}
```

`disable_password_authentication = true` forces key-only login — the correct
default for a Linux VM.

> **Never commit the private key.** `*.pem` and `*.key` are gitignored; keep the
> keypair in `~/.ssh`, outside the repo entirely.

See the working code: [Lab 03 — Multi-environment VMs](../labs/03-multi-env-vms/)

---

## Key takeaways

- Meta-arguments control Terraform's behaviour, not the infrastructure.
- `for_each` over `count` whenever instances have identities — index shifting
  under `count` causes mass recreation.
- Most dependencies are implicit; `depends_on` is for the ones Terraform
  cannot infer.
- `lifecycle` protects resources and suppresses expected drift.
- SSH keys: public key to the VM, private key never leaves your machine.
