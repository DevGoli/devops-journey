# Terraform

Infrastructure as Code with HashiCorp Terraform, on Azure and AWS.

## Notes

| # | Topic | Day |
|---|-------|-----|
| 01 | [Introduction & Setup](notes/01-intro-and-setup.md) | 48 |
| 02 | [Core Workflow & Commands](notes/02-workflow-and-commands.md) | 49 |
| 03 | [State File](notes/03-state-file.md) | 50 |
| 04 | [Remote Backend](notes/04-remote-backend.md) | 51 |
| 05 | [VMs & Meta-Arguments](notes/05-vms-and-meta-arguments.md) | 52 |
| 06 | [Modules](notes/06-modules.md) | 53 |
| 07 | [Workspaces & State Operations](notes/07-workspaces-and-state-operations.md) | 54 |
| 08 | [Terraform in CI/CD](notes/08-terraform-in-cicd.md) | 55 |
| 09 | [AWS: Providers & Multi-Region](notes/09-aws-providers-and-multi-region.md) | 56–57 |
| 10 | [Multi-Cloud & the S3 Backend](notes/10-multicloud-and-s3-backend.md) | 58 |

## Interview prep

→ [Terraform interview questions](interview-questions.md)

## Labs

| Lab | What it builds |
|-----|----------------|
| [01 — First Azure resource](labs/01-azure-first-resource/) | Resource group via the full init→apply→destroy workflow |
| [02 — Remote backend on Azure](labs/02-remote-backend-azure/) | Migrating local state to a locked, versioned Storage Account |
| [03 — Multi-environment VMs](labs/03-multi-env-vms/) | dev/qa/prod VMs, each with isolated vnet and subnet, via `for_each` |
| [04 — Modules](labs/04-modules/) | RG, storage account and VM composed from three reusable child modules, with dev/qa workspaces |
| [05 — Terraform in CI/CD](labs/05-cicd-multistage/) | **Multi-stage Azure Pipeline building an app and provisioning dev + qa infrastructure** |
| [06 — AWS multi-region](labs/06-aws-multi-region/) | EC2 in two AWS regions via provider aliases |
| [07 — AWS VPC network](labs/07-aws-vpc-network/) | VPC, public/private subnets across two AZs, IGW, route table, EC2 and S3 |
| [08 — Multi-cloud](labs/08-multicloud/) | **Azure and AWS provisioned together in one apply, state in S3** |

## What I can do with Terraform

- Write HCL configuration using the `azurerm` and `aws` providers
- Run the full workflow: init, validate, fmt, plan, apply, destroy
- Read a plan and understand create / update / replace behaviour
- Explain and inspect the state file, and keep it out of version control
- Configure a remote backend with state locking and versioning
- Use meta-arguments (`for_each`, `count`, `lifecycle`, `depends_on`) to build repeatable multi-environment infrastructure
- Provision Linux VMs with networking and SSH key authentication
- Write and compose reusable modules with typed inputs and outputs
- Handle secrets correctly — no credentials in committed files or state in Git
- Manage multiple environments with workspaces, and reconcile drift with `-refresh-only`
- Run Terraform from a multi-stage CI/CD pipeline with per-environment remote state
- Debug real pipeline and provider failures from logs
- Work across both Azure and AWS, including AWS provider aliases and VPC networking
- Deploy to multiple clouds from a single configuration with remote state and locking
