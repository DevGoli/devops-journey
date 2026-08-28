# Terraform in CI/CD: Multi-Stage Pipelines

> Day 55 · Topic: Terraform + CI/CD

**In one line:** infrastructure and application deploy through the same
pipeline, promoted stage by stage across environments, with each environment's
state isolated by its own backend config.

---

## The goal

Everything so far ran from a laptop. Today it runs from Azure Pipelines:
build the app once, then for each environment create the infrastructure with
Terraform and deploy the app onto it.

```
Build  →  Terraform Dev  →  Deploy Dev  →  Terraform QA  →  Deploy QA
```

Each stage `dependsOn` the previous one, so a failure stops the chain and a
broken build never reaches QA.

---

## Separating state without workspaces

Yesterday used workspaces. Today uses a different mechanism — and this is the
one used in production.

The backend settings are pulled out of `providers.tf` into per-environment files:

```hcl
# backend-dev.conf
resource_group_name  = "terraformstaterg"
storage_account_name = "netflixenglishstatesa11"
container_name       = "statefile"
key                  = "dev.tfstate"      ← the only difference
```

```hcl
# backend-qa.conf
key                  = "qa.tfstate"
```

`key` is the blob name inside the container, so **each environment writes to a
different blob** — completely isolated state, no workspaces involved.

```bash
terraform init -reconfigure -backend-config="backend-dev.conf"
```

```bash
terraform plan -var-file="dev.tfvars"
```

`-reconfigure` tells Terraform to discard the previously configured backend and
use the new one, rather than trying to migrate state between them.

### Two separate choices, again

Same trap as workspaces: **the backend config and the var file are independent.**
`-backend-config="backend-dev.conf"` with `-var-file="qa.tfvars"` would write
QA's resources into dev's state.

In a pipeline this is safe because each stage runs `init` and `apply` together on
a fresh agent with hardcoded pairs. Running locally, check both before applying.

### Backend config vs. workspaces

| | Workspaces | Backend config per env |
|---|---|---|
| Selected by | `terraform workspace select` | `init -backend-config=...` |
| Visible where | nowhere — invisible state | a file, reviewable in a diff |
| Backend | one, shared | can differ per environment |
| Suits | temporary parallel copies | real dev/qa/prod |

---

## Pipeline structure

### Stages, jobs, steps

```yaml
stages:
  - stage: Build
    jobs:
      - job: Build
        pool:
          vmImage: 'windows-latest'
        steps:
          - task: ...
```

`pool` and `steps` are **siblings** under the job. Nesting `steps` under `pool`
is silently ignored — the job runs zero steps and reports success in a few
seconds. A build that "passes" suspiciously fast is the tell.

### Deployment jobs

Environment stages use `deployment` rather than `job`:

```yaml
      - deployment: TerraformDev
        environment: Dev
        strategy:
          runOnce:
            deploy:
              steps:
                - checkout: self
```

The `environment:` binding is what gives you deployment history per environment
and, if configured, **approval gates** before a stage runs — the mechanism for
requiring sign-off before prod.

Note `- checkout: self`. **Deployment jobs do not check out the repo by
default**, unlike normal jobs. Without it the Terraform files aren't there.

### Build once, deploy many

The Build stage publishes an artifact; each deploy stage downloads it:

```yaml
                - download: current
                  artifact: drop
```

The artifact lands in `$(Pipeline.Workspace)/drop`, **not**
`$(System.DefaultWorkingDirectory)` — that's the repo checkout. Getting this
wrong gives "No package found with specified pattern".

The same compiled artifact goes to dev and to qa. Nothing is rebuilt per
environment, so what was tested is what ships.

---

## Lessons from debugging this

Three failures, each with a lesson worth keeping.

### 1. Missing implicit dependency

```
azurerm_resource_group.resourcerg: Creating...
azurerm_service_plan.nfasp: Creating...          ← both at once
...
Error: ResourceGroupNotFound: Resource group 'nf-english-devrg' could not be found.
```

Cause: `resource_group_name = var.rgname` — a plain string. Terraform saw no
relationship, so it created both in parallel; the resource group took 24s and
the service plan 404'd immediately.

Fix: `resource_group_name = azurerm_resource_group.resourcerg.name`

**Two parallel `Creating...` lines where you expected sequence is the signature
of a missing reference.** Use a variable only for values that come from outside;
reference anything Terraform itself creates.

### 2. A green init in the wrong directory

`cd` to a non-existent path failed, but `terraform init` **succeeded anyway** —
init in an empty directory is a valid no-op. The problem only surfaced at
`apply`, when real files were needed.

A passing init does not prove you are in the right folder.

### 3. Indentation that fails silently

`steps:` nested one level too deep meant the build job ran nothing and passed in
6 seconds. Azure Pipelines ignored the misplaced key rather than erroring.

---

## Key takeaways

- One pipeline builds the app and provisions infrastructure, promoting both
  through environments in order.
- `-backend-config` per environment isolates state via a different blob `key` —
  the production-grade alternative to workspaces.
- Backend config and var file are independent; pair them deliberately.
- `deployment` jobs give environment history and approval gates, but need an
  explicit `- checkout: self`.
- Artifacts download to `$(Pipeline.Workspace)`, not the sources directory.
- Reference resources rather than repeating their names as variables.

---

## Next

Add a Prod stage with a manual approval gate, and replace the .NET Framework
build tasks with `DotNetCoreCLI@2`.
