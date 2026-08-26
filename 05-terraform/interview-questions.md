# Terraform — Interview Questions

Questions this material would generate, answered in my own words.
Added 2–3 per session as I go.

---

## Fundamentals (Day 48)

**What is Infrastructure as Code and why does it matter?**
Managing infrastructure through config files instead of manual portal work.
It makes environments repeatable and reviewable — dev, test and prod are built
from the same code — and it removes configuration drift, because the code is
the source of truth rather than whatever someone last clicked.

**Why Terraform over ARM/Bicep or CloudFormation?**
It's cloud-agnostic — one language and one workflow across Azure, AWS and GCP —
and it has a very large provider ecosystem. ARM/Bicep and CloudFormation are
tied to a single cloud. Terraform's trade-off is that it needs its own state
file, whereas ARM reads state from Azure directly.

**What does "declarative" mean here?**
You describe the desired end state, not the steps. Terraform diffs that against
current state and works out what to create, change or destroy.

---

## Workflow (Day 49)

**Walk me through the Terraform workflow.**
`init` downloads providers and modules and configures the backend. `validate`
checks the config is internally valid. `fmt` formats it. `plan` diffs desired
state against real state and shows what would change. `apply` makes the change
and records it in state. `destroy` tears it down.

**What's the difference between `validate` and `plan`?**
`validate` is offline — syntax, references, types. It never contacts the cloud,
so it can't catch a name collision or a quota problem. `plan` talks to the
provider and compares against reality.

**Why would you use `terraform plan -out=tfplan`?**
It saves the exact plan so `apply` runs precisely what was reviewed, with no
chance of drift between review and apply. Standard practice in CI/CD, where the
plan is often approved by a human between stages.

---

## State (Day 50)

**What is the state file and why does Terraform need one?**
JSON that maps your config to real resource IDs. HCL only says what you want —
state is how Terraform remembers what it already built, so it can diff. Without
it, Terraform would try to create everything again.

**Why must state never go into Git?**
It's plain text and contains subscription IDs, resource metadata, and any
sensitive values a resource produced — passwords, connection strings, keys.
It also conflicts immediately once two people run Terraform.

**What do the plan symbols mean?**
`+` create, `-` destroy, `~` update in place, `-/+` destroy and recreate.
`-/+` is the one to watch — an immutable attribute changed, so the resource is
replaced, which can mean data loss and downtime.

**Someone changed a resource in the portal. What happens?**
The next `plan` shows drift and proposes reverting it to match the code, unless
that attribute is listed in `lifecycle { ignore_changes = [...] }`.

---

## Remote backend (Day 51)

**Why use a remote backend instead of local state?**
Four reasons: state stays out of Git in access-controlled encrypted storage;
state locking prevents two people applying at once; the team and CI/CD share one
state; and the storage layer keeps versions you can roll back to.

**What is state locking and why does it matter?**
Terraform takes a lock on the state during an apply. Anyone else is blocked
until it's released. Without it, two concurrent applies can corrupt state or
create duplicate resources.

**Chicken-and-egg problem with backends?**
Terraform can't create the storage account that holds its own state. You
bootstrap it once — CLI or a separate config — then point the backend at it.

**How do you move existing local state to a remote backend?**
Add the `backend` block, then `terraform init -migrate-state`. Terraform detects
the change and offers to copy state up.

---

## Meta-arguments (Day 52)

**What are meta-arguments?**
Arguments Terraform itself understands rather than passing to the provider —
`count`, `for_each`, `depends_on`, `lifecycle`, `provider`. They control how a
resource is managed, not what it is.

**`count` vs `for_each` — which and why?** ⭐
`for_each` in almost all cases. `count` addresses instances by index, so
removing an item from the middle shifts everything after it and Terraform
destroys and recreates all of them. `for_each` keys by name, so removing one
instance affects only that one. Use `count` only for genuinely identical,
interchangeable instances.

**When do you actually need `depends_on`?**
Rarely. Referencing another resource's attribute already creates an implicit
dependency. `depends_on` is only for hidden dependencies — where the ordering
matters but nothing in the config references the other resource. It's also
coarser: it waits for all instances rather than the specific one.

**What does `lifecycle { ignore_changes = [tags] }` do and when would you use it?**
Terraform sets tags on create then stops tracking them. Used where Azure Policy
or another team auto-applies tags — without it, Terraform strips the tag, policy
re-adds it, forever. You can scope it to one tag: `ignore_changes = [tags["CostCentre"]]`.

