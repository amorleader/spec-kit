# Tasks: Normalize Auto Branch Numbering to Three-digit Feature Branches

## Phase 1: Setup
- [x] T001 Create regression script in tests/create_new_feature_numbering_regression.ps1
- [x] T002 [P] Create fixtures dir in tests/fixtures/create-new-feature-numbering/
- [x] T003 [P] Add base numbering contract in specs/010-normalize-branch-numbering/contracts/numbering-contract.md

## Phase 2: Foundational
- [x] T004 Add helper for numbering test workspace in tests/helpers/create_new_feature_numbering_helper.ps1
- [x] T005 [P] Add docs consistency checker in tests/validate_create_new_feature_numbering_docs.ps1
- [x] T006 [P] Add failure-mode catalog in specs/010-normalize-branch-numbering/contracts/failure-mode-catalog.md

## Phase 3: US1
- [x] T007 [P] [US1] Add failing test for polluted branch list in tests/create_new_feature_numbering_regression.ps1
- [x] T008 [P] [US1] Add failing test for polluted specs dir list in tests/create_new_feature_numbering_regression.ps1
- [x] T009 [US1] Restrict branch-number regex to three digits in .specify/scripts/powershell/create-new-feature.ps1
- [x] T010 [US1] Restrict specs-dir-number regex to three digits in .specify/scripts/powershell/create-new-feature.ps1
- [x] T011 [US1] Update contract examples in specs/010-normalize-branch-numbering/contracts/numbering-contract.md
- [x] T012 [US1] Record US1 evidence in specs/010-normalize-branch-numbering/contracts/numbering-contract.md

## Phase 4: US2
- [x] T013 [P] [US2] Add failing test for manual number override in tests/create_new_feature_numbering_regression.ps1
- [x] T014 [P] [US2] Add failing test for branch suffix stability in tests/create_new_feature_numbering_regression.ps1
- [x] T015 [US2] Preserve manual -Number precedence in .specify/scripts/powershell/create-new-feature.ps1
- [x] T016 [US2] Preserve suffix generation behavior in .specify/scripts/powershell/create-new-feature.ps1
- [x] T017 [US2] Document compatibility guarantees in specs/010-normalize-branch-numbering/contracts/failure-mode-catalog.md
- [x] T018 [US2] Record US2 evidence in specs/010-normalize-branch-numbering/contracts/failure-mode-catalog.md

## Phase 5: US3
- [x] T019 [P] [US3] Add docs consistency checks in tests/validate_create_new_feature_numbering_docs.ps1
- [x] T020 [US3] Update quickstart examples in specs/010-normalize-branch-numbering/quickstart.md
- [x] T021 [US3] Finalize research decisions in specs/010-normalize-branch-numbering/research.md
- [x] T022 [US3] Add docs traceability in specs/010-normalize-branch-numbering/contracts/numbering-contract.md
- [x] T023 [US3] Add final evidence matrix in specs/010-normalize-branch-numbering/contracts/numbering-contract.md

## Phase 6: Polish
- [x] T024 [P] Normalize terminology in specs/010-normalize-branch-numbering/spec.md
- [x] T025 Run regression/docs checks and log outputs in specs/010-normalize-branch-numbering/contracts/numbering-contract.md
- [x] T026 Update semver impact in specs/010-normalize-branch-numbering/plan.md
