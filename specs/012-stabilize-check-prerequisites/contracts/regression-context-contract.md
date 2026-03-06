# Contract: check_prerequisites_regression Context Binding

## Scope
- Applies to `tests/check_prerequisites_regression.ps1` only.

## Rules
- Script must set `SPECIFY_FEATURE` to `004-improve-check-prerequisites` before invoking check-prerequisites assertions.
- Script must restore previous `SPECIFY_FEATURE` in `finally`.
- Missing `plan.md` and `tasks.md` assertions must continue validating non-zero exit and actionable text.

## Evidence
- Command: `powershell -ExecutionPolicy Bypass -File tests/check_prerequisites_regression.ps1`
- Expected: `check_prerequisites_regression: PASSED`
