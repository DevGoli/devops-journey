# CI/CD — Interview Questions

Questions this material would generate, answered in my own words.

---

## Concepts (Day 44)

**What is Continuous Integration?**
Automatically building and testing code every time a developer commits. The
value is fast feedback — a break found ninety seconds after a push costs almost
nothing; the same break found three weeks later, buried under other changes, is
expensive.

**What does the build stage actually do?**
Restore dependencies, compile, run tests, package the app, publish the result as
an artifact.

**What is an artifact, and how is it different from build output?**
Compiling produces binaries — `.dll` or `.exe`. Those binaries, packaged and
published so later stages can retrieve them, are the artifact.

**Why publish an artifact instead of rebuilding per environment?** ⭐
Build once, deploy many. The same artifact that passed tests is what goes to
dev, then QA, then prod. Rebuilding per environment means the thing you tested
isn't the thing you shipped.

**What is an agent?**
The machine a pipeline runs on. Azure DevOps calls it an agent; GitHub Actions
calls it a runner. Microsoft-hosted agents are created fresh per run and
destroyed after — so a build can never pass because of leftovers from a previous
run. Self-hosted agents are for private network access or licensed tooling.

**What does Azure DevOps actually provide?**
Repos, Pipelines, Boards, Artifacts and Test Plans. It orchestrates delivery —
it isn't where the application ultimately runs, though it does provide the build
compute.

---

## Pipelines

**What makes a pipeline "continuous"?**
The `trigger`. Without it the pipeline only runs when someone starts it by hand,
which is automation but not CI.

**How do you pick the right tasks for a project?** ⭐
Match the task family to the project type. For modern .NET (SDK-style,
`net8.0`/`net10.0`) use `DotNetCoreCLI@2` — restore, build, publish. `VSBuild`,
`NuGetCommand` and `VSTest` are the .NET Framework 4.x family. I hit this
directly: the Azure DevOps "ASP.NET" template targets .NET Framework, so it was
the wrong family for a .NET 10 project. Also means modern .NET can build on
`ubuntu-latest`, which starts faster and costs less than a Windows agent.

**How would you handle secrets in a pipeline?**
Pipeline variables marked secret, or a variable group backed by Azure Key Vault.
Never in the YAML — it's in source control.

**What's the difference between CI and CD?**
CI ends at a tested, published artifact. CD takes that artifact and deploys it
to environments, usually with approvals between stages.

---

## To add as I learn

- [ ] Stages, jobs and steps — the hierarchy
- [ ] Approvals and gates between environments
- [ ] Deploying to Azure App Service from a pipeline
- [ ] Running `terraform plan`/`apply` in a pipeline with remote state
- [ ] GitHub Actions equivalents — how workflows compare to Azure Pipelines
