# Feature Specification: Normalize Auto Branch Numbering to Three-digit Feature Branches

**Feature Branch**: `010-normalize-branch-numbering`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Normalize auto branch numbering to three-digit feature branches"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ignore Non-standard Branch Numbers (Priority: P1)
作为使用者，我希望自动编号只参考 `###-` 三位分支，避免测试分支（如 8034-xxx）导致编号跳跃。

**Independent Test**: 分支列表含 `010-...` 与 `8034-...` 时，自动编号结果应为 `011`。

### User Story 2 - Preserve Manual Number Behavior (Priority: P2)
作为维护者，我希望 `-Number` 仍保持原优先级和行为。

**Independent Test**: 提供 `-Number 123` 时结果固定为 `123-*`。

### User Story 3 - Document Numbering Rule (Priority: P3)
作为团队成员，我希望文档明确自动编号仅统计三位 feature 前缀。

**Independent Test**: 文档可指导正确预期自动编号结果。

## Requirements
- **FR-001**: Auto-numbering MUST only consider branches/spec dirs matching `^\d{3}-`.
- **FR-002**: Manual `-Number` behavior MUST remain unchanged.
- **FR-003**: Existing branch-name generation semantics MUST remain unchanged.
- **FR-004**: Docs/contracts MUST document the three-digit numbering rule.

## Constitution Alignment *(mandatory)*
- US1→FR-001, US2→FR-002/FR-003, US3→FR-004
- test-first for polluted numbering regression
- patch-level change

## Success Criteria
- polluted numbering regression pass rate 100%
- manual number behavior compatibility 100%
- documentation alignment 100%
