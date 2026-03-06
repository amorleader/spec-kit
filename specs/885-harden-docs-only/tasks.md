# Tasks: Harden Docs-Only Aggregate Execution

**Input**: Design documents from `/specs/885-harden-docs-only/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Include regression/docs validation tasks before implementation.

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 Align feature scope in specs/885-harden-docs-only/spec.md
- [ ] T002 [P] Align implementation context in specs/885-harden-docs-only/plan.md
- [ ] T003 [P] Capture docs-only hardening decisions in specs/885-harden-docs-only/research.md

---

## Phase 2: Foundational (Blocking Prerequisites)

- [ ] T004 Define docs-only entities in specs/885-harden-docs-only/data-model.md
- [ ] T005 [P] Define docs-only contract in specs/885-harden-docs-only/contracts/docs-only-aggregate-contract.md
- [ ] T006 Define runnable validation steps in specs/885-harden-docs-only/quickstart.md

---

## Phase 3: User Story 1 - docs-only 执行稳定 (Priority: P1) 🎯 MVP

**Goal**: 稳定 docs-only 聚合执行与统计一致性。
**Independent Test**: docs-only regression passes with stable counts and status propagation.

- [ ] T007 [P] [US1] Add docs-only regression fixture in tests/run_all_quality_checks_docs_only_regression.ps1
- [ ] T008 [US1] Add failing assertions for counts/status in tests/run_all_quality_checks_docs_only_regression.ps1
- [ ] T009 [US1] Harden docs-only script selection logic in tests/run_all_quality_checks.ps1
- [ ] T010 [US1] Harden docs-only status aggregation logic in tests/run_all_quality_checks.ps1
- [ ] T011 [US1] Execute US1 verification via tests/run_all_quality_checks_docs_only_regression.ps1

---

## Phase 4: User Story 2 - docs-only 输出契约稳定 (Priority: P2)

**Goal**: 保持 docs-only JSON/text 输出契约兼容稳定。
**Independent Test**: docs-only output fields and structure remain backward compatible.

- [ ] T012 [P] [US2] Add contract compatibility assertions in tests/run_all_quality_checks_docs_only_regression.ps1
- [ ] T013 [US2] Verify docs-only JSON contract stability in tests/run_all_quality_checks.ps1
- [ ] T014 [US2] Execute US2 verification via tests/run_all_quality_checks_docs_only_regression.ps1

---

## Phase 5: User Story 3 - 文档与回归门禁固化 (Priority: P3)

**Goal**: 固化 docs-only 加固约束到文档与自动化门禁。
**Independent Test**: docs validator passes and is included in docs-only aggregate.

- [ ] T015 [P] [US3] Add docs-only hardening docs validator in tests/validate_docs_only_hardening_docs.ps1
- [ ] T016 [US3] Document docs-only constraints in specs/885-harden-docs-only/contracts/docs-only-aggregate-contract.md
- [ ] T017 [US3] Execute docs validator verification via tests/validate_docs_only_hardening_docs.ps1
- [ ] T018 [US3] Execute docs-only aggregate verification via tests/run_all_quality_checks.ps1

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T019 [P] Re-run docs-only aggregate check in tests/run_all_quality_checks.ps1
- [ ] T020 [P] Re-run quality-runner baseline regression in tests/run_all_quality_checks_regression.ps1
- [ ] T021 [P] Re-run status parser baseline regression in tests/run_all_quality_checks_status_parser_regression.ps1
- [ ] T022 Update release impact in specs/885-harden-docs-only/plan.md

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 → US1 → US2 → US3 → Phase 6
- Story graph: US1 → US2 → US3
- US2 depends on docs-only execution stability from US1.
- US3 depends on finalized docs-only contract from US1/US2.

## Parallel Opportunities

- T002 and T003 can run in parallel.
- T005 can run in parallel with T004.
- T007 can run in parallel with T009 preparation.
- T019/T020/T021 can run in parallel.

## Parallel Example: User Story 1

```bash
Task: "T007 [US1] Add docs-only regression fixture in tests/run_all_quality_checks_docs_only_regression.ps1"
Task: "T009 [US1] Harden docs-only script selection logic in tests/run_all_quality_checks.ps1"
```

## Parallel Example: User Story 2

```bash
Task: "T012 [US2] Add contract compatibility assertions in tests/run_all_quality_checks_docs_only_regression.ps1"
Task: "T013 [US2] Verify docs-only JSON contract stability in tests/run_all_quality_checks.ps1"
```

## Parallel Example: User Story 3

```bash
Task: "T015 [US3] Add docs-only hardening docs validator in tests/validate_docs_only_hardening_docs.ps1"
Task: "T016 [US3] Document docs-only constraints in specs/885-harden-docs-only/contracts/docs-only-aggregate-contract.md"
```

## Implementation Strategy

### MVP First (US1 Only)
1. Complete Phase 1 + Phase 2.
2. Deliver US1 tasks (T007-T011).
3. Validate docs-only execution and counting stability.

### Incremental Delivery
1. Add US2 contract compatibility assertions.
2. Add US3 docs gate.
3. Run Phase 6 baseline regressions.