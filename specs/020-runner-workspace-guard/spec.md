# Feature Specification: Protect Workspace Cleanliness After Quality Runner Execution

**Feature Branch**: `020-runner-workspace-guard`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Protect workspace cleanliness after quality runner execution"

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

### User Story 1 - 执行后保持工作区干净 (Priority: P1)

作为维护者，我希望 `run_all_quality_checks.ps1` 执行后不留下临时文件或意外修改，
以便可以直接继续开发或提交，而不需要手工清理。

**Why this priority**: 这是质量聚合脚本的基础可用性要求，直接影响日常使用体验与CI稳定性。

**Independent Test**: 在干净仓库执行聚合脚本后，`git status --short` 仍为空。

**Acceptance Scenarios**:

1. **Given** 执行前仓库干净，**When** 运行聚合脚本，**Then** 执行后仓库保持干净。
2. **Given** 某个子脚本产生新的 `.bak/.tmp` 文件，**When** 聚合脚本结束，**Then** 新增临时文件会被自动清理。

---

### User Story 2 - 不破坏已有未提交改动 (Priority: P2)

作为开发者，我希望清理逻辑只处理由聚合执行新增的污染，不覆盖我原本就存在的本地改动。

**Why this priority**: 需要在自动清理和数据安全之间取得平衡，避免误回滚开发中代码。

**Independent Test**: 在有预置未提交改动的仓库中运行聚合脚本，预置改动保持不变。

**Acceptance Scenarios**:

1. **Given** 运行前已有 tracked/untracked 改动，**When** 执行聚合脚本，**Then** 这些改动不会被恢复或删除。

---

### User Story 3 - 文档与回归门禁覆盖 (Priority: P3)

作为质量维护者，我希望新增工作区防污染能力有明确文档和回归覆盖，避免后续回归。

**Why this priority**: 长期可维护性依赖自动化门禁，而不是手工约定。

**Independent Test**: 新增回归与docs validator通过，并可被聚合脚本包含执行。

**Acceptance Scenarios**:

1. **Given** 020 文档齐全，**When** 运行 docs validator，**Then** 关键语义校验通过。
2. **Given** 工作区防污染回归脚本，**When** 执行回归，**Then** 能稳定验证“清理新增污染且不伤已有改动”。

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- 没有 git 仓库时，聚合脚本仍能执行但跳过工作区恢复逻辑。
- 文件名包含空格或特殊字符（如 `plan.md.us1.bak`）时清理逻辑仍正确。
- 子脚本在执行中修改 tracked 文件且退出失败时，恢复逻辑仍应执行。

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: 聚合脚本 MUST 在每个子脚本执行前后采集工作区状态快照。
- **FR-002**: 聚合脚本 MUST 仅恢复本次执行新增的 tracked 修改，并仅删除本次新增的临时文件（`.bak`/`.tmp`）。
- **FR-003**: 聚合脚本 MUST 不改变执行前已存在的本地改动（tracked/untracked）。
- **FR-004**: 文本输出 MUST 在发生自动恢复时给出可读诊断信息。
- **FR-005**: `-Json` 输出 MUST 增量包含恢复统计字段并保持既有字段兼容。
- **FR-006**: MUST 新增回归脚本覆盖“污染被清理”和“已有改动保留”场景。
- **FR-007**: MUST 新增 docs validator 校验 020 文档语义与契约一致性。

## Constitution Alignment *(mandatory)*

<!--
  ACTION REQUIRED: Confirm alignment with constitutional requirements.
  Keep this section concise and concrete.
-->

- **CA-001 Spec Traceability**: US1→FR-001/FR-002/FR-004，US2→FR-003，US3→FR-006/FR-007。
- **CA-002 CLI Contract Impact**: 无新增参数；文本/JSON仅增加恢复诊断与统计字段。
- **CA-003 Test-First Plan**: 先新增 workspace-guard 回归和 docs validator，再修改聚合脚本。
- **CA-004 Boundary Coverage**: 覆盖 git/non-git、已有改动、临时文件与tracked文件恢复场景。
- **CA-005 Observability & Versioning**: 增加恢复统计可观测性，语义版本 PATCH。

### Key Entities *(include if feature involves data)*

- **WorkspaceSnapshot**: 单次脚本执行前/后的 git 状态集合。
- **WorkspaceRecoverySummary**: 恢复统计（恢复 tracked 数、删除临时文件数、跳过项）。

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: 干净工作区下执行聚合后 `git status --short` 为空。
- **SC-002**: 回归脚本可稳定验证临时污染自动清理与既有改动保留。
- **SC-003**: docs-only 与 JSON 模式在新增统计字段下保持可解析兼容。
- **SC-004**: 新增回归与docs validator可纳入主聚合并通过。
