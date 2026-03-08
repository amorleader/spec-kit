# Team Dry-Run Simulation (Docs-Only)

## Scope

Validate that a teammate can execute the MVP flow using documentation and packaged scripts only, without verbal guidance.

## Simulation Setup

- Repository: `spec-kit`
- Branch: `002-initialize-first-sample`
- OS: Windows
- Demo mode: `expense`
- Script pack: `scripts/team-pilot/`

## Commands Executed

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
& .\scripts\team-pilot\01_preflight.ps1 -JavaHome "C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot" -MavenCommand "C:\Users\Administrator\AppData\Local\Programs\Apache\Maven\apache-maven-3.9.11\bin\mvn.cmd"
& .\scripts\team-pilot\02_build_and_package.ps1 -JavaHome "C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot" -MavenCommand "C:\Users\Administrator\AppData\Local\Programs\Apache\Maven\apache-maven-3.9.11\bin\mvn.cmd"
# start jar
& .\scripts\team-pilot\03_smoke_check.ps1 -Mode expense -BaseUrl "http://localhost:8080"
```

## Results

- Preflight: PASS (`java -version`, `mvn -v`)
- Build and package: PASS (`mvn test`, `mvn package`)
- Smoke checks: PASS (`[smoke] OK`)

## Friction Observed

- Default PowerShell execution policy blocked `.ps1` scripts.
- Mitigation: add process-scope bypass at run start:
  - `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force`

## Conclusion

Docs-only teammate dry-run is successful after one explicit execution-policy step. The command pack is usable for internal pilot onboarding.
