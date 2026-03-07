# Tasks: Stabilize JSON Pure Check Output

**Input**: Design documents from `/specs/883-stabilize-json-pure/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Include regression/docs validation tasks before implementation.

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Align feature scope in specs/883-stabilize-json-pure/spec.md
- [x] T002 [P] Align implementation context in specs/883-stabilize-json-pure/plan.md
- [x] T003 [P] Capture JSON purity decisions in specs/883-stabilize-json-pure/research.md

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T004 Define JSON output entities in specs/883-stabilize-json-pure/data-model.md
- [x] T005 [P] Define JSON output contract in specs/883-stabilize-json-pure/contracts/json-pure-output-contract.md
- [x] T006 Define runnable validation steps in specs/883-stabilize-json-pure/quickstart.md

---

## Phase 3: User Story 1 - JSON 模式输出纯净 (Priority: P1) 🎯 MVP

**Goal**: 保障关键脚本在 `-Json` 模式输出单一可解析 JSON 文档。
**Independent Test**: JSON purity regression passes for success and failure paths.

- [x] T007 [P] [US1] Add JSON purity regression fixture in tests/json_pure_output_regression.ps1
- [x] T008 [US1] Add failing parse/contamination assertions in tests/json_pure_output_regression.ps1
- [x] T009 [US1] Implement pure JSON output path in .specify/scripts/powershell/check-prerequisites.ps1
- [x] T010 [US1] Implement pure JSON output path in .specify/scripts/powershell/setup-plan.ps1
- [x] T011 [US1] Implement pure JSON output path in .specify/scripts/powershell/create-new-feature.ps1
- [x] T012 [US1] Execute US1 regression verification via tests/json_pure_output_regression.ps1

---

## Phase 4: User Story 2 - 错误语义一致化 (Priority: P2)

**Goal**: 在失败路径提供一致核心错误字段语义。
**Independent Test**: Failure outputs from target scripts share stable error-field semantics.

- [x] T013 [P] [US2] Add failure contract assertions in tests/json_pure_output_regression.ps1
- [x] T014 [US2] Normalize JSON error object in .specify/scripts/powershell/check-prerequisites.ps1
- [x] T015 [US2] Normalize JSON error object in .specify/scripts/powershell/setup-plan.ps1
- [x] T016 [US2] Execute US2 failure-contract verification via tests/json_pure_output_regression.ps1

---

## Phase 5: User Story 3 - 文档与门禁固化 (Priority: P3)

**Goal**: 将 JSON 纯净输出约束固化为文档与自动化门禁。
**Independent Test**: Docs validator passes and is included in aggregate run.

- [x] T017 [P] [US3] Add JSON purity docs validator in tests/validate_json_pure_output_docs.ps1
- [x] T018 [US3] Document JSON purity constraints in specs/883-stabilize-json-pure/contracts/json-pure-output-contract.md
- [x] T019 [US3] Execute docs validator verification via tests/validate_json_pure_output_docs.ps1
- [x] T020 [US3] Execute docs-only aggregate verification via tests/run_all_quality_checks.ps1

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T021 [P] Re-run create-new-feature JSON regression in tests/create_new_feature_json_output_regression.ps1
- [x] T022 [P] Re-run setup-plan JSON regression in tests/setup_plan_json_output_regression.ps1
- [x] T023 [P] Re-run check-prerequisites regression in tests/check_prerequisites_regression.ps1
- [x] T024 Update release impact in specs/883-stabilize-json-pure/plan.md

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 → US1 → US2 → US3 → Phase 6
- Story graph: US1 → US2 → US3
- US2 depends on JSON purity path completed in US1.
- US3 depends on finalized contract terms from US1/US2.

## Parallel Opportunities

- T002 and T003 can run in parallel.
- T005 can run in parallel with T004.
- T009/T010/T011 target different files and can run in parallel.
- T021/T022/T023 can run in parallel.

## Parallel Example: User Story 1

```bash
Task: "T007 [US1] Add JSON purity regression fixture in tests/json_pure_output_regression.ps1"
Task: "T009 [US1] Implement pure JSON output path in .specify/scripts/powershell/check-prerequisites.ps1"
Task: "T010 [US1] Implement pure JSON output path in .specify/scripts/powershell/setup-plan.ps1"
```

## Parallel Example: User Story 2

```bash
Task: "T013 [US2] Add failure contract assertions in tests/json_pure_output_regression.ps1"
Task: "T014 [US2] Normalize JSON error object in .specify/scripts/powershell/check-prerequisites.ps1"
```

## Parallel Example: User Story 3

```bash
Task: "T017 [US3] Add JSON purity docs validator in tests/validate_json_pure_output_docs.ps1"
Task: "T018 [US3] Document JSON purity constraints in specs/883-stabilize-json-pure/contracts/json-pure-output-contract.md"
```

## Implementation Strategy

### MVP First (US1 Only)
1. Complete Phase 1 + Phase 2.
2. Deliver US1 tasks (T007-T012).
3. Validate JSON purity in success and failure paths.

### Incremental Delivery
1. Add US2 error semantics normalization.
2. Add US3 docs gate.
3. Run Phase 6 baseline regressions.
