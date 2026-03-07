# Contract: create-new-feature Existing Branch Recovery

## Success Behavior
- Existing target branch (current branch): recover missing `specs/<branch>/spec.md` and return success.
- Existing target branch (non-current branch): checkout target branch then recover missing files.
- Existing `spec.md`: preserve file content.

## JSON Output Compatibility
- Required fields remain: `BRANCH_NAME`, `SPEC_FILE`, `FEATURE_NUM`, `HAS_GIT`.

## Example Output
```json
{"BRANCH_NAME":"006-recover-missing-specs","SPEC_FILE":"<repo>/specs/006-recover-missing-specs/spec.md","FEATURE_NUM":"006","HAS_GIT":true}
```

## Failure Behavior
- If existing branch cannot be checked out: non-zero exit + actionable error.

## Traceability (Docs -> Behavior)
- `quickstart.md` scenario 1 -> current-branch recovery with missing specs directory
- `quickstart.md` scenario 2 -> existing spec preservation (no overwrite)
- `quickstart.md` scenario 3 -> non-current existing branch checkout + recovery

## Final Validation Record
- Command: `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_recovery_regression.ps1`
- Exit code: 0
- Result: `create_new_feature_recovery_regression: PASSED`
- Command: `powershell -ExecutionPolicy Bypass -File tests/validate_create_new_feature_recovery_docs.ps1`
- Exit code: 0
- Result: `validate_create_new_feature_recovery_docs: PASSED`
