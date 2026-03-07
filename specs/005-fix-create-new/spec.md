# Feature Specification: Fix create-new-feature Argument Parsing Consistency

**Feature Branch**: `005-fix-create-new`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Fix create-new-feature argument parsing consistency"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Accept Natural CLI Invocation (Priority: P1)

作为使用者，我希望 `create-new-feature.ps1` 能稳定解析常见调用方式（描述在前/参数在前），避免因为参数顺序导致脚本直接报 usage。

**Why this priority**: 这是创建 feature 的入口能力，失败会阻断后续 spec/plan/tasks 全流程。

**Independent Test**: 用两种调用顺序执行命令，均能创建同等结果（分支名、spec 路径、JSON 字段）。

**Acceptance Scenarios**:

1. **Given** 使用 `-Json "description"` 形式调用, **When** 执行脚本, **Then** 成功输出 JSON 结果且不报 usage。
2. **Given** 使用 `"description" -Json` 形式调用, **When** 执行脚本, **Then** 结果与前者一致。

---

### User Story 2 - Deterministic Option Parsing (Priority: P2)

作为维护者，我希望参数绑定规则明确，避免 `ValueFromRemainingArguments` 与显式参数组合时出现歧义。

**Why this priority**: 降低脚本维护复杂度并减少回归风险。

**Independent Test**: 覆盖 `-ShortName`、`-Number`、`-Json` 与描述文本混排组合，行为 deterministic 且可预测。

**Acceptance Scenarios**:

1. **Given** 同时提供 `-ShortName` 与描述文本, **When** 运行脚本, **Then** 使用 ShortName 生成分支后缀且无解析冲突。
2. **Given** 提供 `-Number` 覆盖自动编号, **When** 运行脚本, **Then** 编号按输入值生效。

---

### User Story 3 - Update Usage & Contract Docs (Priority: P3)

作为团队成员，我希望脚本帮助文本和契约文档能明确参数顺序与示例，避免再次误用。

**Why this priority**: 文档一致性能降低新成员上手成本。

**Independent Test**: 仅根据帮助文本和 contract 文档即可写出成功调用命令。

**Acceptance Scenarios**:

1. **Given** 查看帮助信息和 contract, **When** 按示例执行, **Then** 调用成功且输出符合文档。

---

### Edge Cases

- 描述文本含特殊字符或多空格时，仍能正确归一化并生成分支名。
- `-Json` 与 `-Help` 同时出现时，帮助行为优先且退出码稳定。
- 描述文本缺失或仅空白时，错误提示保持清晰且一致，并返回 non-zero 退出码。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `create-new-feature.ps1` MUST parse feature description correctly regardless of common option ordering.
- **FR-002**: Script MUST preserve existing behavior for `-ShortName`, `-Number`, and branch naming rules.
- **FR-003**: Script MUST emit deterministic usage/error messages for missing or invalid description input.
- **FR-004**: JSON output contract fields (`BRANCH_NAME`, `SPEC_FILE`, `FEATURE_NUM`, `HAS_GIT`) MUST remain backward compatible.
- **FR-005**: Help/contract documentation MUST reflect the supported argument patterns.

## Constitution Alignment *(mandatory)*

- **CA-001 Spec Traceability**: US1→FR-001/FR-004，US2→FR-002/FR-003，US3→FR-005。
- **CA-002 CLI Contract Impact**: 仅修复参数解析路径，不改变核心输出字段。
- **CA-003 Test-First Plan**: 先写失败回归（参数顺序导致 usage），再实现解析修复。
- **CA-004 Boundary Coverage**: 覆盖参数混排、空输入、帮助模式和编号/短名组合。
- **CA-005 Observability & Versioning**: 错误信息可诊断；行为修复按 PATCH 处理。

### Key Entities *(include if feature involves data)*

- **FeatureCreateInvocation**: 一次 create-new-feature 调用上下文（参数、描述、输出）。
- **BranchCreationResult**: 分支创建结果（编号、分支名、spec 文件路径、是否 git）。

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 两种常见参数顺序调用成功率达到 100%。
- **SC-002**: 关键参数组合（`-ShortName`、`-Number`、`-Json`）回归通过率达到 100%。
- **SC-003**: JSON 输出字段保持兼容，无字段缺失。
- **SC-004**: 因参数顺序导致的 usage 误报降为 0。
