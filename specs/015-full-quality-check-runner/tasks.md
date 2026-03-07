# Tasks: Add Full Quality Check Runner

**Input**: Design documents from `/specs/015-full-quality-check-runner/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

## Phase 1: Setup
- [x] T001 Create 015 docs scaffold in specs/015-full-quality-check-runner/
- [x] T002 [P] Create contract baseline in specs/015-full-quality-check-runner/contracts/quality-check-runner-contract.md

## Phase 2: Foundational
- [x] T003 Define aggregate result model in specs/015-full-quality-check-runner/data-model.md
- [x] T004 [P] Record implementation decisions in specs/015-full-quality-check-runner/research.md

## Phase 3: User Story 1 - 一键全量回归 (P1)
**Independent Test**: Runner executes all `*_regression.ps1` scripts.
- [x] T005 [P] [US1] Add regression discovery logic in tests/run_all_quality_checks.ps1
- [x] T006 [US1] Add RUN/PASS/FAIL output blocks in tests/run_all_quality_checks.ps1

## Phase 4: User Story 2 - 一键文档校验 (P2)
**Independent Test**: Runner executes all `validate_*_docs.ps1` scripts.
- [x] T007 [P] [US2] Add docs-check discovery logic in tests/run_all_quality_checks.ps1
- [x] T008 [US2] Add IncludeDocsOnly mode in tests/run_all_quality_checks.ps1

## Phase 5: User Story 3 - 汇总与可诊断输出 (P3)
**Independent Test**: Failure list and non-zero exit code appear when any script fails.
- [x] T009 [P] [US3] Add failure aggregation with script name and exit code in tests/run_all_quality_checks.ps1
- [x] T010 [US3] Normalize output objects to text in tests/run_all_quality_checks.ps1

## Phase 6: Polish
- [x] T011 [P] Run full runner in tests/run_all_quality_checks.ps1
- [x] T012 Update quickstart usage in specs/015-full-quality-check-runner/quickstart.md
- [x] T013 Update release impact in specs/015-full-quality-check-runner/plan.md

## Dependencies
- Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5 -> Phase 6

## Parallel Opportunities
- T002 and T004 can run in parallel
- T005 and T007 can run in parallel

## Implementation Strategy
- MVP first: make regression discovery/execution work (US1).
- Incremental: add docs-only flow (US2), then polish summary quality (US3).
