# Tasks: Stabilize Text Output Check Behavior

**Input**: Design documents from `/specs/884-stabilize-text-output/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Include regression/docs validation tasks before implementation.

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Align feature scope in specs/884-stabilize-text-output/spec.md
- [x] T002 [P] Align implementation context in specs/884-stabilize-text-output/plan.md
- [x] T003 [P] Capture text-output decisions in specs/884-stabilize-text-output/research.md

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T004 Define text-output entities in specs/884-stabilize-text-output/data-model.md
- [x] T005 [P] Define text-output contract in specs/884-stabilize-text-output/contracts/text-output-check-contract.md
- [x] T006 Define runnable validation steps in specs/884-stabilize-text-output/quickstart.md

---

## Phase 3: User Story 1 - 文本模式输出稳定 (Priority: P1) 🎯 MVP

**Goal**: 锁定文本模式关键标签和输出顺序，避免格式漂移。
**Independent Test**: text-output regression passes in success and failure scenarios.

- [x] T007 [P] [US1] Add text-output regression fixture in tests/text_output_check_regression.ps1
- [x] T008 [US1] Add failing assertions for key labels/order in tests/text_output_check_regression.ps1
- [x] T009 [US1] Stabilize text output in .specify/scripts/powershell/check-prerequisites.ps1
- [x] T010 [US1] Stabilize text output in .specify/scripts/powershell/setup-plan.ps1
- [x] T011 [US1] Stabilize text output in .specify/scripts/powershell/create-new-feature.ps1
- [x] T012 [US1] Execute US1 verification via tests/text_output_check_regression.ps1

---

## Phase 4: User Story 2 - 文本错误提示一致 (Priority: P2)

**Goal**: 统一失败路径的文本提示语义与结构。
**Independent Test**: failure messages follow a consistent heading + hint style across scripts.

- [x] T013 [P] [US2] Add failure-hint consistency assertions in tests/text_output_check_regression.ps1
- [x] T014 [US2] Normalize text failure hints in .specify/scripts/powershell/check-prerequisites.ps1
- [x] T015 [US2] Normalize text failure hints in .specify/scripts/powershell/setup-plan.ps1
- [x] T016 [US2] Execute US2 verification via tests/text_output_check_regression.ps1

---

## Phase 5: User Story 3 - 文档与门禁固化 (Priority: P3)

**Goal**: 将文本输出约束固化到文档和自动化门禁。
**Independent Test**: docs validator passes and is included in docs-only aggregate.

- [x] T017 [P] [US3] Add text-output docs validator in tests/validate_text_output_check_docs.ps1
- [x] T018 [US3] Document text-output constraints in specs/884-stabilize-text-output/contracts/text-output-check-contract.md
- [x] T019 [US3] Execute docs validator verification via tests/validate_text_output_check_docs.ps1
- [x] T020 [US3] Execute docs-only aggregate verification via tests/run_all_quality_checks.ps1

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T021 [P] Re-run create-new-feature regression in tests/create_new_feature_regression.ps1
- [x] T022 [P] Re-run setup-plan regression in tests/setup_plan_regression.ps1
- [x] T023 [P] Re-run check-prerequisites regression in tests/check_prerequisites_regression.ps1
- [x] T024 Update release impact in specs/884-stabilize-text-output/plan.md

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 → US1 → US2 → US3 → Phase 6
- Story graph: US1 → US2 → US3
- US2 depends on text-output stabilization from US1.
- US3 depends on finalized constraints from US1/US2.

## Parallel Opportunities

- T002 and T003 can run in parallel.
- T005 can run in parallel with T004.
- T009/T010/T011 can run in parallel (different files).
- T021/T022/T023 can run in parallel.

## Parallel Example: User Story 1

```bash
Task: "T007 [US1] Add text-output regression fixture in tests/text_output_check_regression.ps1"
Task: "T009 [US1] Stabilize text output in .specify/scripts/powershell/check-prerequisites.ps1"
Task: "T010 [US1] Stabilize text output in .specify/scripts/powershell/setup-plan.ps1"
```

## Parallel Example: User Story 2

```bash
Task: "T013 [US2] Add failure-hint consistency assertions in tests/text_output_check_regression.ps1"
Task: "T014 [US2] Normalize text failure hints in .specify/scripts/powershell/check-prerequisites.ps1"
```

## Parallel Example: User Story 3

```bash
Task: "T017 [US3] Add text-output docs validator in tests/validate_text_output_check_docs.ps1"
Task: "T018 [US3] Document text-output constraints in specs/884-stabilize-text-output/contracts/text-output-check-contract.md"
```

## Implementation Strategy

### MVP First (US1 Only)
1. Complete Phase 1 + Phase 2.
2. Deliver US1 tasks (T007-T012).
3. Validate text output stability in success/failure paths.

### Incremental Delivery
1. Add US2 failure hint consistency.
2. Add US3 docs gate.
3. Run Phase 6 baseline regressions.