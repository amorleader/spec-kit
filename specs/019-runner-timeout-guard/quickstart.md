# Quickstart: Validate Quality Runner Timeout Guard

1. 运行超时回归脚本：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks_timeout_regression.ps1`
2. 运行 JSON 聚合（启用超时 30 秒）：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -Json -IncludeDocsOnly -PerScriptTimeoutSec 30`
3. 运行文档校验脚本：
   - `powershell -ExecutionPolicy Bypass -File tests/validate_run_all_quality_checks_timeout_docs.ps1`
4. 运行 docs-only 文本聚合验证：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -IncludeDocsOnly -PerScriptTimeoutSec 30`
