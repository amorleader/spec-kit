# CLI Verification Matrix

## Scope
对规划阶段核心命令建立“命令 -> 契约 -> 期望输出/错误”的验证映射。

| Command | Contract Source | Success Criteria | Failure Criteria |
|---|---|---|---|
| `setup-plan.ps1 -Json` | `contracts/plan-cli-contract.md` | 返回 `FEATURE_SPEC/IMPL_PLAN/SPECS_DIR/BRANCH/HAS_GIT` 且路径可解析 | 非 0 退出码并输出可定位错误 |
| `check-prerequisites.ps1 -Json` | `contracts/prerequisite-check-contract.md` | 返回 `FEATURE_DIR` 与 `AVAILABLE_DOCS`，且文档列表符合阶段预期 | 缺失关键文件时报错并给出下一步建议 |
| `check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks` | `contracts/prerequisite-check-contract.md` | 文档列表包含 `tasks.md` | `tasks.md` 缺失时非 0 并给出补救提示 |
| `update-agent-context.ps1 -AgentType copilot` | `contracts/plan-cli-contract.md` | 更新/创建 `.github/agents/copilot-instructions.md` 且输出成功摘要 | agent 类型错误或写入失败时非 0 |

## Execution Notes
- 所有命令必须可非交互执行。
- JSON 输出字段名需稳定，避免后续自动化解析破坏。

## Evidence Targets

| Command | Evidence File | Minimum Record |
|---|---|---|
| `setup-plan.ps1 -Json` | `evidence/command-log.md` | 时间、命令、退出码、核心 JSON 字段 |
| `check-prerequisites.ps1 -Json` | `evidence/command-log.md` | 时间、命令、退出码、`AVAILABLE_DOCS` |
| `check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks` | `evidence/command-log.md` | 时间、命令、退出码、`tasks.md` 是否出现 |
| `update-agent-context.ps1 -AgentType copilot` | `evidence/command-log.md` | 时间、命令、退出码、更新目标文件 |

## Recommended Validation Order
1. `setup-plan.ps1 -Json`
2. `check-prerequisites.ps1 -Json`
3. `check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks`
4. `update-agent-context.ps1 -AgentType copilot`