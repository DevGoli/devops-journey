# Lab 02 — Remote Backend on Azure Storage

Moves Terraform state from the local disk into an Azure Storage Account with
locking and versioning enabled.

**Concepts:** backends · state locking · state migration · versioning

**Status:** 🔄 in progress — Day 51

## Step 1 — Bootstrap the storage account

Terraform cannot create the place it stores its own state, so this is done once
with the Azure CLI. The storage account name must be globally unique.

```bash
az group create --name rg-tfstate --location australiaeast
```

```bash
az storage account create --name sttfstate<yourinitials>001 --resource-group rg-tfstate --sku Standard_LRS --encryption-services blob
```

```bash
az storage container create --name tfstate --account-name sttfstate<yourinitials>001
```

Enable versioning so previous state versions are recoverable:

```bash
az storage account blob-service-properties update --account-name sttfstate<yourinitials>001 --resource-group rg-tfstate --enable-versioning true
```

## Step 2 — Configure the backend

Add to `providers.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate<yourinitials>001"
    container_name       = "tfstate"
    key                  = "lab02.terraform.tfstate"
  }
}
```

## Step 3 — Migrate

```bash
terraform init -migrate-state
```

Terraform detects the backend change and offers to copy existing local state up
to Azure. Answer `yes`.

## Step 4 — Verify

Confirm the blob exists and the local state file is now empty/stale:

```bash
az storage blob list --container-name tfstate --account-name sttfstate<yourinitials>001 --output table
```

## What I learned

> Fill this in as you go. Things worth capturing:
> - what the lock looks like in the portal during an apply
> - what happens if you run `apply` from two terminals at once
> - whether the local `terraform.tfstate` still contains anything after migration
