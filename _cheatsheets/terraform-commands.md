# Terraform Command Cheatsheet

## Core workflow

| Command | What it does |
|---|---|
| `terraform init` | Download providers, configure backend |
| `terraform validate` | Check config validity (offline) |
| `terraform fmt` | Auto-format config files |
| `terraform plan` | Show what would change |
| `terraform apply` | Make the changes |
| `terraform destroy` | Tear down all managed resources |

## State

| Command | What it does |
|---|---|
| `terraform state list` | List tracked resource addresses |
| `terraform state show <addr>` | Show one resource's attributes |
| `terraform init -migrate-state` | Move state to a new backend |

## Plan symbols

| Symbol | Meaning |
|:---:|---|
| `+` | Create |
| `-` | Destroy |
| `~` | Update in place |
| `-/+` | Destroy and recreate |

## Cloud auth

```bash
az login --use-device-code
```

```bash
az account show
```

```bash
aws configure
```

```bash
aws sts get-caller-identity
```

## Useful flags

- `-auto-approve` — skip confirmation (labs only)
- `terraform fmt -check` — fail if unformatted, for CI
- `terraform plan -out=tfplan` — save a plan, apply exactly it later

## Meta-arguments

| Argument | Purpose |
|---|---|
| `count = N` | Create N instances, addressed by index `[0]`, `[1]` … |
| `for_each = <map/set>` | Create one instance per key, addressed by key `["dev"]` |
| `depends_on = [res]` | Explicit ordering for dependencies Terraform cannot infer |
| `lifecycle { }` | `prevent_destroy`, `ignore_changes`, `create_before_destroy` |
| `provider = alias` | Target a non-default (aliased) provider |

Inside `for_each`: `each.key` and `each.value`.
Inside `count`: `count.index`.

> `count` and `for_each` are mutually exclusive on the same resource.
> Prefer `for_each` — `count` recreates everything when an index shifts.
