# Tasks: Allow check-prerequisites PathsOnly on Non-feature Branches

**Input**: Design documents from `/specs/007-allow-check-prerequisites/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

## Phase 1: Setup
- [x] T001 Create regression script in tests/check_prerequisites_paths_only_regression.ps1
- [x] T002 [P] Create fixtures directory in tests/fixtures/check-prerequisites-paths-only/
- [x] T003 [P] Add base PathsOnly contract in specs/007-allow-check-prerequisites/contracts/paths-only-contract.md

## Phase 2: Foundational
- [x] T004 Add helper for temporary branch workspace in tests/helpers/check_prerequisites_paths_only_helper.ps1
- [x] T005 [P] Add docs consistency checker in tests/validate_check_prerequisites_paths_only_docs.ps1
- [x] T006 [P] Add failure-mode catalog in specs/007-allow-check-prerequisites/contracts/failure-mode-catalog.md

## Phase 3: User Story 1 (P1)
- [x] T007 [P] [US1] Add failing test for PathsOnly JSON on non-feature branch in tests/check_prerequisites_paths_only_regression.ps1
- [x] T008 [P] [US1] Add failing test for PathsOnly text mode on non-feature branch in tests/check_prerequisites_paths_only_regression.ps1
- [x] T009 [US1] Bypass branch validation when PathsOnly is set in .specify/scripts/powershell/check-prerequisites.ps1
- [x] T010 [US1] Keep PathsOnly output fields stable in .specify/scripts/powershell/check-prerequisites.ps1
- [x] T011 [US1] Update contract examples in specs/007-allow-check-prerequisites/contracts/paths-only-contract.md
- [x] T012 [US1] Record US1 evidence in specs/007-allow-check-prerequisites/contracts/paths-only-contract.md

## Phase 4: User Story 2 (P2)
- [x] T013 [P] [US2] Add failing test for normal-mode failure on non-feature branch in tests/check_prerequisites_paths_only_regression.ps1
- [x] T014 [P] [US2] Add failing test for require-tasks semantics unchanged in tests/check_prerequisites_paths_only_regression.ps1
- [x] T015 [US2] Preserve normal-mode branch validation behavior in .specify/scripts/powershell/check-prerequisites.ps1
- [x] T016 [US2] Preserve non-zero failure signaling in .specify/scripts/powershell/check-prerequisites.ps1
- [x] T017 [US2] Document unchanged normal-mode behavior in specs/007-allow-check-prerequisites/contracts/failure-mode-catalog.md
- [x] T018 [US2] Record US2 evidence in specs/007-allow-check-prerequisites/contracts/failure-mode-catalog.md

## Phase 5: User Story 3 (P3)
- [x] T019 [P] [US3] Add docs consistency checks in tests/validate_check_prerequisites_paths_only_docs.ps1
- [x] T020 [US3] Update quickstart with mode-difference examples in specs/007-allow-check-prerequisites/quickstart.md
- [x] T021 [US3] Finalize research decisions in specs/007-allow-check-prerequisites/research.md
- [x] T022 [US3] Add docs traceability in specs/007-allow-check-prerequisites/contracts/paths-only-contract.md
- [x] T023 [US3] Add final evidence matrix in specs/007-allow-check-prerequisites/contracts/paths-only-contract.md

## Phase 6: Polish
- [x] T024 [P] Normalize terminology in specs/007-allow-check-prerequisites/spec.md
- [x] T025 Run regression and docs checks; log outputs in specs/007-allow-check-prerequisites/contracts/paths-only-contract.md
- [x] T026 Update semver impact in specs/007-allow-check-prerequisites/plan.md
