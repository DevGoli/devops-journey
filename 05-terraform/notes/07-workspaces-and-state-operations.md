# Terraform: Workspaces & State Operations

> Day 54 · Topic: Terraform

**In one line:** workspaces give one configuration multiple independent state
files, so the same code can manage dev, qa and prod without them overwriting
each other.

---

## The problem workspaces solve

Yesterday's config had a single `terraform.tfvars`. Today we want per-environment
values — `dev.tfvars`, `qa.tfvars`.

But changing the var file alone does **not** give you two environments. There is
still only **one state file**. Terraform sees the resources it recorded last time
(`rg_demo_development`) and the resources you now want (`rg_demo_qa`), concludes
they are the same resources renamed, and plans to **destroy dev and create qa**.

Same code, same state, different inputs = the previous environment gets torn down.

**Workspaces fix this by giving each environment its own state file.**

---

## How workspaces store state

```
terraform.tfstate                  ← the "default" workspace
terraform.tfstate.d/
├── dev/terraform.tfstate          ← workspace "dev"
└── qa/terraform.tfstate           ← workspace "qa"
```

Note the asymmetry: the **`default` workspace keeps its state at the top level**,
while every named workspace gets a folder under `terraform.tfstate.d/`. With a
remote backend the same thing happens using key prefixes rather than folders.

Terraform is a bit like git branches here — one set of files, several independent
lines of state. The analogy breaks down in one important way: git shows you the
branch in your prompt, whereas the selected workspace is **invisible**. See the
warning below.

---

## Commands

```bash
terraform workspace new dev
```

Creates and immediately switches to it.

```bash
terraform workspace list
```

Lists workspaces; `*` marks the current one.

```bash
terraform workspace select qa
```

Switches.

```bash
terraform workspace show
```

Prints the current workspace name.

### Applying with an environment's variables

```bash
terraform plan -var-file="dev.tfvars"
```

```bash
terraform apply -var-file="dev.tfvars"
```

**The workspace and the var file are two separate choices, and nothing links
them.** Selecting workspace `dev` does not make Terraform read `dev.tfvars`.
Passing `-var-file="dev.tfvars"` while workspace `qa` is selected will happily
write dev's resources into qa's state. This is the single biggest hazard of
workspaces.

You can reference the current workspace inside config, which helps:

```hcl
name = "rg-${terraform.workspace}"
```

---

## ⚠️ Workspaces are not the recommended way to separate real environments

Worth knowing, because interviewers ask and the honest answer is nuanced.
HashiCorp's own guidance is that workspaces suit *temporary, parallel copies of
the same infrastructure* — a feature branch, a short-lived test — rather than
dev/qa/prod.

Why they fall down for real environments:

- **One backend, one set of credentials.** Prod state sits beside dev state with
  the same access control. You usually want prod locked down separately.
- **The selected workspace is invisible.** No prompt indicator, no file on disk
  you'd notice in a diff. `terraform apply` after forgetting to switch is a very
  easy way to change prod while believing you are in dev.
- **One configuration for all environments.** Environments legitimately differ —
  prod wants bigger SKUs, more replicas, stricter policies. Expressing that
  through conditionals in shared code gets ugly fast.

**The common production pattern instead:** a separate directory per environment,
each with its own backend, all calling the same shared modules.

```
environments/
├── dev/    (main.tf → modules, backend key = dev.tfstate)
├── qa/     (main.tf → modules, backend key = qa.tfstate)
└── prod/   (main.tf → modules, backend key = prod.tfstate)
```

Explicit, reviewable in a diff, and separately permissioned. Workspaces are still
worth knowing — they appear in interviews and in existing codebases — but know
when they are the wrong tool.

---

## Handling drift: `-refresh-only`

Scenario: someone resized a VM in the Azure portal from `Standard_B1s` to
`Standard_B2s`, and that change was **intentional** — we want to keep it.

Doing nothing is not an option: the next `apply` would revert it, because the
config still says `B1s`.

```bash
terraform plan -refresh-only
```

Shows what changed in the real world, without proposing to alter anything.

```bash
terraform apply -refresh-only
```

Updates the **state file** to record reality — no infrastructure is touched.

### The essential second step

State now says `B2s`, but the **config still says `B1s`**. The next ordinary
`plan` will want to shrink it back.

So `-refresh-only` alone never finishes the job:

1. `terraform apply -refresh-only` → state matches reality
2. **Edit the `.tf` file to `Standard_B2s`** → config matches reality
3. `terraform plan` → clean, no changes

All three must agree: **config = state = reality.** Accepting drift into state
without updating the config just postpones the revert.

> Contrast with `lifecycle { ignore_changes = [size] }`, which tells Terraform to
> stop watching that attribute permanently. `-refresh-only` is a one-off
> reconciliation; `ignore_changes` is a standing instruction.

---

## Targeting a single resource

`terraform destroy` removes everything in the workspace. To act on one resource,
find its address first:

```bash
terraform state list
```

```bash
terraform state show module.storage_accounts.azurerm_storage_account.sa
```

```bash
terraform destroy -target="module.storage_accounts.azurerm_storage_account.sa"
```

**Answering yesterday's question:** `-target` affects **only the currently
selected workspace**. Every state operation is scoped to the active workspace —
destroying in `qa` leaves `dev` untouched. There is no command that acts across
all workspaces at once; you would select each in turn.

`-target` also works with `plan` and `apply`. It is intended as a recovery tool
for when state and reality have diverged — HashiCorp warns against routine use,
because targeting skips the dependency graph and can leave state inconsistent.
Needing it regularly usually means the configuration should be split into
smaller root modules.

---

## Key takeaways

- One config + one state = changing var files destroys the previous environment.
- Workspaces give each environment its own state file.
- `default` keeps state at the top level; named workspaces live in
  `terraform.tfstate.d/<name>/`.
- **Workspace selection and `-var-file` are independent** — mismatching them is
  the classic workspace mistake.
- Prefer directory-per-environment with separate backends for real dev/qa/prod.
- `-refresh-only` accepts drift into state; you must **also update the config**.
- All state operations, including `-target`, are scoped to the current workspace.

---

## Next

Integrate Terraform into the Azure Pipelines CI/CD project — `plan` and `apply`
as pipeline stages across dev, qa and prod, deploying both the infrastructure
and the .NET application.
