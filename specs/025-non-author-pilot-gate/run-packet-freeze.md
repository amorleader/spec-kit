# Run Packet Freeze

Date: 2026-03-08
Scope: `P001` packet freeze for `025-non-author-pilot-gate`
Source commit: `891a018`

## Frozen References

- Entrypoint: `specs/024-team-rollout-pilot/teammate-run-packet.md`
- Quickstart: `specs/023-java-team-tool-mvp/quickstart.md`
- Troubleshooting: `specs/024-team-rollout-pilot/troubleshooting-appendix.md`
- Script 1: `scripts/team-pilot/01_preflight.ps1`
- Script 2: `scripts/team-pilot/02_build_and_package.ps1`
- Script 3: `scripts/team-pilot/03_smoke_check.ps1`

## Frozen Command Sequence

Run from repository root in PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
pwsh ./scripts/team-pilot/01_preflight.ps1
pwsh ./scripts/team-pilot/02_build_and_package.ps1
# Start application jar in a new terminal before smoke check
pwsh ./scripts/team-pilot/03_smoke_check.ps1 -Mode mhr -BaseUrl http://localhost:8080
```

## Execution Constraints

- Runner must be a non-author teammate.
- Observer is read-only unless hard blocker occurs.
- Any intervention must be logged with timestamp and reason in run log.
- Do not alter scripts/docs during the session.

## Completion Criteria For This Freeze

- Exact sequence above is used as single source of truth for the run.
- All deviations are explicitly documented in run evidence.
