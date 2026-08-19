# Terraform: Introduction & Setup

> Day 48 · Topic: Terraform

**In one line:** Terraform is an open-source Infrastructure as Code tool that
lets you define cloud resources in human-readable config files and create them
consistently across multiple providers.

---

## Background

- Created by **HashiCorp**, founded by Mitchell Hashimoto — Terraform released **2014**.
- HashiCorp was **acquired by IBM** (deal announced 2024, closed 2025).

## Why Terraform

| Advantage | Why it matters |
|---|---|
| Multi-cloud | One tool and one language for Azure, AWS, GCP and more |
| Open source | Free to use, huge provider ecosystem |
| Git-friendly | Config is text, so version control, code review and PRs all work |
| Collaboration | Team reviews infrastructure the same way it reviews application code |
| Easy to learn | Declarative, readable syntax |

## HCL

Terraform uses **HCL — HashiCorp Configuration Language**. It is *declarative*:
you describe the **desired end state**, not the steps to get there. Terraform
works out what to create, change or destroy to reach that state.

---

## Infrastructure as Code

**Definition:** managing IT infrastructure through configuration files rather
than manual clicking in a portal.

**Benefits:**

- Cost reduction — resources are torn down as easily as they are created
- Faster deployments — repeatable, no manual steps
- Fewer errors — no human clicking through portals
- Consistency — dev, test and prod built from the same code
- **Eliminates configuration drift**

### Configuration drift

Drift is when real infrastructure no longer matches the code — for example
someone manually resizes a disk from 30 GB to 60 GB in the portal. Terraform
detects this by comparing the **state file** against reality, and the next
`plan` will show the difference so it can be corrected.

### Where it fits in a real team

A Product Owner holds the business requirements and takes them to a Solution
Architect, who analyses them and plans the infrastructure. That infrastructure
plan is then expressed as Terraform code rather than built by hand — which is
what makes it reviewable, repeatable and auditable.

---

## Local setup

Tools to install on the workstation:

- Terraform CLI
- Azure CLI (`az`)
- AWS CLI (`aws`)
- VS Code + the HashiCorp Terraform extension

Terraform authenticates using the credentials already configured in these CLIs,
so you sign in to the cloud provider first.

### Authenticate to Azure

```bash
az login --use-device-code
```

```bash
az account show
```

### Authenticate to AWS

```bash
aws configure
```

```bash
aws sts get-caller-identity
```

`az account show` and `aws sts get-caller-identity` confirm **which** account
and subscription you are pointed at — worth checking every time before an
`apply`, so you do not build into the wrong subscription.

---

## Key takeaways

- Terraform is declarative — describe the destination, not the route.
- Config is plain text, so all normal Git practices apply to infrastructure.
- Always verify your active subscription/account before applying.
