# Quickstart: Validate Checkout Exit Code Detection

1. 运行 recovery 回归：
   - `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_recovery_regression.ps1`
2. 期望：
   - `recover when branch exists but is non-current` 通过。
   - `failed checkout returns actionable error` 通过（断言非 0）。
3. 回归保护：
   - `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_regression.ps1`
   - `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_json_output_regression.ps1`
