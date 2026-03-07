# Research: Docs-Only Aggregate Hardening

## Decision 1
- docs-only 执行路径显式聚焦 `validate_*_docs.ps1`。
- 原因：避免非 docs 脚本混入导致统计偏差。

## Decision 2
- 聚合输出保持现有 JSON 字段契约不变。
- 原因：保障下游解析兼容。

## Decision 3
- 增加 docs-only 专项回归和 docs validator。
- 原因：将路径稳定性固化为持续门禁。