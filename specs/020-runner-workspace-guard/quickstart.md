# Quickstart: Validate Workspace Guard for Quality Runner

1. 运行工作区防污染回归：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks_workspace_guard_regression.ps1`
2. 运行工作区防污染 docs 校验：
   - `powershell -ExecutionPolicy Bypass -File tests/validate_run_all_quality_checks_workspace_guard_docs.ps1`
3. 运行 docs-only 聚合并查看 JSON 统计：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -Json -IncludeDocsOnly`
4. 期望：
   - 聚合结束后工作区保持干净；
   - JSON 输出包含恢复统计字段。
