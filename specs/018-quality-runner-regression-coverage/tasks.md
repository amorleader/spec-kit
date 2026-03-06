# Tasks: Add Regression Coverage for Full Quality Runner

**Input**: Design documents from `/specs/018-quality-runner-regression-coverage/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md

**Tests**: This feature delivers regression and docs-validation scripts; implementation and verification tasks are included per story.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare feature documentation scaffolding and baseline contract context.

- [ ] T001 Align feature summary and constraints in specs/018-quality-runner-regression-coverage/plan.md
- [ ] T002 [P] Confirm user stories and acceptance criteria in specs/018-quality-runner-regression-coverage/spec.md
- [ ] T003 [P] Capture regression decisions in specs/018-quality-runner-regression-coverage/research.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define shared assertion model and execution expectations used by all stories.

- [ ] T004 Define regression assertion entities in specs/018-quality-runner-regression-coverage/data-model.md
- [ ] T005 [P] Define required regression contract clauses in specs/018-quality-runner-regression-coverage/contracts/quality-runner-regression-contract.md
- [ ] T006 Define runnable verification steps in specs/018-quality-runner-regression-coverage/quickstart.md

**Checkpoint**: Foundation complete; user stories can proceed independently.

---

## Phase 3: User Story 1 - JSON 汇总回归 (Priority: P1) 🎯 MVP

**Goal**: Ensure `run_all_quality_checks.ps1 -Json` remains parseable with required fields.

**Independent Test**: Run `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks_regression.ps1` and verify US1 JSON assertions pass.

### Implementation for User Story 1

- [ ] T007 [P] [US1] Implement JSON contract assertion helper in tests/helpers/assert_run_all_quality_checks_json.ps1
- [ ] T008 [US1] Implement JSON-mode regression flow in tests/run_all_quality_checks_regression.ps1
- [ ] T009 [US1] Execute US1 JSON regression verification via tests/run_all_quality_checks_regression.ps1

**Checkpoint**: JSON regression contract is independently testable.

---

## Phase 4: User Story 2 - 文本模式兼容回归 (Priority: P2)

**Goal**: Preserve RUN/PASS/final summary behavior in text mode and branch stability.

**Independent Test**: Run `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks_regression.ps1` and verify text compatibility and branch stability assertions pass.

### Implementation for User Story 2

- [ ] T010 [US2] Implement text-mode compatibility assertions in tests/run_all_quality_checks_regression.ps1
- [ ] T011 [US2] Implement branch stability before/after checks in tests/run_all_quality_checks_regression.ps1
- [ ] T012 [US2] Execute US2 text/branch regression verification via tests/run_all_quality_checks_regression.ps1

**Checkpoint**: Text compatibility and branch stability are independently testable.

---

## Phase 5: User Story 3 - 文档门禁补齐 (Priority: P3)

**Goal**: Enforce consistency across `spec.md`, `quickstart.md`, and contract docs for runner regression behavior.

**Independent Test**: Run `powershell -ExecutionPolicy Bypass -File tests/validate_run_all_quality_checks_docs.ps1` and verify all semantic checks pass.

### Implementation for User Story 3

- [ ] T013 [P] [US3] Implement docs semantic validator in tests/validate_run_all_quality_checks_docs.ps1
- [ ] T014 [US3] Document JSON required fields and stability semantics in specs/018-quality-runner-regression-coverage/contracts/quality-runner-regression-contract.md
- [ ] T015 [US3] Align Json usage examples and expected outcomes in specs/018-quality-runner-regression-coverage/quickstart.md
- [ ] T016 [US3] Execute docs validator verification via tests/validate_run_all_quality_checks_docs.ps1

**Checkpoint**: Documentation gate is independently testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency pass across full docs-only aggregation and feature metadata.

- [ ] T017 [P] Run docs-only aggregate verification with tests/run_all_quality_checks.ps1
- [ ] T018 [P] Re-run standalone regression suite in tests/run_all_quality_checks_regression.ps1
- [ ] T019 Update release impact notes in specs/018-quality-runner-regression-coverage/plan.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1) has no dependencies.
- Foundational (Phase 2) depends on Setup and blocks all user story work.
- User Story phases (Phase 3-5) depend on Foundational completion.
- Polish (Phase 6) depends on completion of desired user stories.

### User Story Dependencies

- US1 (P1): Starts after Foundational; no dependency on US2/US3.
- US2 (P2): Starts after Foundational; reuses regression script from US1 but remains independently testable.
- US3 (P3): Starts after Foundational; independent docs gate with its own validator.

### Dependency Graph

- Foundation path: Phase 1 → Phase 2
- Story delivery path: Phase 2 → US1 (MVP) → US2 → US3
- Finalization path: US1/US2/US3 → Phase 6

---

## Parallel Opportunities

- Phase 1: T002 and T003 can run in parallel.
- Phase 2: T005 can run in parallel with T004 when file edits do not overlap.
- US1: T007 can be developed in parallel with preparation work for T008.
- US3: T013 and T015 can run in parallel (different files).
- Polish: T017 and T018 can run in parallel.

---

## Parallel Example: User Story 3

```bash
Task: "T013 [US3] Implement docs semantic validator in tests/validate_run_all_quality_checks_docs.ps1"
Task: "T015 [US3] Align Json usage examples and expected outcomes in specs/018-quality-runner-regression-coverage/quickstart.md"
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 and Phase 2.
2. Deliver US1 tasks (T007-T009).
3. Validate JSON regression independently.

### Incremental Delivery

1. Add US2 tasks (T010-T012) and validate text compatibility/branch stability.
2. Add US3 tasks (T013-T016) and validate docs gate.
3. Run Polish tasks (T017-T019) for final readiness.

### Suggested MVP Scope

- US1 only (T007-T009) after Setup/Foundational completion.
