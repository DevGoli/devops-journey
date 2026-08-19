# Terraform: Remote Backend

> Day 51 · Topic: Terraform

**In one line:** a backend is where Terraform stores and manages the state file —
and storing it remotely gives you security, locking, sharing and version history
that a local file cannot.

---

## The problem with local state

By default state lives on your laptop as `terraform.tfstate`. That breaks down
as soon as there is more than one person:

- It cannot be committed to Git (sensitive), so nobody else can get it.
- Two people applying at once corrupt each other's state.
- If the laptop dies, the state — and Terraform's record of your infrastructure —
  is gone.

## What a remote backend gives you

**1. Security** — state stays out of Git, in storage with proper access control
and encryption at rest.

**2. State locking** — when someone runs `apply`, Terraform takes a **lock** on
the state. Anyone else running at the same time is blocked until it is released,
so two concurrent applies cannot conflict or corrupt state.

**3. Sharing** — the whole team and the CI/CD pipeline read the same state.

**4. Versioning and backup** — the storage layer keeps previous versions
(n-1, n-2, n-3 …), so you can roll back to an earlier state if one is corrupted.

---

## Where state can be stored

| Cloud | Backend |
|---|---|
| Azure | Storage Account (blob container) |
| AWS | S3 bucket |
| GCP | Cloud Storage bucket |

Terraform also supports a `local` backend, but remote is the recommendation for
anything beyond personal practice.

---

## Azure backend example

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstatedemo001"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

The storage account has to exist **before** you configure the backend — Terraform
cannot create the place it stores its own state. Create it once with the Azure
CLI (or a separate bootstrap config), then point the backend at it.

Enable **blob versioning** on the storage account — that is what gives you the
rollback history.

### Migrating existing local state

After adding the backend block, re-run init:

```bash
terraform init -migrate-state
```

Terraform detects the backend change and offers to copy the existing local state
up to the remote backend.

---

## How this fits CI/CD

Once state is remote, `terraform plan` and `terraform apply` can run from an
**Azure Pipeline** instead of a laptop. The pipeline authenticates with a service
principal, pulls the shared state from the storage account, and the lock stops a
pipeline run and a developer from applying simultaneously.

That is the point of the whole setup: infrastructure changes go through the same
reviewed, automated path as application code.

---

## Key takeaways

- Remote backend = security + locking + sharing + versioning.
- State locking is what makes team use safe.
- Bootstrap the storage account before configuring the backend.
- `terraform init -migrate-state` moves local state to remote.
- Remote state is the prerequisite for running Terraform in CI/CD.
