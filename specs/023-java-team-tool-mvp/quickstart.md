# Quickstart: Java Team Tool MVP

## 1) Provide requirement input

Use this minimum input:

- Business goal
- Target user
- Core workflow
- Required outputs
- Constraints (security, performance, delivery date)

Preferred source template:

- `specs/023-java-team-tool-mvp/requirement-input-template.md`
- Save each run under `specs/023-java-team-tool-mvp/demo-<id>-<name>/request.md`

## 2) Generate design artifacts

Produce and review in order:

1. `spec.md`
2. `plan.md`
3. `tasks.md`

Do not start coding before tasks are approved.

## 3) Implement with gate checks

Follow tasks sequentially.

Environment preflight (especially on Windows shell/task sessions):

- Verify `mvn -v` and `java -version` in the same terminal context.
- If unresolved in VS Code task terminals, set session vars explicitly:

```powershell
$env:JAVA_HOME='C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot'
$env:Path=($env:JAVA_HOME + '\\bin;' + $env:Path)
```

Multi-feature bootstrap rule:

- Keep Spring Boot component scanning at shared root `com.amor.speckit.mvp` when multiple feature packages are added.
- If a test package is outside boot class package hierarchy, use explicit test bootstrap class (`@SpringBootTest(classes=...)`).

Mandatory checks:

- `mvn -q -DskipTests=false test`
- `mvn -q package`

## 4) Verify runnable package

Example run command:

```bash
java -jar target/<app-name>.jar
```

Validate:

- app starts
- `GET /api/v1/skills` responds
- `POST /api/v1/builds/generate` returns valid results
- boundary validation contract check passes (example: `maxResults=21`)
- root page `/` responds with HTTP 200

## 5) Capture handoff artifacts

- Acceptance summary
- Known limitations
- Follow-up backlog

## 6) Team command pack (recommended)

Use reusable scripts under `scripts/team-pilot/`:

```powershell
pwsh ./scripts/team-pilot/01_preflight.ps1
pwsh ./scripts/team-pilot/02_build_and_package.ps1
pwsh ./scripts/team-pilot/03_smoke_check.ps1 -Mode expense -BaseUrl http://localhost:8080
```

Expected outputs:

- test reports in `target/surefire-reports/`
- jar in `target/*.jar`
- smoke result `OK`

Runtime configuration rule:

- Do not commit secrets.
- Use environment variables for local DB credentials and profile-specific settings.
