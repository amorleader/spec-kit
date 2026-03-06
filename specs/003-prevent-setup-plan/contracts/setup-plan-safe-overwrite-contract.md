# Contract — setup-plan Safe Overwrite Behavior

## Command
- Default:
  - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/setup-plan.ps1 -Json`
- Force overwrite:
  - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/setup-plan.ps1 -Json -Force`

## Parameter Semantics
- `-Force` only affects behavior when `plan.md` already exists.
- Without `-Force`, existing `plan.md` MUST be preserved.
- With `-Force`, existing `plan.md` MUST be replaced from template (or empty fallback when template missing).

## Behavioral Contract

| Plan File State | Default Mode | Force Mode |
|---|---|---|
| Missing | Create from template | Create from template |
| Existing | Preserve current content | Overwrite with template |
| Readonly | Fail with actionable error | Fail with actionable error |

## US1 Implemented Behavior Notes
- Default mode on existing `plan.md` MUST preserve file content and MUST NOT write template.
- Default mode on missing `plan.md` MUST create file from template (or empty fallback when template missing).
- Script output MUST include explicit action hints:
  - `ACTION: preserved ...`
  - `ACTION: created ...`

## JSON Output Contract
```json
{
  "FEATURE_SPEC": "string",
  "IMPL_PLAN": "string",
  "SPECS_DIR": "string",
  "BRANCH": "string",
  "HAS_GIT": "boolean"
}
```

## Compatibility Requirements
- 上述字段名称与类型保持不变。
- 非 JSON 模式下仍输出可读文本提示。
- 动作提示必须可判别：`ACTION: preserved|created|overwritten`。

## Error Contract
- 失败返回非 0。
- 错误提示必须包含：失败原因 + 推荐下一步（例如检查文件权限）。
