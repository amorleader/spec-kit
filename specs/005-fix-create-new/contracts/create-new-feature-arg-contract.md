# Contract: create-new-feature Argument Parsing

## Command
- `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/create-new-feature.ps1 -Json "description"`
- `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/create-new-feature.ps1 "description" -Json`

## Success Output (JSON)
- Required fields:
  - `BRANCH_NAME`
  - `SPEC_FILE`
  - `FEATURE_NUM`
  - `HAS_GIT`

### Example: Json-first invocation
```json
{"BRANCH_NAME":"901-json-first-description","SPEC_FILE":"<workspace>/specs/901-json-first-description/spec.md","FEATURE_NUM":"901","HAS_GIT":false}
```

### Example: Description-first invocation
```json
{"BRANCH_NAME":"902-desc-first-description","SPEC_FILE":"<workspace>/specs/902-desc-first-description/spec.md","FEATURE_NUM":"902","HAS_GIT":false}
```

## Failure Behavior
- Missing or whitespace-only description: non-zero exit + usage/error message.
- Existing target branch conflict: non-zero exit + actionable message.

## Compatibility Rules
- Do not remove existing JSON fields.
- Keep branch numbering and naming semantics unchanged unless explicit options override.

## Parsing Rules
- 支持 `-Json "description"` 与 `"description" -Json` 两种常见顺序。
- 当显式提供 `-ShortName` 时，分支后缀优先使用 `ShortName`。
- 当显式提供 `-Number` 时，编号优先使用输入值。

## Evidence Matrix
- US1: two invocation orders return valid JSON contract
- US2: `-ShortName` + `-Number` mixed options remain deterministic

## Traceability (Docs -> Behavior)
- `quickstart.md` scenario 1/2 -> argument-order compatible success paths
- `quickstart.md` scenario 3 -> deterministic `-ShortName` + `-Number` precedence
- `failure-mode-catalog.md` -> missing description and conflict failures

## Final Validation Record
- Command: `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_regression.ps1`
- Exit code: 0
- Result: `create_new_feature_regression: PASSED`
- Command: `powershell -ExecutionPolicy Bypass -File tests/validate_create_new_feature_docs.ps1`
- Exit code: 0
- Result: `validate_create_new_feature_docs: PASSED`
