# Feature Specification: Add Regression Coverage for Full Quality Runner

**Feature Branch**: `018-quality-runner-regression-coverage`  
**Created**: 2026-03-06  
**Status**: Draft

## User Scenarios & Testing

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

### User Story 1 - JSON 汇总回归 (Priority: P1)

作为维护者，我希望有独立回归脚本验证 `run_all_quality_checks -Json` 的字段与可解析性，
以便后续重构不会破坏机读契约。

**Independent Test**: 运行 `tests/run_all_quality_checks_regression.ps1` 的 US1 用例通过。

**Acceptance Scenarios**:
1. **Given** JSON 模式，**When** 执行 runner，**Then** 输出是可解析 JSON 且字段齐全。

---

### User Story 2 - 文本模式兼容回归 (Priority: P2)

作为开发者，我希望回归脚本继续验证文本模式 `RUN/PASS/summary`，
确保新增 JSON 能力不会破坏原有人工可读输出。

**Independent Test**: 同一回归脚本的 US2 用例通过。

**Acceptance Scenarios**:
1. **Given** 文本模式，**When** 执行 runner，**Then** 输出仍包含 RUN/PASS 与 PASSED 总结。

---

### User Story 3 - 文档门禁补齐 (Priority: P3)

作为文档维护者，我希望新增 runner 回归对应的文档校验脚本，
确保 spec/quickstart/contract 描述一致。

**Independent Test**: `tests/validate_run_all_quality_checks_docs.ps1` 通过。

**Acceptance Scenarios**:
1. **Given** 018 文档存在，**When** 执行 docs validator，**Then** 关键语义检查全部通过。

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

- docs-only 模式下新增 validator 也会被 runner 执行，文档缺失应明确失败。
- 回归脚本执行前后分支应保持稳定。

## Requirements

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: 增加 `tests/run_all_quality_checks_regression.ps1` 覆盖 JSON/文本/分支稳定三类断言。
- **FR-002**: 增加 `tests/helpers/assert_run_all_quality_checks_json.ps1` 校验 JSON 字段契约。
- **FR-003**: 增加 `tests/validate_run_all_quality_checks_docs.ps1` 校验 018 文档语义。
- **FR-004**: 不改动 `tests/run_all_quality_checks.ps1` 的输出行为。

## Constitution Alignment

<!--
  ACTION REQUIRED: Confirm alignment with constitutional requirements.
  Keep this section concise and concrete.
-->

- **CA-001**: US1→FR-001/FR-002，US2→FR-001，US3→FR-003。
- **CA-002**: 仅测试与文档资产变更，无生产 CLI 变更。
- **CA-003**: 先运行新增回归（缺文档失败），再补文档并通过。
- **CA-004**: 覆盖 JSON 契约边界与 docs-only 执行边界。
- **CA-005**: SemVer PATCH。

## Success Criteria

- **SC-001**: `tests/run_all_quality_checks_regression.ps1` 通过。
- **SC-002**: `tests/validate_run_all_quality_checks_docs.ps1` 通过。
- **SC-003**: 现有 `tests/run_all_quality_checks.ps1 -IncludeDocsOnly` 仍通过。
