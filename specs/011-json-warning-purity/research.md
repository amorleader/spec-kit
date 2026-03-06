# Research: JSON Warning Purity for create-new-feature

## Decision 1
- `-Json` 模式不应输出 warning 文本。
- 原因：调用方经常合并流后直接解析 JSON。

## Decision 2
- 文本模式继续保留 warning 提示。
- 原因：人工调试需要可见告警。

## Decision 3
- 通过“长分支名触发截断”场景做回归。
- 原因：这是当前最典型 warning 触发路径。
