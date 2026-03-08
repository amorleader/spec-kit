# MHR Validation Evidence

Date: 2026-03-08
Branch context: `024-team-rollout-pilot`

## Scope

This evidence file covers `P009-P012` for the MHR smoke-contract validation path.

## Validation Summary

- Verified teammate pilot command pack can run end-to-end.
- Verified MHR test/package baseline remains stable.
- Verified packaged runtime supports MHR smoke endpoints.
- Preserved MHR API contract expectations used by team pilot scripts.

## Verification Commands And Results

1. `mvn -DskipTests=false test`
- Result: `BUILD SUCCESS`
- Test summary: `Tests run: 8, Failures: 0, Errors: 0, Skipped: 0`

2. `mvn -DskipTests package`
- Result: `BUILD SUCCESS`
- Artifact: `target/mhr-build-planner-0.0.1-SNAPSHOT.jar`

3. Packaged runtime smoke in MHR mode
- Start command:
  - `java -jar target/mhr-build-planner-0.0.1-SNAPSHOT.jar`
- Smoke command:
  - `pwsh ./scripts/team-pilot/03_smoke_check.ps1 -Mode mhr -BaseUrl http://localhost:8080`
- Runtime evidence:
  - Skills endpoint request succeeds
  - Build generation endpoint request succeeds
  - Root endpoint health smoke check succeeds

## Notes

- Keep smoke command pinned to `-Mode mhr` for teammate pilot sessions.
- Keep command pack unchanged during session to preserve reproducible evidence.
