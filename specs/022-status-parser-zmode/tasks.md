# Tasks: Use Porcelain-Z Parser for Workspace Status Recovery

**Input**: Design documents from `/specs/022-status-parser-zmode/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Include regression/docs validation tasks before implementation.

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Align feature scope in specs/022-status-parser-zmode/spec.md
- [x] T002 [P] Align implementation context in specs/022-status-parser-zmode/plan.md
- [x] T003 [P] Capture z-mode parser decisions in specs/022-status-parser-zmode/research.md

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T004 Define parser entities in specs/022-status-parser-zmode/data-model.md
- [x] T005 [P] Define z-mode contract in specs/022-status-parser-zmode/contracts/quality-runner-status-parser-zmode-contract.md
- [x] T006 Define runnable validation steps in specs/022-status-parser-zmode/quickstart.md

---

## Phase 3: User Story 1 - 解析重命名与特殊文件名 (Priority: P1) 🎯 MVP

**Goal**: 通过 porcelain-z NUL 分隔解析稳定处理 rename 双路径与复杂文件名。
**Independent Test**: z-mode regression passes for rename paths containing ` -> ` and spaces.

- [x] T007 [P] [US1] Add z-mode rename regression fixture in tests/run_all_quality_checks_status_parser_zmode_regression.ps1
- [x] T008 [US1] Add failing assertions for rename+special path recovery in tests/run_all_quality_checks_status_parser_zmode_regression.ps1
- [x] T009 [US1] Implement porcelain-z snapshot parser in tests/run_all_quality_checks.ps1
- [x] T010 [US1] Integrate rename two-path mapping into recovery flow in tests/run_all_quality_checks.ps1
- [x] T011 [US1] Execute US1 regression verification via tests/run_all_quality_checks_status_parser_zmode_regression.ps1

---

## Phase 4: User Story 2 - 保持现有输出兼容 (Priority: P2)

**Goal**: 在解析升级后维持 JSON/text 输出契约和失败语义兼容。
**Independent Test**: docs-only JSON output remains parseable with existing fields.

- [x] T012 [P] [US2] Add compatibility assertions in tests/run_all_quality_checks_status_parser_zmode_regression.ps1
- [x] T013 [US2] Verify no output contract regression in tests/run_all_quality_checks.ps1
- [x] T014 [US2] Execute US2 docs-only JSON verification via tests/run_all_quality_checks.ps1

---

## Phase 5: User Story 3 - 文档与回归门禁 (Priority: P3)

**Goal**: 固化 z-mode 行为到文档和回归门禁，避免后续回退。
**Independent Test**: z-mode docs validator passes and is included in aggregate run.

- [x] T015 [P] [US3] Add z-mode docs validator in tests/validate_run_all_quality_checks_status_parser_zmode_docs.ps1
- [x] T016 [US3] Document z-mode semantics in specs/022-status-parser-zmode/contracts/quality-runner-status-parser-zmode-contract.md
- [x] T017 [US3] Execute docs validator verification via tests/validate_run_all_quality_checks_status_parser_zmode_docs.ps1
- [x] T018 [US3] Execute docs-only aggregate verification via tests/run_all_quality_checks.ps1

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T019 [P] Re-run status parser baseline regression in tests/run_all_quality_checks_status_parser_regression.ps1
- [x] T020 [P] Re-run workspace guard baseline regression in tests/run_all_quality_checks_workspace_guard_regression.ps1
- [x] T021 [P] Re-run timeout baseline regression in tests/run_all_quality_checks_timeout_regression.ps1
- [x] T022 Update release impact in specs/022-status-parser-zmode/plan.md

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 → US1 → US2 → US3 → Phase 6
- Story graph: US1 → US2 → US3
- US2 depends on parser implementation from US1.
- US3 depends on finalized contracts and quickstart references.

## Parallel Opportunities

- T002 and T003 can run in parallel.
- T005 can run in parallel with T004.
- T007 can run in parallel with T009 preparation.
- T019/T020/T021 can run in parallel.

## Parallel Example: User Story 1

```bash
Task: "T007 [US1] Add z-mode rename regression fixture in tests/run_all_quality_checks_status_parser_zmode_regression.ps1"
Task: "T009 [US1] Implement porcelain-z snapshot parser in tests/run_all_quality_checks.ps1"
```

## Parallel Example: User Story 2

```bash
Task: "T012 [US2] Add compatibility assertions in tests/run_all_quality_checks_status_parser_zmode_regression.ps1"
Task: "T013 [US2] Verify no output contract regression in tests/run_all_quality_checks.ps1"
```

## Parallel Example: User Story 3

```bash
Task: "T015 [US3] Add z-mode docs validator in tests/validate_run_all_quality_checks_status_parser_zmode_docs.ps1"
Task: "T016 [US3] Document z-mode semantics in specs/022-status-parser-zmode/contracts/quality-runner-status-parser-zmode-contract.md"
```

## Implementation Strategy

### MVP First (US1 Only)
1. Complete Phase 1 + Phase 2.
2. Deliver US1 tasks (T007-T011).
3. Validate rename/special-path recovery.

### Incremental Delivery
1. Add US2 compatibility checks.
2. Add US3 docs gate.
3. Run Phase 6 baseline regressions.
