# Feature Specification: Stabilize Pure JSON Output for setup-plan

**Feature Branch**: `009-setup-plan-json-purity`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Stabilize pure JSON output for setup-plan"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - JSON Mode Emits Parseable JSON Only (Priority: P1)
作为自动化调用者，我希望 `setup-plan.ps1 -Json` 输出可直接 `ConvertFrom-Json`，不混入 ACTION 文本。

**Independent Test**: `-Json` 模式下 stdout 直接解析成功。

### User Story 2 - Text Mode Keeps ACTION (Priority: P2)
作为人工调用者，我希望非 JSON 模式仍显示 ACTION。

**Independent Test**: 非 JSON 模式输出包含 `ACTION:`。

### User Story 3 - Docs & Contract Alignment (Priority: P3)
作为维护者，我希望文档明确 JSON 与文本模式差异。

**Independent Test**: 仅按文档可正确处理两种模式。

## Requirements
- **FR-001**: `-Json` mode MUST emit pure JSON only.
- **FR-002**: JSON fields (`FEATURE_SPEC`,`IMPL_PLAN`,`SPECS_DIR`,`BRANCH`,`HAS_GIT`) MUST remain compatible.
- **FR-003**: non-JSON mode MUST preserve ACTION output.
- **FR-004**: docs/contracts MUST describe mode difference.

## Constitution Alignment *(mandatory)*
- US1→FR-001/FR-002, US2→FR-003, US3→FR-004
- test-first for mixed-output regression
- patch-level change

## Success Criteria
- JSON parse success: 100%
- text ACTION retention: 100%
- field compatibility: 100%
