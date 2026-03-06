# Quickstart: Validate Workspace Status Parser Hardening

1. 运行状态解析专项回归：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks_status_parser_regression.ps1`
2. 运行状态解析 docs 校验：
   - `powershell -ExecutionPolicy Bypass -File tests/validate_run_all_quality_checks_status_parser_docs.ps1`
3. 运行 docs-only JSON 聚合：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -Json -IncludeDocsOnly`
4. 期望：
   - rename 场景可恢复；
   - JSON 输出保持兼容可解析。
