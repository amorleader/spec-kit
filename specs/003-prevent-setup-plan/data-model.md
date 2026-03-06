# Data Model — Prevent setup-plan Overwrite

## Entities

### 1) PlanFileState
- Description: 目标 feature 目录中 `plan.md` 的状态。
- Fields:
  - `path` (string, required)
  - `exists` (boolean, required)
  - `isWritable` (boolean, required)
  - `contentHash` (string, optional)
  - `state` (enum: `missing|existing|readonly`, required)

### 2) SetupPlanInvocation
- Description: 一次 `setup-plan.ps1` 调用及其动作结果。
- Fields:
  - `branch` (string, required)
  - `jsonMode` (boolean, required)
  - `forceOverwrite` (boolean, required)
  - `resultAction` (enum: `created|preserved|overwritten|failed`, required)
  - `exitCode` (int, required)

### 3) SetupPlanOutput
- Description: `setup-plan -Json` 输出对象。
- Fields:
  - `FEATURE_SPEC` (string, required)
  - `IMPL_PLAN` (string, required)
  - `SPECS_DIR` (string, required)
  - `BRANCH` (string, required)
  - `HAS_GIT` (boolean, required)

## State Transitions

- `missing` + default invoke -> `created`
- `existing` + default invoke -> `preserved`
- `existing` + force invoke -> `overwritten`
- `readonly` + force/default invoke -> `failed`

## Validation Rules
- 默认调用不得将 `existing` 状态转为 `overwritten`。
- `resultAction=failed` 时必须输出可操作错误信息。
- `SetupPlanOutput` 字段集必须稳定且完整。
