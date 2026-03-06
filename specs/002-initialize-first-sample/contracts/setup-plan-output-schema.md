# Schema Notes — setup-plan.ps1 JSON Output

## Command
- `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/setup-plan.ps1 -Json`

## Expected JSON Schema (informal)

```json
{
  "FEATURE_SPEC": "string (absolute path, required)",
  "IMPL_PLAN": "string (absolute path, required)",
  "SPECS_DIR": "string (absolute path, required)",
  "BRANCH": "string (required)",
  "HAS_GIT": "boolean (required)"
}
```

## Field Guarantees
- `FEATURE_SPEC`: 指向当前 feature 下 `spec.md`。
- `IMPL_PLAN`: 指向当前 feature 下 `plan.md`，不存在时脚本会先复制模板后返回该路径。
- `SPECS_DIR`: 当前 feature 根目录。
- `BRANCH`: 当前分支名（例：`002-initialize-first-sample`）。
- `HAS_GIT`: 仓库是否可用 git。

## Validation Rules
- 所有 path 字段必须是绝对路径。
- `BRANCH` 与路径末段必须一致。
- `HAS_GIT=true` 时分支应可被 `git branch -a` 识别。

## Requiredness & Nullability

| Field | Required | Nullable | Notes |
|---|---|---|---|
| `FEATURE_SPEC` | Yes | No | 目标 feature 的 `spec.md` 绝对路径 |
| `IMPL_PLAN` | Yes | No | 目标 feature 的 `plan.md` 绝对路径 |
| `SPECS_DIR` | Yes | No | 目标 feature 根目录绝对路径 |
| `BRANCH` | Yes | No | 当前分支名 |
| `HAS_GIT` | Yes | No | 布尔值，仅 `true/false` |

## Consumer Checklist
- 先验证 JSON 可解析，再验证字段完整性。
- 若字段缺失或类型错误，调用方应判定为契约破坏并停止后续自动化步骤。
- 对路径字段建议追加文件系统存在性检查，作为运行时防御。

## Backward Compatibility
- 字段命名保持稳定，新增字段只能追加不能重命名现有字段。