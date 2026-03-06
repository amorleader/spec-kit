# Quickstart: setup-plan JSON purity

1. JSON mode
- `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/setup-plan.ps1 -Json`
- 期望：stdout 可直接 `ConvertFrom-Json`。

2. Text mode
- `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/setup-plan.ps1`
- 期望：输出包含 `ACTION:`。
