# Quickstart — Prevent setup-plan Overwrite

## Prerequisites
- 当前分支：`003-prevent-setup-plan`
- 可执行 PowerShell
- 已安装 `specify` CLI

## Repro Steps

1. 准备一个带自定义内容的 `plan.md`（existing case），写入标记行 `DO_NOT_OVERWRITE`。
2. 运行默认模式：
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/setup-plan.ps1 -Json`
   - 期望：`plan.md` 保持不变，输出包含 `ACTION: preserved`。
3. 运行强制覆盖模式（修复后行为）：
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/setup-plan.ps1 -Json -Force`
   - 期望：`plan.md` 被模板覆盖，输出包含 `ACTION: overwritten`。
4. 缺失文件场景：删除 `plan.md` 后运行默认模式。
   - 期望：创建新 `plan.md`，输出包含 `ACTION: created`。

## Command Examples

- 默认保护模式：
  - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/setup-plan.ps1 -Json`
- 显式覆盖模式：
  - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/setup-plan.ps1 -Json -Force`

## Verification
- JSON 输出字段稳定：`FEATURE_SPEC`、`IMPL_PLAN`、`SPECS_DIR`、`BRANCH`、`HAS_GIT`。
- 默认模式不覆盖 existing plan。
- 强制模式可覆盖 existing plan。
- 错误场景（如只读文件）提示可操作。

## Next Step
- 运行 `/speckit.tasks` 生成实施任务并开始脚本改造。
