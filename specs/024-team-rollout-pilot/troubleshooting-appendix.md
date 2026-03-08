# Troubleshooting Appendix (Team Rollout Pilot)

## 1. PowerShell blocks script execution

Symptom:
- `cannot be loaded because running scripts is disabled on this system`

Fix (current process only):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

## 2. `mvn` command not found

Symptom:
- `mvn : The term 'mvn' is not recognized`

Fix options:

1) Use absolute Maven path:

```powershell
& 'C:\Users\<user>\AppData\Local\Programs\Apache\Maven\apache-maven-3.9.11\bin\mvn.cmd' -v
```

2) Reload session PATH from persisted User/Machine path:

```powershell
$env:Path = ([Environment]::GetEnvironmentVariable('Path','User') + ';' + [Environment]::GetEnvironmentVariable('Path','Machine'))
mvn -v
```

## 3. Maven reports JAVA_HOME not defined correctly

Symptom:
- `The JAVA_HOME environment variable is not defined correctly`

Fix:

```powershell
$env:JAVA_HOME='C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot'
$env:Path=($env:JAVA_HOME + '\bin;' + $env:Path)
java -version
```

## 4. API smoke check fails after app start

Checklist:

1. Confirm jar process is running.
2. Confirm port 8080 is free and app bound successfully.
3. Confirm app logs include `Started` before running smoke checks.
4. Retry smoke checks after startup logs show `Started`.

## 5. Session hygiene

Rule:
- Do not modify scripts/docs during the pilot session.
- Record all command deviations in run log with reason.

## 6. Teammate unavailable fallback

Rule:

- If no non-author teammate is available in current cycle, run solo-proxy mode with strict docs-only constraints and save evidence in `solo-proxy-run-log.md`.
- Mark decision as `CONDITIONAL GO` until a real teammate run is completed.
