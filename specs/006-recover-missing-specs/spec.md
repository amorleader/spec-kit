# Feature Specification: Recover Missing Specs Directory for Existing Feature Branch

**Feature Branch**: `006-recover-missing-specs`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Recover missing specs directory when feature branch already exists"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Reuse Existing Feature Branch Safely (Priority: P1)

作为使用者，我希望当目标 feature 分支已存在且我就在该分支时，`create-new-feature.ps1` 不要直接失败，而是继续补齐缺失的 `specs/<branch>/spec.md`。

**Why this priority**: 这是高频阻断问题，会导致流程卡死在入口命令。

**Independent Test**: 在已有分支且缺失目录的场景调用脚本，命令成功返回并创建缺失目录/文件。

**Acceptance Scenarios**:

1. **Given** 当前分支即目标分支且 `specs/<branch>` 缺失, **When** 运行脚本, **Then** 命令成功并补齐 `spec.md`。
2. **Given** 当前分支即目标分支且 `spec.md` 已存在, **When** 运行脚本, **Then** 不覆盖已有内容并成功返回路径。

---

### User Story 2 - Deterministic Behavior for Existing Non-current Branch (Priority: P2)

作为维护者，我希望当目标分支已存在但不是当前分支时，行为可预测：要么明确切换并继续，要么给出可操作错误提示。

**Why this priority**: 避免分支状态混乱，确保自动化可控。

**Independent Test**: 在目标分支已存在且非当前分支场景，脚本行为 deterministic、输出与文档一致且可重复。

**Acceptance Scenarios**:

1. **Given** 目标分支已存在但非当前分支, **When** 运行脚本, **Then** 脚本切换到该分支并继续补齐目录与 spec。

---

### User Story 3 - Document Recovery Contract (Priority: P3)

作为团队成员，我希望帮助文本和契约文档明确“分支已存在时的恢复行为”，便于排障。

**Why this priority**: 文档一致性决定可交接性。

**Independent Test**: 仅依赖 quickstart/contract 文档即可复现恢复场景。

**Acceptance Scenarios**:

1. **Given** 阅读文档, **When** 复现 branch-dir 不一致场景, **Then** 行为符合文档描述。

---

### Edge Cases

- `specs/<branch>` 目录存在但 `spec.md` 缺失时，脚本应只补缺而非重置目录。
- 目标分支存在但 `git checkout` 失败时，输出应为 non-zero 并附可操作提示。
- `-Json` 模式下恢复路径字段仍需兼容。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Script MUST support recovery when target branch already exists and `specs/<branch>` is missing.
- **FR-002**: Script MUST preserve existing `spec.md` content unless file is absent.
- **FR-003**: Script MUST provide deterministic behavior when branch exists but is not current (checkout and continue or actionable failure).
- **FR-004**: JSON output fields (`BRANCH_NAME`, `SPEC_FILE`, `FEATURE_NUM`, `HAS_GIT`) MUST remain backward compatible.
- **FR-005**: Help/contract docs MUST describe branch-exists recovery behavior.

## Constitution Alignment *(mandatory)*

- **CA-001 Spec Traceability**: US1→FR-001/FR-002/FR-004，US2→FR-003，US3→FR-005。
- **CA-002 CLI Contract Impact**: 增加“existing branch recovery”行为，不改变输出字段。
- **CA-003 Test-First Plan**: 先写 branch-exists+missing-specs 失败回归，再实现恢复逻辑。
- **CA-004 Boundary Coverage**: 覆盖 current branch / non-current branch / missing spec file。
- **CA-005 Observability & Versioning**: 输出恢复动作提示；行为修复按 PATCH。

### Key Entities *(include if feature involves data)*

- **BranchRecoveryContext**: 分支存在状态、当前分支、目录/文件存在性。
- **FeatureScaffoldResult**: 分支与 spec 脚手架结果。

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: existing branch + missing specs 场景恢复成功率 100%。
- **SC-002**: existing branch + existing spec 场景无内容覆盖率 100%。
- **SC-003**: JSON 输出字段兼容率 100%。
- **SC-004**: 分支已存在导致的入口失败事件降为 0。
