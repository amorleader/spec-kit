# Quickstart: Validate Porcelain-Z Status Parser

1. 运行 z-mode 回归脚本：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks_status_parser_zmode_regression.ps1`
2. 运行 z-mode docs 校验：
   - `powershell -ExecutionPolicy Bypass -File tests/validate_run_all_quality_checks_status_parser_zmode_docs.ps1`
3. 运行 docs-only JSON 聚合：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -Json -IncludeDocsOnly`
4. 期望：
   - rename 特殊路径场景通过；
   - JSON 输出保持兼容并可解析。
