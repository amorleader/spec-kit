# Tasks: Protect Workspace Cleanliness After Quality Runner Execution

**Input**: Design documents from `/specs/020-runner-workspace-guard/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Include regression and docs validation tasks first for behavior changes.

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 Align feature scope in specs/020-runner-workspace-guard/spec.md
- [ ] T002 [P] Align implementation context in specs/020-runner-workspace-guard/plan.md
- [ ] T003 [P] Capture workspace-guard decisions in specs/020-runner-workspace-guard/research.md

---

## Phase 2: Foundational (Blocking Prerequisites)

- [ ] T004 Define recovery entities in specs/020-runner-workspace-guard/data-model.md
- [ ] T005 [P] Define recovery/output contract in specs/020-runner-workspace-guard/contracts/quality-runner-workspace-guard-contract.md
- [ ] T006 Define runnable validation steps in specs/020-runner-workspace-guard/quickstart.md

**Checkpoint**: Foundational contract complete.

---

## Phase 3: User Story 1 - 执行后保持工作区干净 (Priority: P1) 🎯 MVP

**Independent Test**: Run workspace-guard regression and verify runner leaves no new workspace pollution.

- [ ] T007 [P] [US1] Add workspace pollution fixture flow in tests/run_all_quality_checks_workspace_guard_regression.ps1
- [ ] T008 [US1] Add failing assertions for post-run cleanliness in tests/run_all_quality_checks_workspace_guard_regression.ps1
- [ ] T009 [US1] Implement per-script workspace snapshot capture in tests/run_all_quality_checks.ps1
- [ ] T010 [US1] Implement cleanup of newly introduced tracked/temp pollution in tests/run_all_quality_checks.ps1
- [ ] T011 [US1] Execute US1 regression verification via tests/run_all_quality_checks_workspace_guard_regression.ps1

---

## Phase 4: User Story 2 - 不破坏已有未提交改动 (Priority: P2)

**Independent Test**: Run regression with pre-existing changes and verify they remain unchanged.

- [ ] T012 [P] [US2] Add pre-existing-change preservation assertions in tests/run_all_quality_checks_workspace_guard_regression.ps1
- [ ] T013 [US2] Implement baseline-preserving recovery filter in tests/run_all_quality_checks.ps1
- [ ] T014 [US2] Add text diagnostics for skipped existing changes in tests/run_all_quality_checks.ps1
- [ ] T015 [US2] Execute US2 regression verification via tests/run_all_quality_checks_workspace_guard_regression.ps1

---

## Phase 5: User Story 3 - 文档与回归门禁覆盖 (Priority: P3)

**Independent Test**: Run workspace-guard docs validator and docs-only aggregate verification.

- [ ] T016 [P] [US3] Add docs semantic validator in tests/validate_run_all_quality_checks_workspace_guard_docs.ps1
- [ ] T017 [US3] Add JSON recovery stats fields in tests/run_all_quality_checks.ps1
- [ ] T018 [US3] Document workspace-guard behavior in specs/020-runner-workspace-guard/contracts/quality-runner-workspace-guard-contract.md
- [ ] T019 [US3] Execute docs validator verification via tests/validate_run_all_quality_checks_workspace_guard_docs.ps1
- [ ] T020 [US3] Execute docs-only aggregate verification via tests/run_all_quality_checks.ps1

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T021 [P] Re-run timeout regression baseline in tests/run_all_quality_checks_timeout_regression.ps1
- [ ] T022 [P] Re-run existing docs validator baseline in tests/validate_run_all_quality_checks_docs.ps1
- [ ] T023 [P] Re-run workspace-guard regression in tests/run_all_quality_checks_workspace_guard_regression.ps1
- [ ] T024 Update release impact notes in specs/020-runner-workspace-guard/plan.md

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 → US1 → US2 → US3 → Phase 6
- US2 depends on US1 recovery baseline.
- US3 depends on stabilized runner output from US1/US2.

## Parallel Opportunities

- T002 and T003 can run in parallel.
- T005 can run in parallel with T004.
- T007 can run in parallel with T009 preparation.
- T021/T022/T023 can run in parallel.

## Parallel Example: User Story 1

```bash
Task: "T007 [US1] Add workspace pollution fixture flow in tests/run_all_quality_checks_workspace_guard_regression.ps1"
Task: "T009 [US1] Implement per-script workspace snapshot capture in tests/run_all_quality_checks.ps1"
```

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 + Phase 2.
2. Deliver US1 tasks (T007-T011).
3. Validate post-run workspace cleanliness.

### Incremental Delivery

1. Add US2 protections for existing local changes.
2. Add US3 docs gate and JSON recovery stats.
3. Run polish validations.
