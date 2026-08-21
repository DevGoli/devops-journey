# Lab 03 — Multi-Environment VMs with `for_each`

Builds three fully isolated environments — `dev`, `qa` and `prod` — each with its
own resource group, virtual network, subnet, public IP, NIC and Linux VM.

**Concepts:** `for_each` · `each.key` / `each.value` · `lifecycle` ·
`depends_on` · implicit dependencies · SSH key auth

**Day:** 52

## What gets built

Per environment (×3):

```
resource group  rg-<env>
└── virtual network   vnet-<env>     10.<n>.0.0/16
    └── subnet        subnet-<env>   10.<n>.1.0/24
        └── NIC       nic-<env>  ──  public IP  pp-<env>
            └── VM    vm-<env>       Ubuntu 22.04 LTS
```

CIDR ranges are derived per environment so the three networks never overlap:
dev `10.1.x`, qa `10.2.x`, prod `10.3.x`.

## Files

| File | Purpose |
|---|---|
| `provider.tf` | Terraform + `azurerm` version constraints |
| `variables.tf` | Environment map, location, admin user, SSH key path |
| `resources.tf` | All six resource types, each driven by `for_each` |

## Prerequisites

Generate the SSH keypair first:

```bash
ssh-keygen -t rsa -b 4096 -C "devopsuser" -f "$HOME\.ssh\azure_vm_key"
```

Then point `ssh_publickey_path` in `variables.tf` at the `.pub` file.

## Running it

```bash
az login --use-device-code
```

```bash
terraform init
```

```bash
terraform plan
```

Expect **18 resources** to add — six per environment.

```bash
terraform apply
```

Connect to a VM (public IP is in the Azure portal, or add an output):

```bash
ssh -i "$HOME\.ssh\azure_vm_key" devopsuser@<public-ip>
```

Always tear down — three VMs left running cost real money:

```bash
terraform destroy
```

## What I learned

- One `for_each` map drives every resource in the stack, so adding a fourth
  environment is one line in `variables.tf` rather than six new resource blocks.
- `each.value` carries the VM size while `each.key` names everything else —
  a single map does double duty.
- Referencing `azurerm_resource_group.rg[each.key].name` creates an **implicit**
  dependency, so the explicit `depends_on` lines are redundant here.


## Known improvements

Things to fix as I learn more (deliberately left visible):

- [ ] `prod` is `Standard_B1s` — the lab spec called for a larger size
- [ ] No Network Security Group — the VMs have public IPs with no inbound rules
- [ ] Nested ternaries for CIDR ranges would be cleaner as a map of objects
- [ ] No `outputs.tf` — public IPs have to be looked up in the portal
- [ ] Provider pinned `>= 4.0.0` rather than `~> 4.0`, so a v5 release could break it
