# Research: Preserve Branch in Quality Runner

## Decision 1
- 在 runner 启动时记录当前分支（若在 git 仓库）。
- 原因：后续回归可能切换分支。

## Decision 2
- 在 finally 阶段尝试恢复分支。
- 原因：即使中途失败也应尽量恢复执行上下文。

## Decision 3
- 恢复失败输出 warning，不覆盖主流程结果。
- 原因：保持主失败语义可诊断，同时不吞掉错误。
