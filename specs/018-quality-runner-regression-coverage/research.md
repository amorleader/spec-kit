# Research: Quality Runner Regression Coverage

## Decision 1
- 新增独立回归脚本覆盖 JSON/文本/分支稳定。
- 原因：减少未来 runner 演进时的回归风险。

## Decision 2
- 新增 JSON 断言 helper。
- 原因：避免多个脚本重复字段校验逻辑。

## Decision 3
- 新增文档 validator，并纳入 docs-only 聚合执行。
- 原因：保证新增 runner 契约文档持续一致。
