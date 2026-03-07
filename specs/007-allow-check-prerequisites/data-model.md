# Data Model: PathsOnly Output

## Entity: PathOnlyResult
- `REPO_ROOT` (string)
- `BRANCH` (string)
- `FEATURE_DIR` (string)
- `FEATURE_SPEC` (string)
- `IMPL_PLAN` (string)
- `TASKS` (string)

## Entity: ValidationMode
- `pathsOnly` (bool)
- `json` (bool)
- `requireTasks` (bool)

Rule: `pathsOnly=true` 时不做 feature 分支有效性失败门禁。
