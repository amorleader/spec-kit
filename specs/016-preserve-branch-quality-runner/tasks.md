# Tasks: Preserve Current Branch in Full Quality Check Runner

**Input**: Design documents from `/specs/016-preserve-branch-quality-runner/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

## Phase 1: Setup
- [x] T001 Create 016 docs scaffold in specs/016-preserve-branch-quality-runner/
- [x] T002 [P] Create contract baseline in specs/016-preserve-branch-quality-runner/contracts/branch-restore-contract.md

## Phase 2: Foundational
- [x] T003 Define branch snapshot model in specs/016-preserve-branch-quality-runner/data-model.md
- [x] T004 [P] Record decisions in specs/016-preserve-branch-quality-runner/research.md

## Phase 3: User Story 1 - 运行后恢复分支 (P1)
**Independent Test**: Branch before and after runner execution are equal.
- [x] T005 [P] [US1] Capture original branch at runner start in tests/run_all_quality_checks.ps1
- [x] T006 [US1] Add finally-based branch restore flow in tests/run_all_quality_checks.ps1

## Phase 4: User Story 2 - 恢复可观测 (P2)
**Independent Test**: restore success/warning message appears when applicable.
- [x] T007 [P] [US2] Emit restore success message in tests/run_all_quality_checks.ps1
- [x] T008 [US2] Emit restore failure warning in tests/run_all_quality_checks.ps1

## Phase 5: User Story 3 - 契约兼容 (P3)
**Independent Test**: existing runner summary and script execution behavior unchanged.
- [x] T009 [P] [US3] Keep existing discovery and summary contract in tests/run_all_quality_checks.ps1
- [x] T010 [US3] Normalize output handling remains intact in tests/run_all_quality_checks.ps1

## Phase 6: Polish
- [x] T011 [P] Run full runner and assert pass in tests/run_all_quality_checks.ps1
- [x] T012 [P] Validate before/after branch equality using git rev-parse
- [x] T013 Update release impact in specs/016-preserve-branch-quality-runner/plan.md

## Dependencies
- Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5 -> Phase 6

## Parallel Opportunities
- T002 and T004 can run in parallel
- T007 and T009 can run in parallel

## Implementation Strategy
- MVP: ensure branch is restored (US1).
- Incremental: add observability (US2), then verify compatibility (US3).
