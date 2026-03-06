# Tasks: Recover Missing Specs Directory for Existing Feature Branch

**Input**: Design documents from `/specs/006-recover-missing-specs/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

## Phase 1: Setup
- [x] T001 Create recovery regression scaffold in tests/create_new_feature_recovery_regression.ps1
- [x] T002 [P] Create fixtures directory in tests/fixtures/create-new-feature-recovery/
- [x] T003 [P] Add base recovery contract notes in specs/006-recover-missing-specs/contracts/create-new-feature-recovery-contract.md

## Phase 2: Foundational
- [x] T004 Add JSON assertion helper for recovery tests in tests/helpers/assert_create_new_feature_json.ps1
- [x] T005 [P] Add recovery workspace helper in tests/helpers/create_new_feature_test_helper.ps1
- [x] T006 [P] Add failure-mode catalog in specs/006-recover-missing-specs/contracts/failure-mode-catalog.md

## Phase 3: User Story 1 (P1)
- [x] T007 [P] [US1] Add failing test for existing-current-branch recovery in tests/create_new_feature_recovery_regression.ps1
- [x] T008 [P] [US1] Add failing test for preserving existing spec.md in tests/create_new_feature_recovery_regression.ps1
- [x] T009 [US1] Implement recovery path for existing current branch in .specify/scripts/powershell/create-new-feature.ps1
- [x] T010 [US1] Preserve existing spec.md when present in .specify/scripts/powershell/create-new-feature.ps1
- [x] T011 [US1] Update recovery success examples in specs/006-recover-missing-specs/contracts/create-new-feature-recovery-contract.md
- [x] T012 [US1] Record US1 evidence in specs/006-recover-missing-specs/contracts/create-new-feature-recovery-contract.md

## Phase 4: User Story 2 (P2)
- [x] T013 [P] [US2] Add failing test for existing non-current branch recovery in tests/create_new_feature_recovery_regression.ps1
- [x] T014 [P] [US2] Add failing test for checkout failure messaging path in tests/create_new_feature_recovery_regression.ps1
- [x] T015 [US2] Implement checkout-and-recover logic for existing non-current branch in .specify/scripts/powershell/create-new-feature.ps1
- [x] T016 [US2] Add deterministic action messaging for recovery modes in .specify/scripts/powershell/create-new-feature.ps1
- [x] T017 [US2] Document non-current branch behavior in specs/006-recover-missing-specs/contracts/failure-mode-catalog.md
- [x] T018 [US2] Record US2 evidence in specs/006-recover-missing-specs/contracts/failure-mode-catalog.md

## Phase 5: User Story 3 (P3)
- [x] T019 [P] [US3] Add docs consistency check script in tests/validate_create_new_feature_recovery_docs.ps1
- [x] T020 [US3] Update quickstart with recovery examples in specs/006-recover-missing-specs/quickstart.md
- [x] T021 [US3] Finalize research decisions in specs/006-recover-missing-specs/research.md
- [x] T022 [US3] Add docs traceability in specs/006-recover-missing-specs/contracts/create-new-feature-recovery-contract.md
- [x] T023 [US3] Add final evidence matrix in specs/006-recover-missing-specs/contracts/create-new-feature-recovery-contract.md

## Phase 6: Polish
- [x] T024 [P] Normalize terminology in specs/006-recover-missing-specs/spec.md
- [x] T025 Run full regression and docs validation, log outputs in specs/006-recover-missing-specs/contracts/create-new-feature-recovery-contract.md
- [x] T026 Update semver impact and release note in specs/006-recover-missing-specs/plan.md
