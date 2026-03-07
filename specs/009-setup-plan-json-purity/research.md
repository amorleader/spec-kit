# Research: setup-plan JSON Output Purity

## Decision 1
- `setup-plan.ps1 -Json` 必须输出纯 JSON（stdout 不混入 ACTION 文本）。
- 原因：调用方可直接解析，无需截取最后一行。

## Decision 2
- 非 JSON 模式保留 ACTION 文本提示。
- 原因：保持人工执行可观测性。

## Decision 3
- 回归覆盖 JSON 纯净 + 文本模式提示保留。
- 原因：防止双模式回归。

## Finalized After Implementation
- `-Json` 模式已不输出 ACTION/warning 文本。
- 文本模式保留 ACTION 与路径输出。
- 回归与文档一致性检查通过。
