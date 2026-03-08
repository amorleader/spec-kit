# Teammate Run Packet (Docs Entrypoint)

## Audience

Use this packet if you are a teammate running the workflow for the first time.

## Objective

Complete one docs-only run without live guidance and record outcomes.

## Start Here

1. Read: `specs/023-java-team-tool-mvp/quickstart.md`
2. Read: `specs/024-team-rollout-pilot/troubleshooting-appendix.md`
3. Open log template: `specs/024-team-rollout-pilot/teammate-run-log-template.md`

## Command Flow

Run from repository root in PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
pwsh ./scripts/team-pilot/01_preflight.ps1
pwsh ./scripts/team-pilot/02_build_and_package.ps1
# Start application jar in a new terminal
pwsh ./scripts/team-pilot/03_smoke_check.ps1 -Mode expense -BaseUrl http://localhost:8080
```

## Environment Notes

- If Java/Maven commands fail, use fixes in troubleshooting appendix.
- Set DB credentials via environment variables only (do not edit repo files with secrets).

## Required Evidence

- Filled run log template
- Console output (or screenshot) for preflight, test/package, and smoke success
- Any blocker message and resolution steps

## Completion Signal

Pilot is complete when all command steps pass and run log is fully filled.
