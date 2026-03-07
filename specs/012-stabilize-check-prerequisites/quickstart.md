# Quickstart: Branch-Independent check-prerequisites Regression

1. 在任意 feature 分支执行：
   - `powershell -ExecutionPolicy Bypass -File tests/check_prerequisites_regression.ps1`
2. 期望：
   - 输出 `check_prerequisites_regression: PASSED`
3. 可选验证环境恢复：
   - 执行前后检查 `$env:SPECIFY_FEATURE` 值应保持一致。
