# Contract: create-new-feature JSON Output Purity

## JSON Mode
- Command: `create-new-feature.ps1 -Json ...`
- Expected stdout: pure JSON only.
- Required fields: `BRANCH_NAME`, `SPEC_FILE`, `FEATURE_NUM`, `HAS_GIT`.

## Text Mode
- Command: `create-new-feature.ps1 ...`
- Expected stdout: `ACTION:` plus key-value lines.

## Compatibility
- JSON field names and meanings stay unchanged.

## Example JSON Output
```json
{"BRANCH_NAME":"123-example","SPEC_FILE":"<repo>/specs/123-example/spec.md","FEATURE_NUM":"123","HAS_GIT":true}
```

## Traceability (Docs -> Behavior)
- `quickstart.md` JSON mode step -> pure JSON parseability guarantee
- `quickstart.md` text mode step -> ACTION + key-value readability guarantee
- `failure-mode-catalog.md` -> mixed-output and missing-field guardrails

## Final Validation Record
- Command: `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_json_output_regression.ps1`
- Exit code: 0
- Result: `create_new_feature_json_output_regression: PASSED`
- Command: `powershell -ExecutionPolicy Bypass -File tests/validate_create_new_feature_json_output_docs.ps1`
- Exit code: 0
- Result: `validate_create_new_feature_json_output_docs: PASSED`