**What is `prevent_destroy` for?**
Terraform errors instead of destroying the resource. A guard rail for production
databases and storage.

---

## Modules (Day 53)

**What is a module and why use one?**
A reusable, parameterised set of config files. Without modules every engineer
builds a VM stack their own way — no consistency. A module encodes the pattern
plus the org's naming and tagging standards once, and everyone calls it.

**Root module vs child module?**
The root module is the directory you run `apply` in. A child module is one it
calls via a `module` block. Every config is already a module.

**How does data get in and out of a module?** ⭐
Inputs are `variable` blocks, outputs are `output` blocks. A module is a black
box — the caller can't reach inside and read a resource attribute directly. If
a value isn't declared as an `output`, it doesn't exist to the caller.

**How do you make one module depend on another?**
Pass one module's output into the next module's input. That reference creates
the implicit dependency, same as with resources.

**What makes a module genuinely reusable?**
Anything a caller might reasonably vary — sizes, address ranges, SKUs — should
be a variable with a sensible default. Things that must not vary — naming
conventions, mandatory tags, security baselines — stay hardcoded deliberately.
A module that hardcodes everything is just a folder.

**Do you need to re-run `init` after adding a module?**
Yes — `init` installs modules as well as providers.

---

## Security

**How do you handle secrets in Terraform?** ⭐
Never in a committed file. Pass them via `TF_VAR_` environment variables, a
CI/CD secret store, or pull them from Azure Key Vault. Note that
`sensitive = true` only masks the value in CLI output — **it is still plain text
in the state file**, which is a large part of why state must be stored remotely
with restricted access.

**What's in your `.gitignore` for a Terraform repo?**
`*.tfstate`, `*.tfstate.*`, `.terraform/`, `*.tfvars`, plus keys and `.env`.
Commit `*.tfvars.example` with placeholders instead.

---

## Workspaces & state operations (Day 54)

**What problem do workspaces solve?**
One configuration has one state file. If you just swap `dev.tfvars` for
`qa.tfvars`, Terraform compares the new inputs against the existing state,
decides the resources were renamed, and destroys dev to create qa. Workspaces
give each environment its own state file so they coexist.

**Where is workspace state stored?**
The `default` workspace keeps state at `terraform.tfstate`. Named workspaces go
in `terraform.tfstate.d/<name>/terraform.tfstate`. With a remote backend it's the
same idea using key prefixes.

**Would you use workspaces for dev/qa/prod in production?** ⭐
Probably not, and this is HashiCorp's own guidance. Workspaces suit temporary
parallel copies — a feature branch or short-lived test. For real environments the
problems are: all workspaces share one backend and one set of credentials, so
prod isn't separately locked down; the selected workspace is invisible, so
applying to the wrong one is easy; and one config can't cleanly express genuine
differences between environments. The common production pattern is a directory
per environment, each with its own backend, all calling shared modules.

**What's the classic workspace mistake?** ⭐
The workspace and the `-var-file` are independent choices. Selecting workspace
`dev` does not make Terraform read `dev.tfvars`. Being in `qa` while passing
`dev.tfvars` writes dev's resources into qa's state. Always
`terraform workspace show` before applying.

**Someone changed a resource in the portal and the change should be kept. What
do you do?** ⭐
`terraform plan -refresh-only` to see the drift, then `terraform apply
-refresh-only` to record it in state — no infrastructure is touched. Then the
essential second step: **update the config to match**, because state now says
`B2s` while the `.tf` file still says `B1s`, and the next ordinary plan would
revert it. Config, state and reality all have to agree.

**`-refresh-only` vs `lifecycle { ignore_changes }`?**
`-refresh-only` is a one-off reconciliation — accept this drift now.
`ignore_changes` is a standing instruction — stop watching this attribute
permanently.

**How do you destroy just one resource?**
Find its address with `terraform state list`, then
`terraform destroy -target="<address>"`. It's a recovery tool, not routine —
targeting skips the dependency graph and can leave state inconsistent. Needing it
often suggests the config should be split into smaller root modules.

**Does `-target` affect all workspaces?**
No. Every state operation is scoped to the currently selected workspace.
Destroying in `qa` leaves `dev` untouched.
