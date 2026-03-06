# Contract: create-new-feature Warning Stream Behavior

## JSON Mode
- Must output parseable JSON only (no warning lines).

## Text Mode
- Must retain warnings for human operators.

## Compatibility
- JSON fields unchanged.
- Text key-value outputs unchanged.

## Traceability
- FR-001, FR-003 -> JSON Mode + Compatibility
- FR-004 -> Evidence section and quickstart alignment

## Evidence
- Command: `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_warning_stream_regression.ps1`
- Result: `create_new_feature_warning_stream_regression: PASSED`
- Verified JSON scenario: combined stream starts with `{` and is parseable with `ConvertFrom-Json`.
- Command: `powershell -ExecutionPolicy Bypass -File tests/validate_create_new_feature_warning_docs.ps1`
- Result: `validate_create_new_feature_warning_docs: PASSED`
