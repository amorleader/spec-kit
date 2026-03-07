# Command Evidence Template

## Run Metadata
- Date:
- Operator:
- Branch: `003-prevent-setup-plan`

## Case A — Existing plan (default mode)
- Command: `powershell -ExecutionPolicy Bypass -File tests/setup_plan_regression.ps1`
- Exit code: 0
- Expected action: preserved
- Actual action: preserved (verified by marker `DO_NOT_OVERWRITE` retained)
- JSON fields present: FEATURE_SPEC / IMPL_PLAN / SPECS_DIR / BRANCH / HAS_GIT

## Case B — Missing plan (default mode)
- Command: `powershell -ExecutionPolicy Bypass -File tests/setup_plan_regression.ps1`
- Exit code: 0
- Expected action: created
- Actual action: created (plan regenerated when missing)
- JSON fields present: FEATURE_SPEC / IMPL_PLAN / SPECS_DIR / BRANCH / HAS_GIT

## Case C — Existing plan (force mode)
- Command: `powershell -ExecutionPolicy Bypass -File tests/setup_plan_regression.ps1`
- Exit code: 0
- Expected action: overwritten
- Actual action: overwritten (marker `OVERWRITE_ME` removed after force run)
- JSON fields present: FEATURE_SPEC / IMPL_PLAN / SPECS_DIR / BRANCH / HAS_GIT

## Full Regression Log (T028)
- Command: `powershell -ExecutionPolicy Bypass -File tests/setup_plan_regression.ps1`
- Exit code: 0
- Output summary:
	- US1 existing default preserve: PASS
	- US1 missing default create: PASS
	- US2 existing force overwrite: PASS
	- US2 JSON compatibility: PASS

## Notes
- Capture stderr when exit code is non-zero.
- Link to regression script output where applicable.
