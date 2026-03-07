# Research: setup-plan Regression Mode Separation

## Decision 1
- 文本 `ACTION` 断言使用不带 `-Json` 的调用。
- 原因：`ACTION:` 是文本模式契约，不属于 JSON 模式负载。

## Decision 2
- JSON 字段兼容性检查单独调用 `-Json`。
- 原因：避免模式耦合，保证断言语义清晰。

## Decision 3
- 不改动 `setup-plan.ps1`。
- 原因：生产脚本与 JSON 纯净回归已通过，问题在测试脚本。
