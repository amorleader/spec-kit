# Research: create-new-feature Argument Parsing

## Decision 1: Normalize description collection
- Decision: 明确描述参数来源，支持常见顺序（参数在前/描述在前）并去除空白输入。
- Rationale: 降低入口命令误用概率。
- Alternatives considered:
  - 强制单一调用顺序：被拒绝，用户体验差且兼容性差。

## Decision 2: Preserve existing output contract
- Decision: 保持 JSON 字段 `BRANCH_NAME/SPEC_FILE/FEATURE_NUM/HAS_GIT` 不变。
- Rationale: 避免破坏已有自动化依赖。
- Alternatives considered:
  - 重构输出结构：被拒绝，收益低风险高。

## Decision 3: Add regression tests for arg combinations
- Decision: 使用 PowerShell 脚本覆盖参数混排组合。
- Rationale: 可稳定复现并防回归。
- Alternatives considered:
  - 仅更新文档不加测试：被拒绝，无法保证持续稳定。

## Finalized After Implementation
- 新增显式位置参数 `Description`，并与 remaining arguments 合并，解决常见顺序解析不一致。
- 保持 JSON 输出字段兼容：`BRANCH_NAME/SPEC_FILE/FEATURE_NUM/HAS_GIT`。
- `-ShortName` 与 `-Number` 优先级保持稳定，未改变既有分支命名规则。
