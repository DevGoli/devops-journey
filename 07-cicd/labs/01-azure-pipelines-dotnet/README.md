# Lab 01 — Azure Pipelines CI for a .NET App

An ASP.NET Core Razor Pages app (Netflix-style landing page) built in Visual
Studio, pushed to Azure Repos, and built by an Azure Pipelines CI pipeline.

**Concepts:** triggers · agents · build tasks · artifacts

**Day:** 44

## The app

- **.NET 10**, ASP.NET Core Razor Pages
- Single page (`Pages/Index.cshtml`) — a static, self-contained UI clone used as
  something realistic for the pipeline to build
- No database, no external services — the point of the lab is the pipeline

## The pipeline

`azure-pipelines.yml`:

| Step | Task | Purpose |
|---|---|---|
| 1 | `NuGetToolInstaller@1` | Install NuGet on the agent |
| 2 | `NuGetCommand@2` | Restore dependencies |
| 3 | `VSBuild@1` | Compile and package |
| 4 | `VSTest@2` | Run tests |
| 5 | `PublishBuildArtifacts@1` | Publish output as artifact `drop` |

```yaml
trigger:
- main

pool:
  vmImage: 'windows-latest'
```

Every push to `main` queues a run on a fresh Microsoft-hosted Windows agent.

## ⚠️ Known issue: wrong task family for this project

This pipeline came from the **"Build and test ASP.NET projects"** template, which
targets **.NET Framework 4.x** — note the `aspnet/build-aspnet-4` link in the
file header. This project is **.NET 10**, an SDK-style project.

The mismatch:

| Used | Should be | Why |
|---|---|---|
| `NuGetCommand@2` restore | `dotnet restore` | SDK projects restore via the `dotnet` CLI |
| `VSBuild@1` | `dotnet build` / `dotnet publish` | `VSBuild` drives MSBuild the .NET Framework way |
| `VSTest@2` | `dotnet test` | `VSTest` expects `.dll` test assemblies discovered the old way |
| `msbuildArgs` with `WebPublishMethod=Package` | `dotnet publish -o $(Build.ArtifactStagingDirectory)` | Web Deploy packaging is a .NET Framework concept |

The correct pipeline for this project:

```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'

steps:
- task: UseDotNet@2
  inputs:
    version: '10.x'

- task: DotNetCoreCLI@2
  displayName: Restore
  inputs:
    command: 'restore'
    projects: '**/*.csproj'

- task: DotNetCoreCLI@2
  displayName: Build
  inputs:
    command: 'build'
    projects: '**/*.csproj'
    arguments: '--configuration $(buildConfiguration) --no-restore'

- task: DotNetCoreCLI@2
  displayName: Publish
  inputs:
    command: 'publish'
    publishWebProjects: true
    arguments: '--configuration $(buildConfiguration) --output $(Build.ArtifactStagingDirectory)'
    zipAfterPublish: true

- task: PublishBuildArtifacts@1
  inputs:
    PathtoPublish: '$(Build.ArtifactStagingDirectory)'
    ArtifactName: 'drop'
```

Note it can also run on `ubuntu-latest` — modern .NET is cross-platform, and
Linux agents are cheaper and faster to start than Windows ones.

**Also:** there is no test project in this solution, so `VSTest@2` has nothing to
discover. Adding an xUnit project would make the "test" half of CI real rather
than decorative.

> Left as-is deliberately, with the fix documented. Recognising that a template
> targets the wrong framework is the actual lesson of this lab.

## To-do

- [ ] Replace the `VSBuild`/`VSTest` tasks with `DotNetCoreCLI@2`
- [ ] Add an xUnit test project so `dotnet test` has something to run
- [ ] Add a CD stage deploying the artifact to an Azure App Service
- [ ] Mirror the same pipeline as a GitHub Actions workflow to compare the two

## What I learned

> Fill this in — what surprised you, what broke, how long the first run took.
