# Research: Checkout Exit Code Detection

## Decision 1
- 在恢复路径下对 `git checkout` 采用局部 `ErrorActionPreference=Continue` 执行并读取实时退出码。
- 原因：避免 `Stop` 策略对 native 命令错误流的干扰。

## Decision 2
- 保持失败提示文案不变。
- 原因：兼容现有自动化断言与人工排障习惯。

## Decision 3
- 更新 recovery 回归故障注入匹配模式。
- 原因：实现语句已变更，注入必须持续命中。
