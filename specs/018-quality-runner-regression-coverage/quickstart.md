# Quickstart: Validate Quality Runner Regression Coverage

1. 运行新回归：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks_regression.ps1`
2. 运行 JSON 汇总模式：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -Json -IncludeDocsOnly`
   - 期望：输出可直接 `ConvertFrom-Json`。
3. 运行新文档校验：
   - `powershell -ExecutionPolicy Bypass -File tests/validate_run_all_quality_checks_docs.ps1`
4. 运行 docs-only 聚合验证：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -IncludeDocsOnly`
