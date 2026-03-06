# CLI Contract — Plan Workflow

## Scope
定义本 feature 在规划阶段使用的 CLI/脚本接口契约，覆盖输入参数、输出格式与失败语义。

## Interfaces

### 1) `setup-plan.ps1`
- Invocation:
  - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/setup-plan.ps1 -Json`
- Inputs:
  - `-Json` (optional, boolean): 返回 JSON 结构化结果。
- Output (stdout, JSON):
  - `FEATURE_SPEC` (string, absolute path)
  - `IMPL_PLAN` (string, absolute path)
  - `SPECS_DIR` (string, absolute path)
  - `BRANCH` (string)
  - `HAS_GIT` (boolean)
- Errors:
  - 非 0 退出码表示初始化失败（例如路径无法解析）。

**Parameter Constraints**:
- `-Json` 启用后必须返回单个可解析 JSON 对象（不得混入非结构化行）。

**Success Example**:
```json
{
  "FEATURE_SPEC": "E:\\code\\spec-kit\\specs\\002-initialize-first-sample\\spec.md",
  "IMPL_PLAN": "E:\\code\\spec-kit\\specs\\002-initialize-first-sample\\plan.md",
  "SPECS_DIR": "E:\\code\\spec-kit\\specs\\002-initialize-first-sample",
  "BRANCH": "002-initialize-first-sample",
  "HAS_GIT": true
}
```

### 2) `check-prerequisites.ps1`
- Invocation (planning stage):
  - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -Json`
- Invocation (implementation stage):
  - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks`
- Inputs:
  - `-Json` (boolean)
  - `-RequireTasks` (boolean)
  - `-IncludeTasks` (boolean)
  - `-PathsOnly` (boolean)
- Output (stdout):
  - JSON 或文本；`-PathsOnly` 时必须返回路径真值。
- Errors:
  - 缺少 `plan.md` 或 `tasks.md` 时返回非 0，stderr/输出包含缺失说明。

**Parameter Constraints**:
- `-RequireTasks` 仅用于 implementation 前校验。
- `-IncludeTasks` 与 `-RequireTasks` 同时使用时，`AVAILABLE_DOCS` 必须显式包含 `tasks.md`。

**Failure Example**:
```text
ERROR: tasks.md not found in <feature_dir>
Run /speckit.tasks first to create the task list.
```

### 3) `update-agent-context.ps1`
- Invocation:
  - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/update-agent-context.ps1 -AgentType copilot`
- Inputs:
  - `-AgentType copilot`
- Output:
  - 更新 copilot 对应 agent context 文件，保留手工编辑区块。
- Errors:
  - agent 类型非法或文件写入失败时返回非 0。

**Compatibility Notes**:
- 必须支持 `-AgentType copilot` 定向更新，不影响其他 agent 文件。
- 生成或更新文件时需保留“手工编辑区块”（若存在）。

## Determinism & Compatibility Requirements
- CLI 接口必须支持非交互模式。
- 结构化输出字段名保持稳定（尤其 `setup-plan.ps1 -Json`）。
- 错误信息应可行动（指出缺失文件与下一步命令）。
- 同一仓库状态下连续执行，输出字段集合不应变化。
