# Terraform: State File

> Day 50 · Topic: Terraform

**In one line:** the state file is a JSON file that acts as the single source of
truth for your managed infrastructure, mapping your declarative code to the real
resources in the cloud.

---

## What it is

After the first `terraform apply`, Terraform writes **`terraform.tfstate`** into
the working directory. It stores the current state of every resource Terraform
manages, including resource IDs and attribute values returned by the provider.

Terraform needs it because HCL only describes *what you want*. State is how
Terraform remembers *what it already built*, so on the next run it can work out
the difference. Without state, Terraform would try to create everything again.

`terraform.tfstate.backup` is the previous version, written automatically before
each state change.

---

## Inspecting state

### `terraform state list`

```bash
terraform state list
```

Lists all resource addresses currently tracked in the state file.

### `terraform state show`

```bash
terraform state show azurerm_resource_group.example
```

Shows the full recorded attributes of one resource — takes the address from
`state list`.

---

## ⚠️ Never commit state to Git

`terraform.tfstate` and `terraform.tfstate.backup` must be excluded from version
control. State is stored in **plain text** and contains subscription IDs,
resource identifiers, and any sensitive values a resource produced — passwords,
connection strings, keys.

```gitignore
*.tfstate
*.tfstate.*
```

Committing state also causes merge conflicts the moment two people run Terraform,
which is what the remote backend solves — see [Remote Backend](04-remote-backend.md).

---

## Reading a plan

`terraform plan` marks each change with a symbol:

| Symbol | Meaning |
|:---:|---|
| `+` | Create a new resource |
| `-` | Destroy the resource |
| `~` | Update in place |
| `-/+` | Destroy and recreate (a change to an immutable attribute) |
| *(none)* | No change |

`-/+` is the one to watch. It means the resource cannot be changed in place and
will be **replaced** — which for something like a database or a disk can mean
data loss and downtime.

---

## Key takeaways

- State maps your code to real infrastructure; Terraform cannot work without it.
- State is plain text and sensitive — never in Git.
- `state list` to find resources, `state show` to inspect one.
- Watch for `-/+` in a plan: that is a destroy-and-recreate.
