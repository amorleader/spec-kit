# Tasks: Improve check-prerequisites Output Consistency

**Input**: Design documents from `/specs/004-improve-check-prerequisites/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: 本特性在规格中要求测试优先，包含回归测试任务并要求先失败后实现。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 建立输出一致性验证所需的测试与文档骨架。

- [x] T001 Create regression test file scaffold in tests/check_prerequisites_regression.ps1
- [x] T002 [P] Create fixture directory for prerequisite scenarios in tests/fixtures/check-prerequisites/
- [x] T003 [P] Add base contract notes in specs/004-improve-check-prerequisites/contracts/check-prerequisites-output-contract.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 建立所有用户故事共用的断言与场景助手。

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Add JSON field assertion helper in tests/helpers/assert_check_prerequisites_json.ps1
- [x] T005 [P] Add scenario workspace helper in tests/helpers/check_prerequisites_test_helper.ps1
- [x] T006 [P] Add failure-mode catalog in specs/004-improve-check-prerequisites/contracts/failure-mode-catalog.md

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Stable JSON Contract (Priority: P1) 🎯 MVP

**Goal**: `check-prerequisites -Json` 在关键场景下输出稳定字段与类型。

**Independent Test**: 运行回归脚本验证 `FEATURE_DIR` 与 `AVAILABLE_DOCS` 始终存在，且 `AVAILABLE_DOCS` 永远是数组。

### Tests for User Story 1 ⚠️

- [x] T007 [P] [US1] Add failing test for stable required JSON fields in tests/check_prerequisites_regression.ps1
- [x] T008 [P] [US1] Add failing test for AVAILABLE_DOCS array type in tests/check_prerequisites_regression.ps1

### Implementation for User Story 1

- [x] T009 [US1] Normalize success JSON output fields in .specify/scripts/powershell/check-prerequisites.ps1
- [x] T010 [US1] Enforce AVAILABLE_DOCS array initialization in .specify/scripts/powershell/check-prerequisites.ps1
- [x] T011 [US1] Update JSON success examples in specs/004-improve-check-prerequisites/contracts/check-prerequisites-output-contract.md
- [x] T012 [US1] Record US1 command evidence in specs/004-improve-check-prerequisites/contracts/check-prerequisites-output-contract.md

**Checkpoint**: User Story 1 should provide stable JSON output contract for automation consumers

---

## Phase 4: User Story 2 - Predictable Error Signaling (Priority: P2)

**Goal**: 缺失前置条件时返回一致失败退出码与可操作错误信息。

**Independent Test**: 触发缺失 plan/tasks 场景，验证非 0 退出码与错误文本可定位根因。

### Tests for User Story 2 ⚠️

- [x] T013 [P] [US2] Add failing test for missing required plan error path in tests/check_prerequisites_regression.ps1
- [x] T014 [P] [US2] Add failing test for require-tasks failure semantics in tests/check_prerequisites_regression.ps1

### Implementation for User Story 2

- [x] T015 [US2] Standardize failure exit codes and messages in .specify/scripts/powershell/check-prerequisites.ps1
- [x] T016 [US2] Ensure -RequireTasks and -IncludeTasks interaction is deterministic in .specify/scripts/powershell/check-prerequisites.ps1
- [x] T017 [US2] Document failure semantics in specs/004-improve-check-prerequisites/contracts/failure-mode-catalog.md
- [x] T018 [US2] Capture US2 failure evidence in specs/004-improve-check-prerequisites/contracts/failure-mode-catalog.md

**Checkpoint**: User Story 2 should provide deterministic failure behavior for CI and scripts

---

## Phase 5: User Story 3 - Documentation Alignment (Priority: P3)

**Goal**: 文档、契约和脚本行为保持一致，支持自助接入。

**Independent Test**: 仅按 quickstart/contract 文档执行即可复现成功与失败语义。

### Tests for User Story 3 ⚠️

- [x] T019 [P] [US3] Add docs consistency check script in tests/validate_check_prerequisites_docs.ps1

### Implementation for User Story 3

- [x] T020 [US3] Update quickstart command examples and expected outputs in specs/004-improve-check-prerequisites/quickstart.md
- [x] T021 [US3] Finalize research decisions and tradeoffs in specs/004-improve-check-prerequisites/research.md
- [x] T022 [US3] Add docs-to-behavior traceability section in specs/004-improve-check-prerequisites/contracts/check-prerequisites-output-contract.md
- [x] T023 [US3] Add final command evidence matrix in specs/004-improve-check-prerequisites/contracts/check-prerequisites-output-contract.md

**Checkpoint**: User Story 3 should provide complete and consistent operational documentation

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 全局收口、回归验证和发布影响说明。

- [x] T024 [P] Normalize terminology across spec and contracts in specs/004-improve-check-prerequisites/spec.md
- [x] T025 Run full regression and docs validation scripts; log outputs in specs/004-improve-check-prerequisites/contracts/check-prerequisites-output-contract.md
- [x] T026 Update semver impact and release note in specs/004-improve-check-prerequisites/plan.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - 可并行策略：US2 和 US3 在 US1 稳定后并行
  - 可串行策略：P1 → P2 → P3
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: 无依赖，是 MVP
- **User Story 2 (P2)**: 依赖 US1 输出契约稳定
- **User Story 3 (P3)**: 依赖 US1/US2 行为定稿

### Dependency Graph

- Phase1 → Phase2 → US1 → (US2 || US3) → Phase6

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Script behavior update before contract/doc updates
- Contract/doc updates before final evidence capture

### Parallel Opportunities

- Setup: `T002`, `T003`
- Foundational: `T005`, `T006`
- US1 Tests: `T007`, `T008`
- US2 Tests: `T013`, `T014`
- US3: `T019` 可与 `T020` 并行

---

## Parallel Example: User Story 1

```bash
Task: "T007 [US1] Add failing test for stable required JSON fields in tests/check_prerequisites_regression.ps1"
Task: "T008 [US1] Add failing test for AVAILABLE_DOCS array type in tests/check_prerequisites_regression.ps1"
```

## Parallel Example: User Story 2

```bash
Task: "T013 [US2] Add failing test for missing required plan error path in tests/check_prerequisites_regression.ps1"
Task: "T014 [US2] Add failing test for require-tasks failure semantics in tests/check_prerequisites_regression.ps1"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: 确认 JSON 字段/类型稳定

### Incremental Delivery

1. 先交付 US1（稳定成功输出）
2. 再交付 US2（稳定失败语义）
3. 最后交付 US3（文档契约一致）
4. Polish 阶段做统一验证与发布备注

### Parallel Team Strategy

1. 开发者 A：`.specify/scripts/powershell/check-prerequisites.ps1` 行为修复
2. 开发者 B：`tests/*` 回归脚本
3. 开发者 C：`specs/004.../contracts` 与 `quickstart.md`

---

## Notes

- 所有任务均使用严格 checklist 格式：`- [ ] Txxx [P?] [US?] 描述 + 文件路径`
- Setup/Foundational/Polish 不加 `[USx]`
- User Story phase 任务必须带 `[USx]`
- 每个任务描述均包含明确文件路径，可直接被 LLM 执行
