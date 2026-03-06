# Quickstart: Pure JSON Output

1. JSON mode
- `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/create-new-feature.ps1 -Json -Number 880 "json pure mode"`
- 期望：stdout 可直接 `ConvertFrom-Json` 成功。

2. Text mode
- `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/create-new-feature.ps1 -Number 881 "text mode"`
- 期望：包含 `ACTION:` 与键值输出。
