# Research: Full Quality Check Runner

## Decision 1
- 自动发现并执行 `*_regression.ps1` 与 `validate_*_docs.ps1`。
- 原因：避免手工维护脚本列表。

## Decision 2
- 每个脚本输出 `RUN/PASS/FAIL` 块并保留原始输出。
- 原因：便于排障并快速定位失败脚本。

## Decision 3
- 提供 `-IncludeDocsOnly` 模式。
- 原因：支持仅文档收口场景的快速检查。

## Decision 4
- 将输出对象规范化为纯文本再打印。
- 原因：避免 ErrorRecord 格式噪声干扰可读性。
