# Quickstart: Verify Branch Preservation in Quality Runner

1. 记录当前分支：
   - `git rev-parse --abbrev-ref HEAD`
2. 运行：
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1`
3. 再次检查分支：
   - `git rev-parse --abbrev-ref HEAD`
4. 期望：
   - 前后分支一致，且输出包含 `run_all_quality_checks: PASSED`。
