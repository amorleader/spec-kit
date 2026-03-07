# Research: JSON Summary Mode for Quality Runner

## Decision 1
- 新增 `-Json` 开关输出机读汇总对象。
- 原因：便于 CI 与自动化脚本消费。

## Decision 2
- JSON 模式抑制 RUN/PASS/FAIL 文本与分支恢复提示。
- 原因：保证输出可直接解析。

## Decision 3
- 默认文本模式保持完全兼容。
- 原因：避免破坏已有人工排障流程。
