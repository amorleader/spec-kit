# Quickstart: Run Full Quality Checks

1. 全量检查（回归 + 文档）：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1`
2. 仅文档检查：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -IncludeDocsOnly`
3. 期望：
   - 全部通过时输出 `run_all_quality_checks: PASSED`
   - 有失败时输出失败脚本列表并返回非 0
