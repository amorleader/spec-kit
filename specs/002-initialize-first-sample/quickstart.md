# Quickstart — Initialize First Sample Feature Workflow

## Prerequisites
- 已安装 `specify` CLI。
- 可执行 PowerShell 脚本（Windows PowerShell 或 pwsh）。
- 当前仓库位于 feature 分支 `002-initialize-first-sample`。

## Steps
1. 确认基础环境：
   - `specify check`
   - 期望：输出包含 `Specify CLI is ready to use`
2. 确认当前 feature 上下文与路径：
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/setup-plan.ps1 -Json`
   - 期望：返回 `FEATURE_SPEC/IMPL_PLAN/SPECS_DIR/BRANCH/HAS_GIT`
   - 注意：该命令可能覆盖 `plan.md` 为模板，若已有人工更新计划，请在执行后确认计划内容未回退。
3. 校验规划前置状态（期望至少识别 `plan.md`）：
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -Json`
   - 期望：`AVAILABLE_DOCS` 至少包含 `research.md`、`data-model.md`、`contracts/`、`quickstart.md`
4. 完成 Phase 0/1 文档产物（本目录下）：
   - `research.md`
   - `data-model.md`
   - `contracts/*`
   - `quickstart.md`
5. 更新代理上下文：
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/update-agent-context.ps1 -AgentType copilot`
   - 期望：输出 `Agent context update completed successfully`

6. 实施阶段门禁复检：
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks`
   - 期望：`AVAILABLE_DOCS` 包含 `tasks.md`

## Verification
- 文档目录应包含：
  - `specs/002-initialize-first-sample/plan.md`
  - `specs/002-initialize-first-sample/research.md`
  - `specs/002-initialize-first-sample/data-model.md`
  - `specs/002-initialize-first-sample/quickstart.md`
  - `specs/002-initialize-first-sample/contracts/plan-cli-contract.md`
- 前置检查脚本可根据阶段返回预期结果：
  - 仅计划阶段：`check-prerequisites.ps1 -Json`（不要求 tasks）
  - 实施阶段：`check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks`

## Next Step
- 运行 `/speckit.tasks` 生成 `tasks.md`，进入 Phase 2 任务分解。
