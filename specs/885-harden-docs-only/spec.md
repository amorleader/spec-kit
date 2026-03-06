# Feature Specification: Harden Docs-Only Aggregate Execution

**Feature Branch**: `885-harden-docs-only`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Harden docs-only aggregate execution"

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

### User Story 1 - docs-only 执行稳定 (Priority: P1)

作为维护者，我希望 `run_all_quality_checks.ps1 -IncludeDocsOnly` 在不同工作区状态下都能稳定完成，
这样文档门禁可以持续作为轻量快速检查入口。

**Why this priority**: docs-only 是高频检查路径，稳定性直接影响交付效率。

**Independent Test**: 针对 docs-only 路径构造回归场景，验证聚合通过且结果字段完整。

**Acceptance Scenarios**:

1. **Given** 文档脚本全部存在，**When** 执行 docs-only，**Then** 返回 `PASSED` 且统计准确。
2. **Given** 工作区存在轻量变化，**When** 执行 docs-only，**Then** 不影响结果聚合与输出稳定。

---

### User Story 2 - docs-only 输出契约稳定 (Priority: P2)

作为自动化调用方，我希望 docs-only 的 JSON/text 输出契约稳定，
这样下游解析逻辑不会因字段漂移而失败。

**Why this priority**: 契约稳定是自动化集成的前提。

**Independent Test**: 校验 docs-only 的 JSON 字段集与文本摘要结构与既有约定兼容。

**Acceptance Scenarios**:

1. **Given** docs-only 模式，**When** 产出 JSON，**Then** 关键字段（如 `TOTAL_SCRIPTS`/`FAILED_SCRIPTS`/`RESULTS`）保持稳定。

---

### User Story 3 - 文档与回归门禁固化 (Priority: P3)

作为协作者，我希望 docs-only 加固方案有专用文档与回归门禁，
这样后续重构不会破坏该路径。

**Why this priority**: 通过门禁长期保护稳定性改进。

**Independent Test**: 新增 docs-only 专项回归与 docs validator 均通过并可纳入聚合。

**Acceptance Scenarios**:

1. **Given** 885 文档完整，**When** 运行 docs validator，**Then** 关键约束条款命中并通过。

---

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- docs validator 数量变化时，`TOTAL_SCRIPTS` 应与实际匹配。
- 单个 docs validator 失败时，聚合状态与失败计数应正确反映。
- docs-only 与全量模式切换时，输出字段兼容性不得漂移。

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: docs-only 模式 MUST 稳定执行所有 `validate_*_docs.ps1` 并正确汇总。
- **FR-002**: docs-only JSON 输出 MUST 保持既有字段与语义兼容。
- **FR-003**: docs-only 文本输出 MUST 保持摘要与计数稳定格式。
- **FR-004**: MUST 新增 docs-only 专项回归脚本覆盖统计与失败传播。
- **FR-005**: MUST 新增 docs validator 校验 885 文档中的 docs-only 加固约束。
- **FR-006**: 变更 MUST 不影响非 docs-only 全量执行路径。

## Constitution Alignment *(mandatory)*

<!--
  ACTION REQUIRED: Confirm alignment with constitutional requirements.
  Keep this section concise and concrete.
-->

- **CA-001 Spec Traceability**: US1→FR-001/FR-004，US2→FR-002/FR-003，US3→FR-005/FR-006。
- **CA-002 CLI Contract Impact**: 不新增参数；稳定 docs-only 既有输出契约。
- **CA-003 Test-First Plan**: 先写 docs-only 回归与 docs validator，再改实现。
- **CA-004 Boundary Coverage**: 覆盖成功/失败 docs validator 计数与结果传播场景。
- **CA-005 Observability & Versioning**: 输出诊断稳定化，版本影响 PATCH。

### Key Entities *(include if feature involves data)*

- **DocsOnlySummary**: docs-only 聚合输出摘要，包含计数与状态字段。
- **DocsOnlyResultItem**: 单个 docs validator 的执行结果项。

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: docs-only 专项回归通过且可稳定复现。
- **SC-002**: docs-only JSON 输出字段在回归中保持 100% 兼容。
- **SC-003**: docs-only docs validator 通过并纳入聚合执行链。
