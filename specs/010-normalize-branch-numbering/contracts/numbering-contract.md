# Contract: create-new-feature Auto Numbering Rule

## Automatic Numbering
- Only branch/spec names matching `^\d{3}-` are counted.
- Non-standard prefixes (e.g., `8034-...`) are ignored.

## Manual Numbering
- `-Number` continues to override auto-numbering.

## Compatibility
- Output fields and branch suffix generation remain unchanged.

## Traceability (Docs -> Behavior)
- `quickstart.md` pollution scenario -> 4-digit noise ignored for auto-numbering
- `quickstart.md` manual mode scenario -> `-Number` override preserved
- `failure-mode-catalog.md` -> jump regression and compatibility guardrails

## Final Validation Record
- Command: `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_numbering_regression.ps1`
- Exit code: 0
- Result: `create_new_feature_numbering_regression: PASSED`
- Command: `powershell -ExecutionPolicy Bypass -File tests/validate_create_new_feature_numbering_docs.ps1`
- Exit code: 0
- Result: `validate_create_new_feature_numbering_docs: PASSED`
