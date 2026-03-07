# Tasks: Stabilize check-prerequisites Regression Across Branches

**Input**: Design documents from `/specs/012-stabilize-check-prerequisites/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

## Phase 1: Setup
- [x] T001 Create feature docs scaffold in specs/012-stabilize-check-prerequisites/
- [x] T002 [P] Create contract baseline in specs/012-stabilize-check-prerequisites/contracts/regression-context-contract.md

## Phase 2: Foundational
- [x] T003 Define regression context model in specs/012-stabilize-check-prerequisites/data-model.md
- [x] T004 [P] Define decision log in specs/012-stabilize-check-prerequisites/research.md

## Phase 3: User Story 1 - 分支解耦 (P1)
**Independent Test**: Run `tests/check_prerequisites_regression.ps1` on non-004 branch and observe pass.
- [x] T005 [P] [US1] Reproduce failing regression on non-004 branch in tests/check_prerequisites_regression.ps1
- [x] T006 [US1] Bind SPECIFY_FEATURE to stable target in tests/check_prerequisites_regression.ps1
- [x] T007 [US1] Keep missing plan/tasks assertions intact in tests/check_prerequisites_regression.ps1

## Phase 4: User Story 2 - 环境恢复 (P2)
**Independent Test**: Verify SPECIFY_FEATURE is restored after script execution.
- [x] T008 [P] [US2] Preserve prior SPECIFY_FEATURE value in tests/check_prerequisites_regression.ps1
- [x] T009 [US2] Restore SPECIFY_FEATURE in finally block in tests/check_prerequisites_regression.ps1

## Phase 5: User Story 3 - 文档收口 (P3)
**Independent Test**: Docs describe branch-independent strategy and command.
- [x] T010 [P] [US3] Document usage in specs/012-stabilize-check-prerequisites/quickstart.md
- [x] T011 [US3] Document contract rules in specs/012-stabilize-check-prerequisites/contracts/regression-context-contract.md

## Phase 6: Polish
- [x] T012 [P] Run regression validation in tests/check_prerequisites_regression.ps1
- [x] T013 Update release impact in specs/012-stabilize-check-prerequisites/plan.md

## Dependencies
- Phase 1 -> Phase 2 -> Phase 3/4/5 -> Phase 6
- US2 depends on US1 context setup
- US3 depends on validated implementation evidence

## Parallel Opportunities
- T002, T004 can run in parallel
- T005 and documentation draft tasks can run in parallel

## Implementation Strategy
- MVP: complete US1 first to remove branch coupling.
- Incremental: add US2 env restoration guarantees, then US3 documentation.
