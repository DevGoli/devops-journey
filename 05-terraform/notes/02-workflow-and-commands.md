# Terraform: Core Workflow & Commands

> Day 49 · Topic: Terraform

**In one line:** the Terraform workflow is init → validate → fmt → plan → apply,
with destroy to tear everything back down.

---

## File extension

Terraform config files use the **`.tf`** extension. Terraform loads *every*
`.tf` file in the working directory, so splitting config across `main.tf`,
`variables.tf`, `outputs.tf` and `providers.tf` is purely for readability.

## Providers

A **provider** is the plugin that lets Terraform talk to a specific platform —
`azurerm` for Azure, `aws` for AWS, `google` for GCP. Providers are downloaded
during `terraform init`.

---

## The core commands

### 1. `terraform init`

```bash
terraform init
```

Initialises the working directory: downloads the provider plugins into
`.terraform/` and configures the backend. **Always the first command** in a new
directory, and again whenever providers or the backend change.

### 2. `terraform validate`

```bash
terraform validate
```

Checks the configuration is valid — syntax, references, argument names and
types. It does **not** contact the cloud provider, so it cannot tell you whether
a resource name is already taken or a quota will be exceeded.

### 3. `terraform fmt`

```bash
terraform fmt
```

Rewrites config files into the canonical format (consistent indentation and
alignment). Use `terraform fmt -check` in CI to fail a build on unformatted code.

### 4. `terraform plan`

```bash
terraform plan
```

Creates an **execution plan**: compares the desired state in your config against
the current state, and shows what it would do without changing anything. Output
ends with a summary such as:

```
Plan: 1 to add, 0 to change, 0 to destroy.
```

This is the review step — read it before every apply.

### 5. `terraform apply`

```bash
terraform apply
```

Applies the changes needed to reach the desired state. It creates the real
resources **and** records them in the state file. Prompts for confirmation
unless you pass `-auto-approve`.

### 6. `terraform destroy`

```bash
terraform destroy
```

Destroys all infrastructure managed by this configuration. Useful in learning
labs to avoid running up cloud costs.

```bash
terraform destroy -auto-approve
```

> `-auto-approve` skips the confirmation prompt. Convenient in a lab, dangerous
> in production — it removes the last chance to catch a mistake.

---

## Terraform Registry

Providers and modules are published at **registry.terraform.io**, which is also
where the documentation for every resource lives.

Use **Official** (published by HashiCorp) and **Partner** (verified by
HashiCorp) providers. **Community** providers are unverified — treat them as
untrusted code, since a provider runs on your machine with your cloud
credentials.

---

## Key takeaways

- `init` → `validate` → `fmt` → `plan` → `apply`, then `destroy` to clean up.
- `validate` is offline; only `plan` compares against real infrastructure.
- Always read the plan summary before applying.
- Stick to Official and Partner providers.
