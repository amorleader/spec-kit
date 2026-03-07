# Failure Mode Catalog: check-prerequisites

## Case A: Missing plan.md
- Trigger: feature directory lacks `plan.md`
- Expected exit code: non-zero
- Expected error message: identifies `plan.md` missing and recommends running `/speckit.plan`
- Actual (US2): exit code non-zero; stderr contains `plan.md not found` and `/speckit.plan`

## Case B: Require tasks but tasks.md missing
- Trigger: run with `-RequireTasks` when `tasks.md` absent
- Expected exit code: non-zero
- Expected error message: identifies `tasks.md` missing and recommends running `/speckit.tasks`
- Actual (US2): exit code non-zero; stderr contains `tasks.md not found` and `/speckit.tasks`

## Case C: Invalid repository context
- Trigger: run outside supported repository structure
- Expected exit code: non-zero
- Expected error message: identifies missing repo markers or feature context

## US2 Evidence
- Command: `powershell -ExecutionPolicy Bypass -File tests/check_prerequisites_regression.ps1`
- Exit code: 0
- Verified assertions:
	- missing `plan.md` => non-zero exit with actionable message
	- `-RequireTasks` + missing `tasks.md` => non-zero exit with actionable message
