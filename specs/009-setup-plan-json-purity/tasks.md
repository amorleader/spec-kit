# Tasks: Stabilize Pure JSON Output for setup-plan

## Phase 1: Setup
- [x] T001 Create regression script in tests/setup_plan_json_output_regression.ps1
- [x] T002 [P] Create fixtures directory in tests/fixtures/setup-plan-json-output/
- [x] T003 [P] Add base contract in specs/009-setup-plan-json-purity/contracts/json-output-contract.md

## Phase 2: Foundational
- [x] T004 Add JSON parse helper in tests/helpers/assert_setup_plan_json_output.ps1
- [x] T005 [P] Add docs consistency script in tests/validate_setup_plan_json_output_docs.ps1
- [x] T006 [P] Add failure-mode catalog in specs/009-setup-plan-json-purity/contracts/failure-mode-catalog.md

## Phase 3: US1
- [x] T007 [P] [US1] Add failing test for pure JSON stdout in tests/setup_plan_json_output_regression.ps1
- [x] T008 [P] [US1] Add failing test for required JSON fields in tests/setup_plan_json_output_regression.ps1
- [x] T009 [US1] Remove non-JSON lines from JSON mode in .specify/scripts/powershell/setup-plan.ps1
- [x] T010 [US1] Preserve JSON field compatibility in .specify/scripts/powershell/setup-plan.ps1
- [x] T011 [US1] Update JSON examples in specs/009-setup-plan-json-purity/contracts/json-output-contract.md
- [x] T012 [US1] Record US1 evidence in specs/009-setup-plan-json-purity/contracts/json-output-contract.md

## Phase 4: US2
- [x] T013 [P] [US2] Add failing test for ACTION presence in text mode in tests/setup_plan_json_output_regression.ps1
- [x] T014 [P] [US2] Add failing test for text mode output paths in tests/setup_plan_json_output_regression.ps1
- [x] T015 [US2] Keep text mode ACTION output in .specify/scripts/powershell/setup-plan.ps1
- [x] T016 [US2] Keep text mode path output in .specify/scripts/powershell/setup-plan.ps1
- [x] T017 [US2] Document text mode guarantees in specs/009-setup-plan-json-purity/contracts/failure-mode-catalog.md
- [x] T018 [US2] Record US2 evidence in specs/009-setup-plan-json-purity/contracts/failure-mode-catalog.md

## Phase 5: US3
- [x] T019 [P] [US3] Add docs consistency checks in tests/validate_setup_plan_json_output_docs.ps1
- [x] T020 [US3] Update quickstart examples in specs/009-setup-plan-json-purity/quickstart.md
- [x] T021 [US3] Finalize research decisions in specs/009-setup-plan-json-purity/research.md
- [x] T022 [US3] Add docs traceability in specs/009-setup-plan-json-purity/contracts/json-output-contract.md
- [x] T023 [US3] Add final evidence matrix in specs/009-setup-plan-json-purity/contracts/json-output-contract.md

## Phase 6: Polish
- [x] T024 [P] Normalize terminology in specs/009-setup-plan-json-purity/spec.md
- [x] T025 Run regression/docs checks and log outputs in specs/009-setup-plan-json-purity/contracts/json-output-contract.md
- [x] T026 Update semver impact in specs/009-setup-plan-json-purity/plan.md
