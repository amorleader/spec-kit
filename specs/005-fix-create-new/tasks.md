# Tasks: Fix create-new-feature Argument Parsing Consistency

**Input**: Design documents from `/specs/005-fix-create-new/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: 本特性要求测试优先，包含回归测试任务并要求先失败后实现。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 建立参数解析回归所需的测试与契约骨架。

- [x] T001 Create regression script scaffold in tests/create_new_feature_regression.ps1
- [x] T002 [P] Create test fixtures directory in tests/fixtures/create-new-feature/
- [x] T003 [P] Add base argument contract notes in specs/005-fix-create-new/contracts/create-new-feature-arg-contract.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 建立所有用户故事共享的测试 helper 与失败场景文档。

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Add JSON contract assertion helper in tests/helpers/assert_create_new_feature_json.ps1
- [x] T005 [P] Add temporary workspace helper in tests/helpers/create_new_feature_test_helper.ps1
- [x] T006 [P] Add parsing failure-mode catalog in specs/005-fix-create-new/contracts/failure-mode-catalog.md

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Accept Natural CLI Invocation (Priority: P1) 🎯 MVP

**Goal**: 支持常见参数顺序（参数在前/描述在前）并稳定输出 JSON 结果。

**Independent Test**: 两种调用顺序都可成功，输出字段一致且不出现 usage 误报。

### Tests for User Story 1 ⚠️

- [x] T007 [P] [US1] Add failing test for `-Json "description"` invocation in tests/create_new_feature_regression.ps1
- [x] T008 [P] [US1] Add failing test for `"description" -Json` invocation in tests/create_new_feature_regression.ps1

### Implementation for User Story 1

- [x] T009 [US1] Normalize description parsing for mixed argument order in .specify/scripts/powershell/create-new-feature.ps1
- [x] T010 [US1] Preserve JSON output contract fields in .specify/scripts/powershell/create-new-feature.ps1
- [x] T011 [US1] Update success examples in specs/005-fix-create-new/contracts/create-new-feature-arg-contract.md
- [x] T012 [US1] Record US1 command evidence in specs/005-fix-create-new/contracts/create-new-feature-arg-contract.md

**Checkpoint**: User Story 1 should remove parameter-order usage failures for common invocations

---

## Phase 4: User Story 2 - Deterministic Option Parsing (Priority: P2)

**Goal**: `-ShortName`、`-Number`、`-Json` 与描述组合解析稳定且可预测。

**Independent Test**: 参数混排场景输出编号/分支后缀符合预期，无解析冲突。

### Tests for User Story 2 ⚠️

- [x] T013 [P] [US2] Add failing test for `-ShortName` + description parsing in tests/create_new_feature_regression.ps1
- [x] T014 [P] [US2] Add failing test for explicit `-Number` override behavior in tests/create_new_feature_regression.ps1

### Implementation for User Story 2

- [x] T015 [US2] Ensure deterministic parameter precedence in .specify/scripts/powershell/create-new-feature.ps1
- [x] T016 [US2] Keep branch numbering and naming semantics stable in .specify/scripts/powershell/create-new-feature.ps1
- [x] T017 [US2] Document deterministic parsing rules in specs/005-fix-create-new/contracts/failure-mode-catalog.md
- [x] T018 [US2] Capture US2 command evidence in specs/005-fix-create-new/contracts/failure-mode-catalog.md

**Checkpoint**: User Story 2 should make mixed option parsing deterministic and backward compatible

---

## Phase 5: User Story 3 - Update Usage & Contract Docs (Priority: P3)

**Goal**: 帮助文本、quickstart、contract 一致反映可用参数顺序与失败语义。

**Independent Test**: 仅按文档执行即可获得预期成功/失败行为。

### Tests for User Story 3 ⚠️

- [x] T019 [P] [US3] Add docs consistency check script in tests/validate_create_new_feature_docs.ps1

### Implementation for User Story 3

- [x] T020 [US3] Update quickstart with argument-order examples in specs/005-fix-create-new/quickstart.md
- [x] T021 [US3] Finalize research decisions after implementation in specs/005-fix-create-new/research.md
- [x] T022 [US3] Add docs-to-behavior traceability in specs/005-fix-create-new/contracts/create-new-feature-arg-contract.md
- [x] T023 [US3] Add final evidence matrix in specs/005-fix-create-new/contracts/create-new-feature-arg-contract.md

**Checkpoint**: User Story 3 should provide consistent and self-serve documentation

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 全局收口、回归验证、语义版本说明。

- [x] T024 [P] Normalize terminology in specs/005-fix-create-new/spec.md
- [x] T025 Run full regression and docs validation scripts; log outputs in specs/005-fix-create-new/contracts/create-new-feature-arg-contract.md
- [x] T026 Update semver impact and release note in specs/005-fix-create-new/plan.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - 可并行策略：US2/US3 在 US1 稳定后并行
  - 可串行策略：P1 → P2 → P3
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: 无依赖，是 MVP
- **User Story 2 (P2)**: 依赖 US1 解析路径稳定
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

## Notes

- 所有任务均使用严格 checklist 格式：`- [ ] Txxx [P?] [US?] 描述 + 文件路径`
- Setup/Foundational/Polish 不加 `[USx]`
- User Story phase 任务必须带 `[USx]`
- 每个任务描述均包含明确文件路径，可直接被 LLM 执行
