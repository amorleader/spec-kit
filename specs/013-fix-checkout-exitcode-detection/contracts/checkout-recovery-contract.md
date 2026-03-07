# Contract: create-new-feature Checkout Recovery

## Success Path
- If target branch already exists and current branch differs, script must checkout target branch and continue.
- `ACTION` should reflect recovered path.

## Failure Path
- If checkout fails (including injected throw), script must exit non-zero with actionable error text.

## Compatibility
- JSON fields remain unchanged.
- Text-mode key-value lines remain unchanged.

## Evidence
- `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_recovery_regression.ps1`
- `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_regression.ps1`
- `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_json_output_regression.ps1`
