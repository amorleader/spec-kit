# Research: check-prerequisites Output Consistency

## Decision 1: Keep JSON top-level fields stable
- Decision: 固定输出 `FEATURE_DIR` 与 `AVAILABLE_DOCS` 两个顶层字段（即使为空集合也保留字段）。
- Rationale: 调用脚本可采用静态解析逻辑，减少分支判断。
- Alternatives considered:
  - 按场景动态增减字段：被拒绝，破坏兼容与可预测性。

## Decision 2: Enforce deterministic failure signaling
- Decision: 参数约束与缺失必需文件时统一返回非 0 退出码，并输出可操作错误文本。
- Rationale: 便于 CI 快速失败与错误归因。
- Alternatives considered:
  - 只打印警告并返回 0：被拒绝，会导致流水线误判成功。

## Decision 3: Validate with script-level regressions
- Decision: 采用 PowerShell 回归脚本覆盖 git/non-git（或等效）、缺失文档、tasks 参数组合。
- Rationale: 与现有仓库脚本技术栈一致，接入成本低。
- Alternatives considered:
  - 手工验证清单：被拒绝，重复性与可回归性不足。

## Open Clarifications
- 非 git 场景是否在当前仓库下可稳定复现，需要在实现阶段通过临时目录流程确认。

## Finalized After Implementation
- 成功输出在 JSON 模式下固定包含 `FEATURE_DIR` 与 `AVAILABLE_DOCS`。
- `AVAILABLE_DOCS` 在所有成功路径保持数组类型（可为空数组）。
- 缺失 `plan.md` 与 `tasks.md`（RequireTasks 模式）均返回 non-zero 退出码并附带可操作提示。

## Tradeoffs
- 采用脚本级回归（优点：低接入成本、可快速回归；缺点：对命令行上下文更敏感）。
- 保持字段兼容优先于新增字段（优点：降低调用方变更成本；缺点：短期内扩展能力受限）。
