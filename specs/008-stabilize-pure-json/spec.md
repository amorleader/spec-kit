# Feature Specification: Stabilize Pure JSON Output for create-new-feature

**Feature Branch**: `008-stabilize-pure-json`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Stabilize pure JSON output for create-new-feature"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - JSON Mode Emits Parseable JSON Only (Priority: P1)
作为自动化调用者，我希望 `create-new-feature.ps1 -Json` 输出可直接 `ConvertFrom-Json`，不混入额外文本行。

**Independent Test**: 调用 `-Json` 后整段 stdout 可直接解析为单个 JSON 对象。

### User Story 2 - Non-JSON Mode Keeps Action Messaging (Priority: P2)
作为人工调用者，我希望普通模式继续显示 ACTION 提示和字段输出，不丢可读性。

**Independent Test**: 不带 `-Json` 调用仍包含 deterministic 的 ACTION 与键值文本行。

### User Story 3 - Contract & Docs Alignment (Priority: P3)
作为维护者，我希望 contract/quickstart 明确 JSON 与文本模式输出差异。

**Independent Test**: 仅按文档可写出稳定解析脚本。

## Requirements
- **FR-001**: `-Json` mode MUST emit pure JSON only.
- **FR-002**: JSON fields (`BRANCH_NAME`,`SPEC_FILE`,`FEATURE_NUM`,`HAS_GIT`) MUST remain compatible.
- **FR-003**: non-JSON mode MUST preserve ACTION and text output behavior.
- **FR-004**: docs/contracts MUST describe mode differences.

## Constitution Alignment *(mandatory)*
- US1→FR-001/FR-002, US2→FR-003, US3→FR-004
- Test-first for mixed output regression
- PATCH-level change

## Success Criteria
- `-Json` parse success rate: 100%
- non-JSON action output retention: 100%
- contract compatibility: 100%
