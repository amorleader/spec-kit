# Tasks: Fix Checkout Exit Code Detection in create-new-feature

**Input**: Design documents from `/specs/013-fix-checkout-exitcode-detection/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

## Phase 1: Setup
- [x] T001 Create feature docs scaffold in specs/013-fix-checkout-exitcode-detection/
- [x] T002 [P] Create contract baseline in specs/013-fix-checkout-exitcode-detection/contracts/checkout-recovery-contract.md

## Phase 2: Foundational
- [x] T003 Define checkout recovery state model in specs/013-fix-checkout-exitcode-detection/data-model.md
- [x] T004 [P] Capture root-cause decisions in specs/013-fix-checkout-exitcode-detection/research.md

## Phase 3: User Story 1 - 恢复成功判定修复 (P1)
**Independent Test**: `tests/create_new_feature_recovery_regression.ps1` non-current recovery path passes.
- [x] T005 [P] [US1] Reproduce failing non-current recovery case in tests/create_new_feature_recovery_regression.ps1
- [x] T006 [US1] Use local EAP scope and explicit exit-code capture in .specify/scripts/powershell/create-new-feature.ps1
- [x] T007 [US1] Preserve recovered action semantics in .specify/scripts/powershell/create-new-feature.ps1

## Phase 4: User Story 2 - 失败路径保持 (P2)
**Independent Test**: injected checkout failure returns non-zero.
- [x] T008 [P] [US2] Revalidate checkout-failure assertion in tests/create_new_feature_recovery_regression.ps1
- [x] T009 [US2] Keep actionable checkout failure message in .specify/scripts/powershell/create-new-feature.ps1

## Phase 5: User Story 3 - 回归注入同步 (P3)
**Independent Test**: failure injection pattern still matches current implementation.
- [x] T010 [P] [US3] Update injection replacement pattern in tests/create_new_feature_recovery_regression.ps1
- [x] T011 [US3] Document injection-target expression in specs/013-fix-checkout-exitcode-detection/contracts/checkout-recovery-contract.md

## Phase 6: Polish
- [x] T012 [P] Run recovery regression in tests/create_new_feature_recovery_regression.ps1
- [x] T013 [P] Run safety regressions in tests/create_new_feature_regression.ps1
- [x] T014 [P] Run JSON-output regression in tests/create_new_feature_json_output_regression.ps1
- [x] T015 Update release impact in specs/013-fix-checkout-exitcode-detection/plan.md

## Dependencies
- Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5 -> Phase 6

## Parallel Opportunities
- T002 + T004 can run in parallel.
- T012/T013/T014 can run in parallel after implementation.

## Implementation Strategy
- MVP first: complete US1 to remove false failure on recovery path.
- Incremental: lock failure-path semantics (US2), then sync test-injection contract (US3).
