# Feature Specification: Use Porcelain-Z Parser for Workspace Status Recovery

**Feature Branch**: `022-status-parser-zmode`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Use porcelain-z parser for workspace status recovery"

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

### User Story 1 - 解析重命名与特殊文件名 (Priority: P1)

作为维护者，我希望工作区快照基于 `git status --porcelain -z` 解析，
这样即使文件名包含 ` -> ` 或空格，也能稳定识别 rename 变更并正确恢复。

**Why this priority**: 这是恢复逻辑正确性的根基，直接影响自动清理是否可靠。

**Independent Test**: 在临时仓中构造带 ` -> ` 的重命名文件名，运行聚合脚本后状态恢复为执行前状态。

**Acceptance Scenarios**:

1. **Given** 文件名包含 ` -> `，**When** 子脚本执行 `git mv`，**Then** 恢复逻辑能正确回滚 rename。
2. **Given** rename 与临时文件同时出现，**When** 聚合完成，**Then** tracked 恢复和临时文件清理都成功。

---

### User Story 2 - 保持现有输出兼容 (Priority: P2)

作为调用方，我希望切换到 `-z` 解析后，聚合输出字段与失败语义保持兼容。

**Why this priority**: 能力增强不能破坏既有自动化消费。

**Independent Test**: 运行 `-Json -IncludeDocsOnly`，检查既有字段仍存在并可解析。

**Acceptance Scenarios**:

1. **Given** docs-only 模式，**When** 输出 JSON，**Then** 既有字段保持不变，新增行为不引入破坏。

---

### User Story 3 - 文档与回归门禁 (Priority: P3)

作为质量维护者，我希望 `-z` 解析方案有独立回归与文档校验，避免后续回归。

**Why this priority**: 需要把解析约束固化在自动化门禁中。

**Independent Test**: 新增回归脚本和 docs validator 均通过。

**Acceptance Scenarios**:

1. **Given** 022 文档存在，**When** 执行 docs validator，**Then** 关键语义检查通过。
2. **Given** `-z` 解析回归脚本，**When** 执行回归，**Then** rename 特殊路径场景稳定通过。

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- `git status --porcelain -z` 输出为空时，快照应返回空集合。
- 非 git 仓库时，快照解析应安全退化，不影响主流程。
- 路径含空格、引号、`->` 时，解析结果应保持准确。

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: 快照解析 MUST 使用 `git status --porcelain -z` 并按 NUL 分隔解析条目。
- **FR-002**: 对 rename/copy 条目 MUST 解析出 old/new 两个路径用于恢复判断。
- **FR-003**: 文件名包含 ` -> `、空格时，恢复逻辑 MUST 保持正确。
- **FR-004**: 切换解析方案后，`run_all_quality_checks.ps1` 既有 JSON 顶层字段 MUST 保持兼容。
- **FR-005**: MUST 新增 status parser z-mode 回归脚本覆盖特殊路径 rename。
- **FR-006**: MUST 新增 docs validator 校验 spec/quickstart/contract 的 z-mode 语义。

## Constitution Alignment *(mandatory)*

<!--
  ACTION REQUIRED: Confirm alignment with constitutional requirements.
  Keep this section concise and concrete.
-->

- **CA-001 Spec Traceability**: US1→FR-001/FR-002/FR-003，US2→FR-004，US3→FR-005/FR-006。
- **CA-002 CLI Contract Impact**: 无新增参数；仅内部解析策略升级。
- **CA-003 Test-First Plan**: 先写 z-mode 回归与 docs validator，再改解析函数。
- **CA-004 Boundary Coverage**: 覆盖 rename 双路径、特殊字符路径、空输出场景。
- **CA-005 Observability & Versioning**: 输出语义保持兼容，版本影响 PATCH。

### Key Entities *(include if feature involves data)*

- **PorcelainZEntry**: 一条 `-z` 状态记录，包含状态码与 1~2 个路径。
- **WorkspaceSnapshot**: 由 `PorcelainZEntry` 汇总得到的 tracked/untracked 路径集合。

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: z-mode 回归脚本在 rename 特殊路径场景通过。
- **SC-002**: docs-only JSON 聚合保持可解析且字段兼容。
- **SC-003**: 新增 docs validator 通过并纳入聚合执行。
