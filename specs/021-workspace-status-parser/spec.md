# Feature Specification: Harden Workspace Recovery with Robust Git Status Parsing

**Feature Branch**: `021-workspace-status-parser`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Harden workspace recovery by robust git status parsing"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - 重命名变更可恢复 (Priority: P1)

作为维护者，我希望工作区恢复逻辑能正确处理 `git status` 中的重命名条目，
避免恢复时漏掉或误处理由子脚本引入的 rename 污染。

**Why this priority**: 这是恢复逻辑正确性的核心边界，直接影响执行后工作区稳定性。

**Independent Test**: 回归脚本制造 tracked 文件重命名污染后，聚合执行结束能恢复为执行前状态。

**Acceptance Scenarios**:

1. **Given** 子脚本把 tracked 文件从 `old.txt` 重命名为 `new.txt`，**When** 聚合执行结束，**Then** 工作区恢复到重命名前状态。
2. **Given** 同时产生 `.bak/.tmp` 临时文件，**When** 执行恢复，**Then** 临时文件被清理且重命名污染被回滚。

---

### User Story 2 - 路径解析兼容复杂格式 (Priority: P2)

作为开发者，我希望状态解析函数能统一处理带空格路径与 `old -> new` 形式，
保证恢复逻辑对不同 porcelain 输出格式都稳定。

**Why this priority**: 这是避免平台/文件名差异导致恢复失效的关键保障。

**Independent Test**: 为解析函数增加覆盖复杂路径格式的回归断言并通过。

**Acceptance Scenarios**:

1. **Given** `git status --porcelain` 输出包含 `R  old -> new`，**When** 解析，**Then** 能提取用于恢复的目标路径。
2. **Given** 输出包含带空格路径，**When** 解析，**Then** 路径不被截断且可被后续 git 命令使用。

---

### User Story 3 - 文档与回归门禁补齐 (Priority: P3)

作为质量维护者，我希望为状态解析增强补充文档门禁与专项回归，
保证后续重构不会回退该能力。

**Why this priority**: 长期稳定依赖自动化门禁而非人工记忆。

**Independent Test**: 新增 status-parser 回归与 docs validator 均通过。

**Acceptance Scenarios**:

1. **Given** 021 文档齐全，**When** 运行 docs validator，**Then** 关键语义全部通过。
2. **Given** 状态解析回归脚本，**When** 执行，**Then** rename 与复杂路径场景均通过。

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- rename 条目中出现 `old name -> new name` 且包含空格时如何解析。
- 路径包含引号或转义字符时，恢复逻辑是否仍可执行。
- 非 git 仓库场景下解析函数不应影响原有执行流程。

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: 聚合脚本 MUST 使用统一状态解析函数处理 porcelain 行。
- **FR-002**: 解析函数 MUST 正确处理 `old -> new` 重命名格式。
- **FR-003**: 解析函数 MUST 保留带空格路径的完整性。
- **FR-004**: 恢复逻辑 MUST 能回滚由 rename 引入的 tracked 污染。
- **FR-005**: 既有 timeout/workspace guard 行为 MUST 保持兼容。
- **FR-006**: MUST 新增 status-parser 专项回归覆盖 rename 场景。
- **FR-007**: MUST 新增 docs validator 校验 021 语义一致性。

## Constitution Alignment *(mandatory)*

<!--
  ACTION REQUIRED: Confirm alignment with constitutional requirements.
  Keep this section concise and concrete.
-->

- **CA-001 Spec Traceability**: US1→FR-001/FR-002/FR-004，US2→FR-003，US3→FR-006/FR-007。
- **CA-002 CLI Contract Impact**: 无新增CLI参数；内部解析与恢复逻辑增强。
- **CA-003 Test-First Plan**: 先补 status-parser 回归与 docs validator，再改主脚本。
- **CA-004 Boundary Coverage**: 覆盖 rename、空格路径、非 git 场景。
- **CA-005 Observability & Versioning**: 维持恢复统计可观测性，语义版本 PATCH。

### Key Entities *(include if feature involves data)*

- **StatusEntry**: 解析后的单条 git 状态项，含 `Code`、`RawPath`、`NormalizedPath`。
- **RecoveryAction**: 恢复动作记录，含 `ActionType`、`Path`、`Succeeded`。

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: rename 污染回归执行后，仓库状态与执行前一致。
- **SC-002**: docs-only 聚合与 JSON 模式继续可解析并通过既有回归。
- **SC-003**: 新增 status-parser 回归与 docs validator 纳入聚合并通过。
- **SC-004**: 不新增任何 breaking 参数或行为变更。
