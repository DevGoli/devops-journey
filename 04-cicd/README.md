# CI/CD — Azure DevOps

Continuous Integration and Deployment with Azure Pipelines.

## Notes

| # | Topic | Day |
|---|-------|-----|
| 01 | [Azure DevOps & Continuous Integration](notes/01-azure-devops-and-ci.md) | 44 |

## Labs

| Lab | What it does |
|-----|--------------|
| [01 — Azure Pipelines for .NET](labs/01-azure-pipelines-dotnet/) | ASP.NET Core app built by a CI pipeline on a hosted agent |

## What I can do

- Explain the CI/CD flow: commit → trigger → agent → build → test → artifact
- Write a YAML pipeline with triggers, pools and tasks
- Choose the right task family for a project type (`DotNetCoreCLI` vs `VSBuild`)
- Publish build output as a versioned artifact for later deployment stages
