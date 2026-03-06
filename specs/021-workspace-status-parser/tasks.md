# Tasks: Harden Workspace Recovery with Robust Git Status Parsing

**Input**: Design documents from `/specs/021-workspace-status-parser/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md

## Phase 1: Setup

- [ ] T001 Align feature scope in specs/021-workspace-status-parser/spec.md
- [ ] T002 [P] Align implementation context in specs/021-workspace-status-parser/plan.md
- [ ] T003 [P] Capture parsing decisions in specs/021-workspace-status-parser/research.md

---

## Phase 2: Foundational

- [ ] T004 Define parser entities in specs/021-workspace-status-parser/data-model.md
- [ ] T005 [P] Define parsing contract in specs/021-workspace-status-parser/contracts/quality-runner-status-parser-contract.md
- [ ] T006 Define quickstart scenarios in specs/021-workspace-status-parser/quickstart.md

---

## Phase 3: User Story 1 - 重命名变更可恢复 (P1)

- [ ] T007 [P] [US1] Add rename-pollution regression in tests/run_all_quality_checks_status_parser_regression.ps1
- [ ] T008 [US1] Add failing rename recovery assertions in tests/run_all_quality_checks_status_parser_regression.ps1
- [ ] T009 [US1] Implement status path normalization in tests/run_all_quality_checks.ps1
- [ ] T010 [US1] Wire normalized paths into snapshot/recovery flow in tests/run_all_quality_checks.ps1
- [ ] T011 [US1] Execute US1 regression verification via tests/run_all_quality_checks_status_parser_regression.ps1

---

## Phase 4: User Story 2 - 路径解析兼容复杂格式 (P2)

- [ ] T012 [P] [US2] Add parser assertions for `old -> new` path form in tests/run_all_quality_checks_status_parser_regression.ps1
- [ ] T013 [US2] Add parser assertions for spaced path handling in tests/run_all_quality_checks_status_parser_regression.ps1
- [ ] T014 [US2] Implement parser normalization helper for quoted/rename paths in tests/run_all_quality_checks.ps1
- [ ] T015 [US2] Execute US2 regression verification via tests/run_all_quality_checks_status_parser_regression.ps1

---

## Phase 5: User Story 3 - 文档与回归门禁补齐 (P3)

- [ ] T016 [P] [US3] Add status-parser docs validator in tests/validate_run_all_quality_checks_status_parser_docs.ps1
- [ ] T017 [US3] Document parser contract in specs/021-workspace-status-parser/contracts/quality-runner-status-parser-contract.md
- [ ] T018 [US3] Document runnable parser checks in specs/021-workspace-status-parser/quickstart.md
- [ ] T019 [US3] Execute docs validator verification via tests/validate_run_all_quality_checks_status_parser_docs.ps1
- [ ] T020 [US3] Execute docs-only aggregate verification via tests/run_all_quality_checks.ps1

---

## Phase 6: Polish

- [ ] T021 [P] Re-run workspace guard baseline in tests/run_all_quality_checks_workspace_guard_regression.ps1
- [ ] T022 [P] Re-run timeout baseline in tests/run_all_quality_checks_timeout_regression.ps1
- [ ] T023 [P] Re-run status parser regression in tests/run_all_quality_checks_status_parser_regression.ps1
- [ ] T024 Update release impact in specs/021-workspace-status-parser/plan.md
