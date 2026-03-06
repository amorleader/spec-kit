# Contract: check-prerequisites PathsOnly Mode

## PathsOnly Success
- Command: `check-prerequisites.ps1 -PathsOnly -Json`
- Expected: exit code 0 with fields `REPO_ROOT`, `BRANCH`, `FEATURE_DIR`, `FEATURE_SPEC`, `IMPL_PLAN`, `TASKS`
- Applies on any branch, including non-feature branches.

## Normal Mode Guardrail
- Command: `check-prerequisites.ps1 -Json`
- On non-feature branches, expected non-zero failure remains unchanged.

## Compatibility
- PathsOnly output fields and names remain stable.
- Normal mode validation behavior remains stable.

## Traceability (Docs -> Behavior)
- `quickstart.md` step 1/3 -> PathsOnly JSON/text success on non-feature branches
- `quickstart.md` step 2 -> normal mode non-zero failure unchanged
- `failure-mode-catalog.md` -> normal mode guardrail and PathsOnly success boundary

## Final Validation Record
- Command: `powershell -ExecutionPolicy Bypass -File tests/check_prerequisites_paths_only_regression.ps1`
- Exit code: 0
- Result: `check_prerequisites_paths_only_regression: PASSED`
- Command: `powershell -ExecutionPolicy Bypass -File tests/validate_check_prerequisites_paths_only_docs.ps1`
- Exit code: 0
- Result: `validate_check_prerequisites_paths_only_docs: PASSED`
