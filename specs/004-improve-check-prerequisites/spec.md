# Feature Specification: Improve check-prerequisites Output Consistency

**Feature Branch**: `004-improve-check-prerequisites`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Improve check-prerequisites output consistency"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Stable JSON Contract (Priority: P1)

作为脚本调用者，我希望 `check-prerequisites.ps1 -Json` 在不同仓库状态下都返回稳定字段和一致语义，避免自动化解析失败。

**Why this priority**: 这是所有后续自动化步骤的基础契约，破坏会直接导致流水线中断。

**Independent Test**: 在 git 仓库和非 git 场景执行默认模式 `-Json`，字段集合与类型一致，解析脚本无需分支逻辑。

**Acceptance Scenarios**:

1. **Given** 在 git 仓库内执行 `-Json`, **When** 命令成功返回, **Then** 输出包含约定字段且可直接反序列化。
2. **Given** 在非 git 场景执行 `-Json`, **When** 命令成功返回, **Then** 输出仍包含相同字段并给出可预期默认值。

---

### User Story 2 - Predictable Error Signaling (Priority: P2)

作为维护者，我希望缺失必要文件时有明确错误消息与退出码，便于快速定位和失败处理。

**Why this priority**: 明确失败信号能降低排障成本，防止误判为成功。

**Independent Test**: 触发缺失文件场景时，退出码 non-zero 且 stderr 提示包含缺失项。

**Acceptance Scenarios**:

1. **Given** 必需文档缺失, **When** 执行检查命令, **Then** 返回非 0 退出码并输出可操作错误。

---

### User Story 3 - Documentation Alignment (Priority: P3)

作为团队成员，我希望契约文档与脚本实际输出保持一致，避免示例与行为偏离。

**Why this priority**: 文档一致性是交接与长期维护的关键，但依赖行为先稳定。

**Independent Test**: 仅根据文档即可编写通过的解析脚本。

**Acceptance Scenarios**:

1. **Given** 阅读 contract/quickstart, **When** 按文档解析输出, **Then** 行为与文档一致。

---

### Edge Cases

- 路径包含空格或非 ASCII 字符时，JSON 字符串应保持合法且可解析。
- `-RequireTasks` 与 `-IncludeTasks` 组合下，缺失任务文件应返回一致的 non-zero 失败格式。
- 可选文档全部缺失时，`AVAILABLE_DOCS` 应返回空数组而非 null。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `check-prerequisites.ps1 -Json` MUST return a stable top-level field set across supported scenarios.
- **FR-002**: `AVAILABLE_DOCS` MUST always be an array (possibly empty), never null.
- **FR-003**: Failure cases MUST use non-zero exit code and actionable error messages.
- **FR-004**: `-RequireTasks` behavior MUST be deterministic with `-IncludeTasks` output.
- **FR-005**: Documentation/contracts MUST match real command output and error semantics.

## Constitution Alignment *(mandatory)*

- **CA-001 Spec Traceability**: US1→FR-001/FR-002，US2→FR-003/FR-004，US3→FR-005。
- **CA-002 CLI Contract Impact**: 明确 `check-prerequisites.ps1` 的 JSON 字段与失败语义契约。
- **CA-003 Test-First Plan**: 先写失败回归（字段漂移/错误码不一致）再实现。
- **CA-004 Boundary Coverage**: 覆盖 git/non-git、可选文档缺失、tasks 组合参数边界。
- **CA-005 Observability & Versioning**: 输出需可诊断；若仅兼容性修复则按 PATCH 处理。

### Key Entities *(include if feature involves data)*

- **PrerequisiteResult**: 一次检查的结构化输出（字段、状态、错误信息）。
- **DocumentAvailability**: 可选文档可用性集合及其来源路径。

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 在定义场景集合中，JSON 字段集合一致率达到 100%。
- **SC-002**: 失败场景退出码正确率达到 100%。
- **SC-003**: 根据文档编写的解析脚本在 CI 中一次通过率达到 100%。
- **SC-004**: 因输出不一致导致的回归失败降为 0。
