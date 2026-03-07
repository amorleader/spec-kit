# Feature Specification: Stabilize Text Output Check Behavior

**Feature Branch**: `884-stabilize-text-output`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Stabilize text output check behavior"

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

### User Story 1 - 文本模式输出稳定 (Priority: P1)

作为脚本调用方，我希望非 `-Json` 模式下的输出结构稳定且可预测，
这样终端用户和日志采集都能持续得到一致文本格式。

**Why this priority**: 文本模式是人工排障入口，稳定性直接影响可诊断性。

**Independent Test**: 运行文本模式回归脚本，验证关键标题行/键值行格式一致，且不出现意外前缀或错序。

**Acceptance Scenarios**:

1. **Given** 成功路径，**When** 以文本模式运行，**Then** 输出包含稳定的关键字段行。
2. **Given** 失败路径，**When** 以文本模式运行，**Then** 输出包含可操作提示且格式不漂移。

---

### User Story 2 - 文本错误提示一致 (Priority: P2)

作为维护者，我希望相关脚本在文本模式失败时给出一致提示语义，
这样用户不需要记忆不同脚本的不同错误文案结构。

**Why this priority**: 错误提示一致化降低支持与排障成本。

**Independent Test**: 在多个脚本触发失败路径，验证错误标题和提示行模式一致。

**Acceptance Scenarios**:

1. **Given** 脚本失败，**When** 输出文本，**Then** 错误信息包含统一前缀与下一步提示。

---

### User Story 3 - 文档与门禁固化 (Priority: P3)

作为协作者，我希望文本输出约束被文档化并加入自动化门禁，
这样后续改动不会引入格式回退。

**Why this priority**: 通过文档 + validator 防止回归。

**Independent Test**: docs validator 与文本输出回归通过，并纳入聚合执行。

**Acceptance Scenarios**:

1. **Given** 文档完整，**When** 执行 docs validator，**Then** 文本输出约束条款全部命中。

---

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- 文本输出中出现额外空行、调试前缀或顺序漂移时，应被回归捕获。
- 缺失 feature 目录、非 feature 分支等失败路径应保留可操作提示。
- 文本模式与 `-Json` 模式之间输出语义不得相互污染。

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: `check-prerequisites.ps1` 文本模式 MUST 保持关键输出行格式稳定。
- **FR-002**: `setup-plan.ps1` 文本模式 MUST 保持 `ACTION` 与路径字段格式稳定。
- **FR-003**: `create-new-feature.ps1` 文本模式 MUST 保持摘要字段输出顺序与结构稳定。
- **FR-004**: 三脚本文本失败路径 MUST 提供一致错误提示语义。
- **FR-005**: MUST 新增文本输出回归脚本覆盖成功与失败路径。
- **FR-006**: MUST 新增 docs validator 校验文本输出约束文档条款。

## Constitution Alignment *(mandatory)*

<!--
  ACTION REQUIRED: Confirm alignment with constitutional requirements.
  Keep this section concise and concrete.
-->

- **CA-001 Spec Traceability**: US1→FR-001/FR-002/FR-003，US2→FR-004，US3→FR-005/FR-006。
- **CA-002 CLI Contract Impact**: 无新增参数；仅稳定文本模式格式与提示语义。
- **CA-003 Test-First Plan**: 先写文本输出回归与 docs validator，再改脚本输出。
- **CA-004 Boundary Coverage**: 覆盖成功/失败文本输出、分支校验失败、缺失文档场景。
- **CA-005 Observability & Versioning**: 输出稳定性增强，版本影响 PATCH。

### Key Entities *(include if feature involves data)*

- **TextOutputLineSet**: 文本模式输出行集合，包含顺序与关键字段。
- **TextErrorHint**: 文本错误提示对象（前缀、消息、下一步建议）。

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: 文本输出回归脚本在成功/失败场景 100% 通过。
- **SC-002**: docs-only 聚合包含文本输出 docs validator 且通过。
- **SC-003**: 三脚本文本关键字段行顺序与标签在回归中保持稳定。
