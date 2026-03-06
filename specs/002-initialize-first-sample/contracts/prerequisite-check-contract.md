# Contract — check-prerequisites.ps1

## Command
- Planning stage:
  - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -Json`
- Implementation stage:
  - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks`
- Paths-only mode:
  - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly`

## Inputs
- `-Json` (bool): 输出 JSON。
- `-RequireTasks` (bool): 要求 `tasks.md` 必须存在。
- `-IncludeTasks` (bool): 在 `AVAILABLE_DOCS` 包含 `tasks.md`。
- `-PathsOnly` (bool): 仅输出路径变量，不做前置验证。

## Output Contract
### Success JSON
```json
{
  "FEATURE_DIR": "<absolute-path>",
  "AVAILABLE_DOCS": ["research.md", "data-model.md", "contracts/", "quickstart.md", "tasks.md?"]
}
```

### PathsOnly JSON
```json
{
  "REPO_ROOT": "<path>",
  "BRANCH": "<branch>",
  "FEATURE_DIR": "<path>",
  "FEATURE_SPEC": "<path>",
  "IMPL_PLAN": "<path>",
  "TASKS": "<path>"
}
```

## Error Modes
- Feature 目录缺失：退出码非 0，提示先运行 `/speckit.specify`。
- `plan.md` 缺失：退出码非 0，提示先运行 `/speckit.plan`。
- `-RequireTasks` 时 `tasks.md` 缺失：退出码非 0，提示先运行 `/speckit.tasks`。

## Result Cases Matrix

| Case | Args | Expected Exit Code | Contract Notes |
|---|---|---:|---|
| Planning pass | `-Json` | 0 | `AVAILABLE_DOCS` 至少包含 `research.md`、`data-model.md`、`contracts/`、`quickstart.md`（按实际存在返回） |
| Implementation pass | `-Json -RequireTasks -IncludeTasks` | 0 | `AVAILABLE_DOCS` 必须包含 `tasks.md` |
| Missing plan | `-Json` | 非 0 | 输出包含 `plan.md not found` 与 `/speckit.plan` 提示 |
| Missing tasks (impl mode) | `-Json -RequireTasks -IncludeTasks` | 非 0 | 输出包含 `tasks.md not found` 与 `/speckit.tasks` 提示 |
| Paths only | `-Json -PathsOnly` | 0 | 返回路径字段，不做存在性校验 |

## Machine Parse Guidance
- 当启用 `-Json` 时，调用方应以 JSON 解析 `FEATURE_DIR` 与 `AVAILABLE_DOCS`。
- 当退出码非 0 时，调用方应直接回传错误文本，不进行 JSON 强制解析。

## Determinism Requirements
- 同一仓库状态下多次执行输出应一致。
- 错误提示必须包含缺失文件名与下一步命令建议。