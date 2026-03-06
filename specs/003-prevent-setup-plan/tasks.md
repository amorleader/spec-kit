# Tasks: Prevent setup-plan Overwrite

**Input**: Design documents from `/specs/003-prevent-setup-plan/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: 本特性已在规格中显式要求测试优先，因此包含测试任务并要求先失败后实现。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 建立脚本修复与验证所需的目录与基线测试骨架。

- [x] T001 Create test fixture directory in tests/fixtures/setup-plan/
- [x] T002 Create baseline existing-plan fixture in tests/fixtures/setup-plan/existing-plan.md
- [x] T003 [P] Create missing-plan fixture metadata in tests/fixtures/setup-plan/missing-plan.json
- [x] T004 [P] Create overwrite verification notes in specs/003-prevent-setup-plan/contracts/overwrite-verification-notes.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 完成所有用户故事共享的阻塞前置条件。

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Add setup-plan regression test harness script in tests/setup_plan_regression.ps1
- [x] T006 [P] Add helper for temp feature workspace creation in tests/helpers/setup_plan_test_helper.ps1
- [x] T007 [P] Define JSON contract assertion helper in tests/helpers/assert_setup_plan_json.ps1
- [x] T008 Add command evidence template in specs/003-prevent-setup-plan/contracts/command-evidence-template.md
- [x] T009 Add failure-mode catalog for readonly and missing states in specs/003-prevent-setup-plan/contracts/failure-mode-catalog.md

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Protect Existing plan.md (Priority: P1) 🎯 MVP

**Goal**: 默认执行 `setup-plan` 时保护已存在的 `plan.md`，避免覆盖人工内容。

**Independent Test**: 在 existing fixture 下先运行失败测试，再实现后验证 `plan.md` 内容不变且命令成功返回。

### Tests for User Story 1 ⚠️

- [x] T010 [P] [US1] Add failing test for existing plan preservation in tests/setup_plan_regression.ps1
- [x] T011 [P] [US1] Add failing test for missing plan creation path in tests/setup_plan_regression.ps1

### Implementation for User Story 1

- [x] T012 [US1] Implement default preserve behavior in .specify/scripts/powershell/setup-plan.ps1
- [x] T013 [US1] Emit explicit action message (preserved/created) in .specify/scripts/powershell/setup-plan.ps1
- [x] T014 [US1] Update preserve behavior notes in specs/003-prevent-setup-plan/contracts/setup-plan-safe-overwrite-contract.md
- [x] T015 [US1] Record US1 command evidence in specs/003-prevent-setup-plan/contracts/command-evidence-template.md

**Checkpoint**: User Story 1 should protect existing plan.md while preserving creation behavior

---

## Phase 4: User Story 2 - Explicit Overwrite Control (Priority: P2)

**Goal**: 增加显式覆盖参数，让“可控覆盖”成为受控行为。

**Independent Test**: 在 existing fixture 下使用覆盖参数可成功覆盖，不带参数不覆盖；JSON 字段保持兼容。

### Tests for User Story 2 ⚠️

- [x] T016 [P] [US2] Add failing test for explicit overwrite flag path in tests/setup_plan_regression.ps1
- [x] T017 [P] [US2] Add failing test for JSON output backward compatibility in tests/setup_plan_regression.ps1

### Implementation for User Story 2

- [x] T018 [US2] Add explicit overwrite parameter handling in .specify/scripts/powershell/setup-plan.ps1
- [x] T019 [US2] Preserve JSON output field contract in .specify/scripts/powershell/setup-plan.ps1
- [x] T020 [US2] Update overwrite parameter contract in specs/003-prevent-setup-plan/contracts/setup-plan-safe-overwrite-contract.md
- [x] T021 [US2] Update failure scenarios for force/non-force modes in specs/003-prevent-setup-plan/contracts/failure-mode-catalog.md

**Checkpoint**: User Story 2 should enable controlled overwrite with stable output contract

---

## Phase 5: User Story 3 - Document Safe Behavior (Priority: P3)

**Goal**: 文档化安全默认行为与覆盖策略，保证团队可复现和可交接。

**Independent Test**: 仅依赖 quickstart/contract 文档即可正确选择默认与覆盖模式并解释失败场景。

### Tests for User Story 3 ⚠️

- [x] T022 [P] [US3] Add docs consistency check script in tests/validate_setup_plan_docs.ps1

### Implementation for User Story 3

- [x] T023 [US3] Update quickstart with safe-default and force examples in specs/003-prevent-setup-plan/quickstart.md
- [x] T024 [US3] Update research decisions with final parameter choice in specs/003-prevent-setup-plan/research.md
- [x] T025 [US3] Add traceability section for docs-to-behavior mapping in specs/003-prevent-setup-plan/contracts/overwrite-verification-notes.md
- [x] T026 [US3] Record final validation evidence in specs/003-prevent-setup-plan/contracts/command-evidence-template.md

**Checkpoint**: User Story 3 should provide complete, self-serve operational guidance

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 全局一致性、最终验证和发布说明。

- [x] T027 [P] Normalize terminology for preserve/overwrite actions in specs/003-prevent-setup-plan/spec.md
- [x] T028 Run full regression checks and log outputs in specs/003-prevent-setup-plan/contracts/command-evidence-template.md
- [x] T029 Update semver impact and release note in specs/003-prevent-setup-plan/plan.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - 可并行策略：US2/US3 在 US1 完成后并行推进
  - 可串行策略：P1 → P2 → P3
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: 无其他故事依赖，是 MVP
- **User Story 2 (P2)**: 依赖 US1 默认保护行为已稳定
- **User Story 3 (P3)**: 依赖 US1/US2 行为最终确定

### Dependency Graph

- Phase1 → Phase2 → US1 → (US2 || US3) → Phase6

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Script behavior update before contract/docs updates
- Contract/docs updates before final evidence capture

### Parallel Opportunities

- Setup: `T003`, `T004`
- Foundational: `T006`, `T007`
- US1 Tests: `T010`, `T011`
- US2 Tests: `T016`, `T017`
- US3: `T022` 可与文档更新并行

---

## Parallel Example: User Story 1

```bash
Task: "T010 [US1] Add failing test for existing plan preservation in tests/setup_plan_regression.ps1"
Task: "T011 [US1] Add failing test for missing plan creation path in tests/setup_plan_regression.ps1"
```

## Parallel Example: User Story 2

```bash
Task: "T016 [US2] Add failing test for explicit overwrite flag path in tests/setup_plan_regression.ps1"
Task: "T017 [US2] Add failing test for JSON output backward compatibility in tests/setup_plan_regression.ps1"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: 验证默认模式不覆盖 existing plan

### Incremental Delivery

1. 先交付 US1（消除数据覆盖风险）
2. 再交付 US2（加入受控覆盖能力）
3. 最后交付 US3（完善文档与交接）
4. Polish 阶段做统一验证与发布备注

### Parallel Team Strategy

1. 开发者 A：`.specify/scripts/powershell/setup-plan.ps1` 逻辑
2. 开发者 B：`tests/*` 回归验证
3. 开发者 C：`specs/003-prevent-setup-plan/contracts/*` 与 `quickstart.md`

---

## Notes

- 所有任务均使用严格 checklist 格式：`- [ ] Txxx [P?] [US?] 描述 + 文件路径`
- Setup/Foundational/Polish 不加 `[USx]`
- User Story phase 任务必须带 `[USx]`
- 每个任务描述均包含明确文件路径，可直接被 LLM 执行
