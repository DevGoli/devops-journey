# DevOps Learning Journey

Hands-on notes and labs from my daily DevOps study, currently on **Day 53**.
Everything here is written and run by me — notes in my own words, and working
infrastructure code I have actually deployed and destroyed.

**Currently focused on:** Terraform (Infrastructure as Code) on Azure and AWS.

Covered so far: **CI/CD with Azure Pipelines** and **Terraform**.

---

## Terraform

| # | Topic | Days | Status |
|---|-------|------|--------|
| 01 | [Introduction & Setup](05-terraform/notes/01-intro-and-setup.md) | 48 | ✅ |
| 02 | [Core Workflow & Commands](05-terraform/notes/02-workflow-and-commands.md) | 49 | ✅ |
| 03 | [State File](05-terraform/notes/03-state-file.md) | 50 | ✅ |
| 04 | [Remote Backend](05-terraform/notes/04-remote-backend.md) | 51 | ✅ |
| 05 | [VMs & Meta-Arguments](05-terraform/notes/05-vms-and-meta-arguments.md) | 52 | ✅ |
| 06 | [Modules](05-terraform/notes/06-modules.md) | 53 | ✅ |

## CI/CD

| # | Topic | Day | Status |
|---|-------|-----|--------|
| 01 | [Azure DevOps & Continuous Integration](04-cicd/notes/01-azure-devops-and-ci.md) | 44 | ✅ |

Earlier topics (Linux, Git, Docker, Kubernetes) and later ones (Ansible, more
CI/CD) will be added as separate folders.

## Labs

| Lab | What it builds |
|-----|----------------|
| [01 — First Azure resource](05-terraform/labs/01-azure-first-resource/) | Resource group via the full init→apply→destroy workflow |
| [02 — Remote backend on Azure](05-terraform/labs/02-remote-backend-azure/) | Migrating local state to a locked, versioned Storage Account |
| [03 — Multi-environment VMs](05-terraform/labs/03-multi-env-vms/) | dev/qa/prod VMs with isolated networking, via `for_each` |
| [04 — Modules](05-terraform/labs/04-modules/) | RG, storage account and VM composed from reusable child modules |
| [CI/CD 01 — Azure Pipelines for .NET](04-cicd/labs/01-azure-pipelines-dotnet/) | ASP.NET Core app built by a CI pipeline on a hosted agent |

## Interview prep

Questions and answers written up as I go, in my own words:

- [Terraform](05-terraform/interview-questions.md)
- [CI/CD](04-cicd/interview-questions.md)

## Reference

- [Terraform command cheatsheet](_cheatsheets/terraform-commands.md)

---

## Repository structure

```
├── 05-terraform/       Infrastructure as Code
│   ├── notes/          concepts, in my own words, tagged by day
│   └── labs/           working code, each with its own README
├── 04-cicd/            Azure Pipelines
│   ├── notes/
│   └── labs/
└── _cheatsheets/       quick command references
```

Notes carry the day number they came from, so the daily timeline is preserved
without exploding into 100+ folders.

---

## A note on secrets

State files, `*.tfvars`, keys and kubeconfigs are excluded via
[`.gitignore`](.gitignore). Terraform state is stored in a remote backend, never
in version control — it is plain text and can expose subscription IDs and
resource metadata. Example variable files are committed as `*.tfvars.example`
with placeholder values.

---

## About me

Dev Goli — transitioning into DevOps / Cloud Infrastructure engineering.

- LinkedIn: _add link_
- Contact: _add email or portfolio link_
