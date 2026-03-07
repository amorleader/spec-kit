# Failure Mode Catalog: create-new-feature Argument Parsing

## Case A: Missing description input
- Trigger: no description provided
- Expected exit code: non-zero
- Expected error: usage + explicit missing description message

## Case B: Whitespace-only description
- Trigger: description contains only spaces
- Expected exit code: non-zero
- Expected error: explicit validation failure

## Case C: Branch conflict
- Trigger: generated branch already exists
- Expected exit code: non-zero
- Expected error: actionable branch-conflict guidance

## Deterministic Parsing Notes (US2)
- `-ShortName` + description 混排时，`ShortName` 优先作为后缀来源。
- `-Number` 明确覆盖自动编号逻辑，`FEATURE_NUM` 与分支前缀保持一致。

## US2 Evidence
- Command: `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_regression.ps1`
- Exit code: 0
- Verified:
	- `-Json -ShortName demo-short -Number 910 "..."` => `BRANCH_NAME=910-demo-short`
	- `"..." -Json -Number 915` => `FEATURE_NUM=915` and `BRANCH_NAME` starts with `915-`
