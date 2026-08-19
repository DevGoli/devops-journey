# Lab 01 — First Azure Resource

Creates an Azure Resource Group using the complete Terraform workflow.
The goal is the workflow itself, not the resource.

**Concepts:** providers · resources · variables · outputs · state

## Files

| File | Purpose |
|---|---|
| `providers.tf` | Terraform and `azurerm` provider version constraints |
| `variables.tf` | Input variables with defaults |
| `main.tf` | The resource group |
| `outputs.tf` | Values surfaced after apply |
| `terraform.tfvars.example` | Template for local values (real file is gitignored) |

## Running it

Authenticate and confirm the target subscription first:

```bash
az login --use-device-code
```

```bash
az account show
```

Then the workflow:

```bash
terraform init
```

```bash
terraform validate
```

```bash
terraform fmt
```

```bash
terraform plan
```

Expected: `Plan: 1 to add, 0 to change, 0 to destroy.`

```bash
terraform apply
```

Inspect what Terraform now tracks:

```bash
terraform state list
```

```bash
terraform state show azurerm_resource_group.lab
```

Clean up so the lab costs nothing:

```bash
terraform destroy
```

## What I learned

- `terraform validate` passes on config that will still fail at apply — it never
  contacts Azure, so it cannot catch a name collision or a quota problem.
- The state file appears only after the first `apply`, and `state list` is the
  quickest way to confirm what Terraform believes it owns.
- Setting `required_version` and a `~>` provider constraint keeps the config
  reproducible instead of silently picking up a new major provider version.

> Replace this section with your own observations as you work through the lab —
> this is what interviewers actually read.
