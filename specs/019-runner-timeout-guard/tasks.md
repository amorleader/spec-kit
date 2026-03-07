# Tasks: Harden Quality Runner with Per-Script Timeout Guard

**Input**: Design documents from `/specs/019-runner-timeout-guard/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Include test tasks for behavior changes; write failing regression/docs tests first.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Initialize feature documentation and baseline task scaffolding.

- [x] T001 Align feature metadata in specs/019-runner-timeout-guard/spec.md
- [x] T002 [P] Align implementation context in specs/019-runner-timeout-guard/plan.md
- [x] T003 [P] Record timeout strategy decisions in specs/019-runner-timeout-guard/research.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define shared timeout contract and assertion model used by all stories.

- [x] T004 Define timeout entities in specs/019-runner-timeout-guard/data-model.md
- [x] T005 [P] Define CLI/output timeout contract in specs/019-runner-timeout-guard/contracts/quality-runner-timeout-contract.md
- [x] T006 Define timeout validation quickstart in specs/019-runner-timeout-guard/quickstart.md

**Checkpoint**: Timeout foundation is complete; user stories can proceed independently.

---

## Phase 3: User Story 1 - 超时防护执行 (Priority: P1) 🎯 MVP

**Goal**: Prevent a hanging child script from blocking the entire quality runner.

**Independent Test**: Run timeout regression and verify timed-out child scripts are terminated while aggregate execution continues.

### Tests for User Story 1

- [x] T007 [P] [US1] Add hanging-script regression fixture flow in tests/run_all_quality_checks_timeout_regression.ps1
- [x] T008 [US1] Add failing assertion for timeout termination/continuation in tests/run_all_quality_checks_timeout_regression.ps1

### Implementation for User Story 1

- [x] T009 [US1] Add `-PerScriptTimeoutSec` parameter handling in tests/run_all_quality_checks.ps1
- [x] T010 [US1] Implement per-script timeout execution and forced termination in tests/run_all_quality_checks.ps1
- [x] T011 [US1] Execute US1 timeout regression verification via tests/run_all_quality_checks_timeout_regression.ps1

**Checkpoint**: Timeout guard execution is independently testable.

---

## Phase 4: User Story 2 - 汇总可观测性增强 (Priority: P2)

**Goal**: Surface timeout diagnostics consistently in text and JSON outputs.

**Independent Test**: Run runner with timeout enabled and verify timeout labels/counts in text and JSON output.

### Tests for User Story 2

- [x] T012 [P] [US2] Add JSON timeout-field assertions in tests/run_all_quality_checks_timeout_regression.ps1
- [x] T013 [US2] Add text summary timeout assertions in tests/run_all_quality_checks_timeout_regression.ps1

### Implementation for User Story 2

- [x] T014 [US2] Add timeout count and status mapping in JSON summary in tests/run_all_quality_checks.ps1
- [x] T015 [US2] Add timeout labels and summary details in text output in tests/run_all_quality_checks.ps1
- [x] T016 [US2] Execute US2 observability regression verification via tests/run_all_quality_checks_timeout_regression.ps1

**Checkpoint**: Timeout observability is independently testable.

---

## Phase 5: User Story 3 - 文档与回归门禁 (Priority: P3)

**Goal**: Ensure timeout behavior is enforced by docs validation and integrated regression checks.

**Independent Test**: Run docs validator and docs-only aggregate with timeout option enabled.

### Tests for User Story 3

- [x] T017 [P] [US3] Add docs semantic validator for timeout contract in tests/validate_run_all_quality_checks_timeout_docs.ps1

### Implementation for User Story 3

- [x] T018 [US3] Document timeout CLI/output contract in specs/019-runner-timeout-guard/contracts/quality-runner-timeout-contract.md
- [x] T019 [US3] Document timeout usage examples in specs/019-runner-timeout-guard/quickstart.md
- [x] T020 [US3] Execute docs validator verification via tests/validate_run_all_quality_checks_timeout_docs.ps1
- [x] T021 [US3] Execute docs-only aggregate verification with timeout option in tests/run_all_quality_checks.ps1

**Checkpoint**: Docs gate for timeout behavior is independently testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening and compatibility checks across all stories.

- [x] T022 [P] Re-run full timeout regression suite in tests/run_all_quality_checks_timeout_regression.ps1
- [x] T023 [P] Re-run existing docs validator baseline in tests/validate_run_all_quality_checks_docs.ps1
- [x] T024 Update release impact details in specs/019-runner-timeout-guard/plan.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1) has no dependencies.
- Foundational (Phase 2) depends on Setup and blocks all story work.
- User story phases (Phase 3-5) depend on Foundational completion.
- Polish (Phase 6) depends on completion of desired user stories.

### User Story Dependencies

- US1 (P1): Starts after Foundational; no dependency on US2/US3.
- US2 (P2): Starts after Foundational; builds on runner execution from US1 but remains independently testable.
- US3 (P3): Starts after Foundational; independent docs gate with its own validator.

### Dependency Graph

- Foundation path: Phase 1 → Phase 2
- Delivery path: Phase 2 → US1 (MVP) → US2 → US3
- Finalization path: US1/US2/US3 → Phase 6

---

## Parallel Opportunities

- Setup: T002 and T003 can run in parallel.
- Foundational: T005 can run in parallel with T004.
- US1: T007 can run in parallel with preparation work for T009.
- US2: T012 can run in parallel with T013.
- Polish: T022 and T023 can run in parallel.

---

## Parallel Example: User Story 2

```bash
Task: "T012 [US2] Add JSON timeout-field assertions in tests/run_all_quality_checks_timeout_regression.ps1"
Task: "T013 [US2] Add text summary timeout assertions in tests/run_all_quality_checks_timeout_regression.ps1"
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 and Phase 2.
2. Deliver US1 tasks (T007-T011).
3. Validate timeout guard behavior independently.

### Incremental Delivery

1. Add US2 tasks (T012-T016) and validate observability.
2. Add US3 tasks (T017-T021) and validate docs gate.
3. Run Polish tasks (T022-T024) for final readiness.

### Suggested MVP Scope

- US1 only (T007-T011) after Setup/Foundational completion.
