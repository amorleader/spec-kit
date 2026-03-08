# Demo A Reproducibility Notes

## Purpose

Capture practical run notes from Demo A that must be reused in Demo B to reduce drift.

## Environment Preflight (Windows)

1. Confirm Java and Maven commands are available in the active shell.
2. If VS Code task terminal cannot resolve Java/Maven, explicitly set session variables:

```powershell
$env:JAVA_HOME='C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot'
$env:Path=($env:JAVA_HOME + '\bin;' + $env:Path)
```

3. If `mvn` still fails in task context, invoke Maven using absolute path:

```powershell
& 'C:\Users\Administrator\AppData\Local\Programs\Apache\Maven\apache-maven-3.9.11\bin\mvn.cmd' -q -DskipTests=false test
```

## Database Preflight

Use profile `local` and provide DB values via environment variables instead of hardcoding secrets:

```powershell
$env:MHR_DB_HOST='localhost'
$env:MHR_DB_PORT='5432'
$env:MHR_DB_NAME='speckit_mhr'
$env:MHR_DB_USER='mhr_user'
$env:MHR_DB_PASSWORD='<secret>'
```

## Contract Consistency Check

- `maxResults` out-of-range must return:
  - `code=VALIDATION_ERROR`
  - `message=maxResults must be between 1 and 20`
  - `details[0]={field:maxResults, reason:out_of_range}`
- Run this check both in unit/integration tests and runtime smoke test.

## Recommended Command Sequence

```powershell
& 'C:\Users\Administrator\AppData\Local\Programs\Apache\Maven\apache-maven-3.9.11\bin\mvn.cmd' -q -DskipTests=false test
& 'C:\Users\Administrator\AppData\Local\Programs\Apache\Maven\apache-maven-3.9.11\bin\mvn.cmd' -q -DskipTests package
& 'C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot\bin\java.exe' -jar target\mhr-build-planner-0.0.1-SNAPSHOT.jar --spring.profiles.active=local
```

## Drift Risks Observed in Demo A

- Shell session did not automatically load updated user PATH.
- VS Code task terminal required explicit `JAVA_HOME`.
- Bean validation path produced generic error message until explicitly mapped.

## Reuse Rules for Demo B

- Apply this preflight before first build command.
- Re-run contract consistency check for all validation boundary fields.
- Preserve evidence files under `target/surefire-reports` and acceptance notes.
