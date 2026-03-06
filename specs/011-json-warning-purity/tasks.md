# Tasks: Keep create-new-feature JSON Mode Free of Warning Output

**Input**: Design documents from `/specs/011-json-warning-purity/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Include test tasks for every behavior change. Tests must fail first, then pass after implementation.

**Organization**: Tasks are grouped by user story so each story is independently implementable and testable.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 建立本特性的回归与文档校验骨架

- [x] T001 Create warning scenario fixture workspace in tests/fixtures/create-new-feature-warning-stream/
- [x] T002 [P] Create warning scenario helper in tests/helpers/create_new_feature_warning_helper.ps1
- [x] T003 [P] Create regression runner scaffold in tests/create_new_feature_warning_stream_regression.ps1
- [x] T004 [P] Create docs consistency checker scaffold in tests/validate_create_new_feature_warning_docs.ps1

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 建立跨用户故事共享的契约与失败模式定义（阻塞后续故事）

**⚠️ CRITICAL**: No user story work should proceed until this phase is complete.

- [x] T005 Define JSON/text warning stream baseline contract in specs/011-json-warning-purity/contracts/warning-stream-contract.md
- [x] T006 [P] Define failure mode catalog for truncation scenarios in specs/011-json-warning-purity/contracts/failure-mode-catalog.md
- [x] T007 [P] Align terminology and acceptance wording in specs/011-json-warning-purity/spec.md

**Checkpoint**: Foundation ready - user story implementation can begin.

---

## Phase 3: User Story 1 - JSON 模式输出纯净 (Priority: P1) 🎯 MVP

**Goal**: JSON 模式在 warning 场景下仍保持可解析、无告警污染。

**Independent Test**: 运行 `tests/create_new_feature_warning_stream_regression.ps1` 的 US1 场景，合并流输出可 `ConvertFrom-Json` 且不含 `WARNING:`。

### Tests for User Story 1

- [x] T008 [P] [US1] Add failing JSON purity assertion for truncation warning scenario in tests/create_new_feature_warning_stream_regression.ps1
- [x] T009 [P] [US1] Add failing JSON parseability assertion under stream merge in tests/create_new_feature_warning_stream_regression.ps1

### Implementation for User Story 1

- [x] T010 [US1] Suppress warning emission path when -Json is set in .specify/scripts/powershell/create-new-feature.ps1
- [x] T011 [US1] Preserve JSON output schema keys in .specify/scripts/powershell/create-new-feature.ps1
- [x] T012 [US1] Update JSON mode contract examples and expected outputs in specs/011-json-warning-purity/contracts/warning-stream-contract.md
- [x] T013 [US1] Record US1 execution evidence and sample output in specs/011-json-warning-purity/contracts/warning-stream-contract.md

**Checkpoint**: US1 is independently functional and testable.

---

## Phase 4: User Story 2 - 文本模式 warning 可见 (Priority: P2)

**Goal**: 文本模式继续显示 warning，同时保留 ACTION/key-value 行为。

**Independent Test**: 运行 US2 场景输出包含 `WARNING:` 与 `ACTION:`，且 key-value 文本保持稳定。

### Tests for User Story 2

- [x] T014 [P] [US2] Add failing warning visibility assertion for non-JSON mode in tests/create_new_feature_warning_stream_regression.ps1
- [x] T015 [P] [US2] Add failing ACTION/key-value stability assertion in text mode in tests/create_new_feature_warning_stream_regression.ps1

### Implementation for User Story 2

- [x] T016 [US2] Ensure warning stream remains enabled in non-JSON path in .specify/scripts/powershell/create-new-feature.ps1
- [x] T017 [US2] Preserve text-mode ACTION and key-value output contract in .specify/scripts/powershell/create-new-feature.ps1
- [x] T018 [US2] Document text-mode warning guarantees and examples in specs/011-json-warning-purity/contracts/failure-mode-catalog.md
- [x] T019 [US2] Record US2 execution evidence in specs/011-json-warning-purity/contracts/failure-mode-catalog.md

**Checkpoint**: US1 and US2 both work independently.

---

## Phase 5: User Story 3 - 文档与契约一致 (Priority: P3)

**Goal**: quickstart/contract/spec 对 warning 行为描述一致且可校验。

**Independent Test**: 执行 `tests/validate_create_new_feature_warning_docs.ps1`，关键语句检查通过。

### Tests for User Story 3

- [x] T020 [P] [US3] Add failing keyword assertions for JSON/text warning semantics in tests/validate_create_new_feature_warning_docs.ps1

### Implementation for User Story 3

- [x] T021 [US3] Update quickstart usage and expected outputs in specs/011-json-warning-purity/quickstart.md
- [x] T022 [US3] Finalize rationale and decisions in specs/011-json-warning-purity/research.md
- [x] T023 [US3] Add traceability links from requirements to contracts in specs/011-json-warning-purity/contracts/warning-stream-contract.md
- [x] T024 [US3] Add final documentation evidence matrix in specs/011-json-warning-purity/contracts/warning-stream-contract.md

**Checkpoint**: All stories are independently functional and documented.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 统一收口、验证与发布影响说明

- [x] T025 [P] Run regression and docs checks, then log outputs in specs/011-json-warning-purity/contracts/warning-stream-contract.md
- [x] T026 Update release impact and SemVer notes in specs/011-json-warning-purity/plan.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1) has no dependencies.
- Foundational (Phase 2) depends on Setup and blocks all user stories.
- User Story phases (Phase 3-5) depend on Foundational completion.
- Polish (Phase 6) depends on all targeted stories.

### User Story Dependencies

- US1 (P1): starts after Foundational; no dependency on other stories.
- US2 (P2): starts after Foundational; independent from US1 but must preserve shared CLI contract.
- US3 (P3): starts after Foundational; can run after/alongside US1/US2 docs updates with merge discipline.

### Within Each User Story

- Tests first and failing before implementation tasks.
- Script behavior changes before contract/docs evidence updates.
- Story checkpoint must pass before moving to polish.

## Parallel Opportunities

- Setup parallel tasks: T002, T003, T004
- Foundational parallel tasks: T006, T007
- US1 parallel tests: T008, T009
- US2 parallel tests: T014, T015
- US3 test task T020 can run while docs edits are prepared

## Parallel Example: User Story 1

```bash
Task: "T008 [US1] Add failing JSON purity assertion in tests/create_new_feature_warning_stream_regression.ps1"
Task: "T009 [US1] Add failing JSON parseability assertion in tests/create_new_feature_warning_stream_regression.ps1"
```

## Parallel Example: User Story 2

```bash
Task: "T014 [US2] Add failing warning visibility assertion in tests/create_new_feature_warning_stream_regression.ps1"
Task: "T015 [US2] Add failing ACTION/key-value stability assertion in tests/create_new_feature_warning_stream_regression.ps1"
```

## Parallel Example: User Story 3

```bash
Task: "T020 [US3] Add failing docs keyword assertions in tests/validate_create_new_feature_warning_docs.ps1"
Task: "T021 [US3] Update quickstart expectations in specs/011-json-warning-purity/quickstart.md"
```

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete US1 (Phase 3).
3. Validate US1 independently using regression script.

### Incremental Delivery

1. Deliver US1 for machine-read JSON stability.
2. Deliver US2 to protect human-readable warning behavior.
3. Deliver US3 for documentation and traceability consistency.

