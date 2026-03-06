# Contract: run_all_quality_checks Branch Restore

## Capture Contract
- Runner captures current branch at start when in git repository.

## Restore Contract
- Runner attempts branch restore in finally when current branch differs from captured branch.
- On restore success, emits `restored branch` message.
- On restore failure, emits warning.

## Compatibility Contract
- Existing script discovery and RUN/PASS/FAIL output format remain unchanged.

## Evidence
- `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1`
- Verify `git rev-parse --abbrev-ref HEAD` before and after are equal.
