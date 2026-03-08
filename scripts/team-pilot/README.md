# Team Pilot Command Pack

This folder contains reusable commands for teammate pilot runs.

## Scripts

- `01_preflight.ps1`: verify Java/Maven in active shell
- `02_build_and_package.ps1`: run `mvn test` and `mvn package`
- `03_smoke_check.ps1`: run API/UI smoke checks for a selected demo mode

## Typical Flow

```powershell
pwsh ./scripts/team-pilot/01_preflight.ps1
pwsh ./scripts/team-pilot/02_build_and_package.ps1
pwsh ./scripts/team-pilot/03_smoke_check.ps1 -Mode expense -BaseUrl http://localhost:8080
```

## Notes

- Provide DB secrets via environment variables.
- If Maven is not in PATH, pass `-MavenCommand` explicitly.
