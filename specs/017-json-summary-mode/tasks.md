# Tasks: Add JSON Summary Mode to Full Quality Check Runner

**Input**: Design documents from `/specs/017-json-summary-mode/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

## Phase 1: Setup
- [x] T001 Create 017 docs scaffold in specs/017-json-summary-mode/
- [x] T002 [P] Create contract baseline in specs/017-json-summary-mode/contracts/json-summary-contract.md

## Phase 2: Foundational
- [x] T003 Define summary schema in specs/017-json-summary-mode/data-model.md
- [x] T004 [P] Capture decisions in specs/017-json-summary-mode/research.md

## Phase 3: User Story 1 - JSON机读汇总 (P1)
**Independent Test**: `-Json -IncludeDocsOnly` returns parseable JSON object.
- [x] T005 [P] [US1] Add Json switch in tests/run_all_quality_checks.ps1
- [x] T006 [US1] Emit structured summary object in tests/run_all_quality_checks.ps1

## Phase 4: User Story 2 - 文本兼容保持 (P2)
**Independent Test**: text mode keeps RUN/PASS/FAIL output.
- [x] T007 [P] [US2] Keep text-mode log blocks in tests/run_all_quality_checks.ps1
- [x] T008 [US2] Preserve text-mode final summary behavior in tests/run_all_quality_checks.ps1

## Phase 5: User Story 3 - JSON纯净输出 (P3)
**Independent Test**: Json mode has no extra text noise.
- [x] T009 [P] [US3] Suppress per-script and restore logs in Json mode in tests/run_all_quality_checks.ps1
- [x] T010 [US3] Keep branch stability checks valid in Json mode in tests/run_all_quality_checks.ps1

## Phase 6: Polish
- [x] T011 [P] Run Json mode validation in tests/run_all_quality_checks.ps1
- [x] T012 [P] Run text mode compatibility validation in tests/run_all_quality_checks.ps1
- [x] T013 Update release impact in specs/017-json-summary-mode/plan.md

## Dependencies
- Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5 -> Phase 6

## Parallel Opportunities
- T002 and T004 can run in parallel
- T011 and T012 can run in parallel

## Implementation Strategy
- MVP: deliver Json summary output (US1).
- Incremental: preserve text compatibility (US2), then enforce pure-json noise-free output (US3).
