# Quickstart: check-prerequisites Output Consistency

## Goal
验证 `check-prerequisites.ps1 -Json` 的输出结构与失败语义在关键场景下保持一致。

## Preconditions
- 位于仓库根目录
- PowerShell 可执行仓库脚本

## Scenarios

1. 正常场景（已有 spec/plan）
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -Json`
   - 期望：返回 JSON，包含 `FEATURE_DIR` 与数组类型 `AVAILABLE_DOCS`。

2. 含 tasks 约束场景
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks`
   - 期望：若任务文件存在，`AVAILABLE_DOCS` 包含 `tasks.md`；缺失则 non-zero 退出并提示 `/speckit.tasks`。

3. 缺失必需文档场景
   - 暂时移除/重命名目标文档后执行命令
   - 期望：non-zero 退出，错误文本明确指出缺失项并给出下一步命令。

## Done Criteria
- 所有场景输出与契约文档一致
- 调用方可直接依赖稳定字段解析
