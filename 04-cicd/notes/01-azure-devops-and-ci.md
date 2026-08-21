# CI/CD Part 1: Azure DevOps & Continuous Integration

> Day 44 · Topic: CI/CD

**In one line:** Continuous Integration is the practice of automatically building
and testing code every time a developer commits, so problems surface in minutes
rather than at release time.

---

## What Azure DevOps is

Azure DevOps is a **SaaS platform** that coordinates the software delivery
process. Like Airbnb or Expedia — which run the booking platform without owning
the hotels or the planes — Azure DevOps orchestrates your pipeline without being
where your application ultimately runs. Your app is deployed to Azure, AWS,
on-prem, wherever; Azure DevOps is the platform that gets it there.

The one thing it *does* provide is **build compute** — short-lived hosted agents
that run your pipeline.

### The five services

| Service | Purpose |
|---|---|
| **Repos** | Git repositories |
| **Pipelines** | CI/CD automation |
| **Boards** | Work items, backlogs, sprints |
| **Artifacts** | Package feeds (NuGet, npm, Maven) |
| **Test Plans** | Manual and exploratory testing |

---

## The flow

```
Developer laptop
      │  git push
      ▼
Azure Repos / GitHub
      │  trigger
      ▼
CI stage  ──►  runs on an AGENT
      │        restore → build → test → package
      ▼
   ARTIFACT  (.dll / .exe / .zip)
      │
      ▼
   CD stage  ──►  deploy to environment
```

## Agents

A pipeline needs a machine to run on. Azure DevOps calls this an **agent**;
GitHub Actions calls the equivalent a **runner**.

**Microsoft-hosted agents** are created fresh for each run and destroyed
afterwards. That is a feature, not a limitation — every build starts from an
identical clean machine, so a build cannot succeed because of something left
behind by a previous run.

```yaml
pool:
  vmImage: 'windows-latest'
```

**Self-hosted agents** are machines you manage — needed when a build requires
private network access, specialist software, or licensed tooling.

---

## What CI actually means

> CI is the process of automatically building and testing code whenever a
> developer commits.

The value is **speed of feedback**. A broken build discovered ninety seconds
after a push costs almost nothing. The same break discovered three weeks later,
buried under other changes, is expensive.

### What the build stage does

1. **Restore dependencies** — fetch the packages the project needs
2. **Compile** the source code
3. **Run tests**
4. **Package** the application into a deployable unit
5. **Publish** the result as an artifact

### Package managers by ecosystem

| Language | Package manager | Build tool |
|---|---|---|
| .NET | NuGet | `dotnet` / MSBuild |
| Java | Maven / Gradle | Maven / Gradle |
| Python | pip | setuptools / poetry |
| Node.js | npm / yarn | npm scripts |

### Build output vs. artifact

Compiling produces **binaries** — `.dll` or `.exe` files. Those binaries,
packaged and published so later stages can retrieve them, are the **artifact**.

The distinction matters because of a core CI/CD principle: **build once, deploy
many times.** The same artifact that passed tests is what goes to dev, then QA,
then production. Rebuilding per environment means the thing you tested is not
the thing you shipped.

---

## Lab

Built an ASP.NET Core Razor Pages app in Visual Studio, pushed it to Azure
Repos, and created a build pipeline.

See: [Lab 01 — Azure Pipelines for .NET](../labs/01-azure-pipelines-dotnet/)

### Pipeline structure

```yaml
trigger:
- main                        # run on every push to main

pool:
  vmImage: 'windows-latest'   # the agent

steps:
- task: ...                   # restore, build, test, publish
```

`trigger` is what makes it *continuous* — without it the pipeline only runs when
someone starts it by hand, which is just automation, not CI.

---

## Key takeaways

- Azure DevOps orchestrates delivery; it is not where the app runs.
- Agents (Azure DevOps) = runners (GitHub Actions); hosted agents are ephemeral.
- CI = automatic build + test on every commit; the point is fast feedback.
- Build once, deploy many — promote the same artifact through environments.
- Match the pipeline tasks to the project type — see the lab's notes on this.
