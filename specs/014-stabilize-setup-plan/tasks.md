# Tasks: Stabilize setup-plan Regression Mode Expectations

**Input**: Design documents from `/specs/014-stabilize-setup-plan/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

## Phase 1: Setup
- [x] T001 Create 014 docs scaffold in specs/014-stabilize-setup-plan/
- [x] T002 [P] Create contract baseline in specs/014-stabilize-setup-plan/contracts/setup-plan-regression-contract.md

## Phase 2: Foundational
- [x] T003 Define invocation-mode model in specs/014-stabilize-setup-plan/data-model.md
- [x] T004 [P] Capture decision log in specs/014-stabilize-setup-plan/research.md

## Phase 3: User Story 1 - 文本断言对齐文本模式 (P1)
**Independent Test**: `tests/setup_plan_regression.ps1` action assertions pass.
- [x] T005 [P] [US1] Reproduce action assertion failures in tests/setup_plan_regression.ps1
- [x] T006 [US1] Add JsonMode switch to invocation helper in tests/setup_plan_regression.ps1
- [x] T007 [US1] Keep ACTION checks on text-mode calls in tests/setup_plan_regression.ps1

## Phase 4: User Story 2 - JSON断言独立验证 (P2)
**Independent Test**: JSON field checks pass via explicit -Json calls.
- [x] T008 [P] [US2] Add dedicated JSON invocation per scenario in tests/setup_plan_regression.ps1
- [x] T009 [US2] Preserve required JSON field assertions in tests/setup_plan_regression.ps1

## Phase 5: User Story 3 - 无副作用保障 (P3)
**Independent Test**: setup_plan_json_output_regression still passes.
- [x] T010 [P] [US3] Run setup_plan_json_output_regression in tests/setup_plan_json_output_regression.ps1
- [x] T011 [US3] Document mode expectations in specs/014-stabilize-setup-plan/contracts/setup-plan-regression-contract.md

## Phase 6: Polish
- [x] T012 [P] Run setup_plan_regression in tests/setup_plan_regression.ps1
- [x] T013 [P] Run setup_plan_json_output_regression in tests/setup_plan_json_output_regression.ps1
- [x] T014 Update release impact in specs/014-stabilize-setup-plan/plan.md

## Dependencies
- Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5 -> Phase 6

## Parallel Opportunities
- T002 and T004 can run in parallel.
- T012 and T013 can run in parallel.

## Implementation Strategy
- MVP first: fix US1 to clear failing action assertions.
- Incremental: separate JSON validations (US2), then validate no side effects (US3).
