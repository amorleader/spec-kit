# Research: Pure JSON Output for create-new-feature

## Decision 1
- `-Json` 模式输出必须为纯 JSON（单对象）。
- 原因：机读调用方可直接解析，避免截取最后一行。

## Decision 2
- 文本模式保留 ACTION 与键值输出。
- 原因：兼顾人工可读性。

## Decision 3
- 通过回归测试同时验证 JSON 纯净性与文本模式保留。
- 原因：防止两类模式互相回归。

## Finalized After Implementation
- `-Json` 模式已去除 ACTION/warning 等非 JSON 行，stdout 可直接解析。
- 文本模式仍保留 ACTION 与键值输出。
- 回归脚本在隔离工作区执行，避免污染主仓库分支状态。
