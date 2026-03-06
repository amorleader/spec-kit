# Data Model — Initialize First Sample Feature Workflow

## Entities

### 1) FeatureWorkspace
- Description: 某个 feature 分支对应的规划文档工作空间。
- Fields:
  - `branchName` (string, required, pattern: `^\d{3}-[a-z0-9-]+$`)
  - `specDir` (string, required)
  - `createdAt` (date, required)
- Relationships:
  - one-to-one with `FeatureSpec`
  - one-to-one with `ImplementationPlan`
  - one-to-many with `ContractDocument`

### 2) FeatureSpec
- Description: feature 需求规格文档（输入源）。
- Fields:
  - `path` (string, required, default: `spec.md`)
  - `status` (enum: `draft|refined`, required)
  - `userStories` (array, optional in current sample stage)
- Validation rules:
  - 文件必须存在；允许模板内容用于样例流程阶段。

### 3) ImplementationPlan
- Description: 计划文档，承载技术上下文、门禁与结构决策。
- Fields:
  - `path` (string, required, default: `plan.md`)
  - `technicalContextComplete` (boolean, required)
  - `constitutionGateStatus` (enum: `pass|fail`, required)
  - `postDesignRecheckStatus` (enum: `pass|fail`, required)
- Validation rules:
  - `technicalContextComplete=true` 时不得包含 `NEEDS CLARIFICATION`。

### 4) ResearchRecord
- Description: Phase 0 研究结论，记录决策依据。
- Fields:
  - `path` (string, required, default: `research.md`)
  - `decisions` (array, required)
  - `clarificationsResolved` (boolean, required)
- Validation rules:
  - 每个研究项包含 `Decision`、`Rationale`、`Alternatives considered`。

### 5) ContractDocument
- Description: 对外或跨组件接口契约（本 feature 为 CLI/脚本契约）。
- Fields:
  - `path` (string, required)
  - `interfaceType` (enum: `cli|script-json-output`, required)
  - `inputs` (array, required)
  - `outputs` (array, required)
  - `errorModes` (array, required)
- Relationships:
  - many-to-one to `FeatureWorkspace`

### 6) QuickstartGuide
- Description: 复现流程与验证步骤说明。
- Fields:
  - `path` (string, required, default: `quickstart.md`)
  - `prerequisites` (array, required)
  - `steps` (array, required)
  - `verificationCommands` (array, required)

## State Transitions

### FeatureWorkspace lifecycle
1. `initialized` → 2. `planned` → 3. `designed`

- `initialized`:
  - 必需文件: `spec.md`
- `planned`:
  - 必需文件: `plan.md`, `research.md`
- `designed`:
  - 必需文件: `data-model.md`, `quickstart.md`, `contracts/*`

Transition guards:
- `initialized -> planned`: `plan.md` 完整且 Constitution Check = pass。
- `planned -> designed`: Phase 1 设计文档齐全且 post-design Constitution Check = pass。
