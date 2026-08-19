# Terraform

Infrastructure as Code with HashiCorp Terraform, on Azure and AWS.

## Notes

| # | Topic | Day |
|---|-------|-----|
| 01 | [Introduction & Setup](notes/01-intro-and-setup.md) | 48 |
| 02 | [Core Workflow & Commands](notes/02-workflow-and-commands.md) | 49 |
| 03 | [State File](notes/03-state-file.md) | 50 |
| 04 | [Remote Backend](notes/04-remote-backend.md) | 51 |

## Labs

| Lab | What it builds |
|-----|----------------|
| [01 — First Azure resource](labs/01-azure-first-resource/) | Resource group via the full init→apply→destroy workflow |
| [02 — Remote backend on Azure](labs/02-remote-backend-azure/) | Migrating local state to a locked, versioned Storage Account |

## What I can do with Terraform

- Write HCL configuration using the `azurerm` and `aws` providers
- Run the full workflow: init, validate, fmt, plan, apply, destroy
- Read a plan and understand create / update / replace behaviour
- Explain and inspect the state file, and keep it out of version control
- Configure a remote backend with state locking and versioning
