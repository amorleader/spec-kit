# Data Model: create-new-feature Argument Parsing

## Entity: FeatureCreateInvocation
- Purpose: 表示一次脚本调用请求。
- Fields:
  - `description` (string)
  - `shortName` (string|null)
  - `number` (int|null)
  - `json` (bool)
  - `hasGit` (bool)
- Invariants:
  - description 不能为空白。
  - number 为正整数（若显式提供）。

## Entity: BranchCreationResult
- Purpose: 表示脚本执行结果。
- Fields:
  - `branchName` (string)
  - `specFile` (string)
  - `featureNum` (string)
  - `hasGit` (bool)
- Invariants:
  - JSON 模式输出字段集合保持兼容。
  - `specFile` 为可访问路径。
