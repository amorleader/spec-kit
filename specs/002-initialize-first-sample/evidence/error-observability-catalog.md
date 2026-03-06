# Error & Observability Catalog

## Purpose
记录规划阶段关键命令的可观测信号与常见错误，支持快速定位问题。

## Signals

| Command | Success Signal | Error Signal | Where to Observe |
|---|---|---|---|
| `specify check` | `Specify CLI is ready to use` | 缺失工具项显示 `not found` | 命令标准输出 |
| `setup-plan.ps1 -Json` | 返回有效 JSON 且包含 5 个核心字段 | 非 0 退出或路径字段为空 | 标准输出 + 退出码 |
| `check-prerequisites.ps1 -Json` | `AVAILABLE_DOCS` 包含阶段所需文档 | 输出 `ERROR: ... not found` | 标准输出 + 退出码 |
| `update-agent-context.ps1 -AgentType copilot` | `Agent context update completed successfully` | agent 类型错误/写入失败提示 | 标准输出 + 退出码 |

## Common Errors and Actions

| Error Pattern | Likely Cause | Action |
|---|---|---|
| `Feature directory not found` | 未创建 feature 目录或分支上下文不匹配 | 先创建/切换 feature，再重试 |
| `plan.md not found` | 未执行 `/speckit.plan` | 运行 `setup-plan.ps1 -Json` 生成计划 |
| `tasks.md not found` | 未执行 `/speckit.tasks` 或路径错误 | 生成 `tasks.md` 后复检 |
| `Branch ... already exists` | 重复使用同编号分支 | 切换现有分支或指定新编号 |

## Logging Discipline
- 关键命令执行结果需同步记录到 `evidence/command-log.md`。
- 问题复现至少记录：命令、时间、退出码、核心输出。