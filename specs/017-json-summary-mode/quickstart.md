# Quickstart: Use JSON Summary Mode in Quality Runner

1. 仅文档校验（JSON模式）：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -Json -IncludeDocsOnly`
2. 期望：
   - 输出是单行 JSON，可直接 `ConvertFrom-Json`。
3. 文本模式兼容检查：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -IncludeDocsOnly`
   - 期望保留 `RUN/PASS/FAIL` 文本。
