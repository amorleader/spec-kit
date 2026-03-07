# Feature Specification: Prevent setup-plan Overwrite

**Feature Branch**: `003-prevent-setup-plan`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Prevent setup-plan from overwriting existing plan content"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Protect Existing plan.md (Priority: P1)

作为维护者，我希望当 `plan.md` 已存在并包含人工内容时，`setup-plan.ps1` 不会默认覆盖它，以免丢失已完成规划。

**Why this priority**: 这是数据安全问题，会直接导致计划文档回退，必须最优先修复。

**Independent Test**: 在已有自定义 `plan.md` 的 feature 目录执行默认模式 `setup-plan.ps1 -Json`，文件内容保持不变且命令返回成功。

**Acceptance Scenarios**:

1. **Given** `plan.md` 已存在且内容非模板，**When** 执行 `setup-plan.ps1 -Json`, **Then** 脚本不覆盖该文件并返回现有路径。
2. **Given** `plan.md` 不存在，**When** 执行 `setup-plan.ps1 -Json`, **Then** 脚本仍会复制模板并返回路径。

---

### User Story 2 - Explicit Overwrite Control (Priority: P2)

作为自动化执行者，我希望可以通过显式参数控制是否覆盖 `plan.md`，让初始化与更新流程都可预测。

**Why this priority**: 在保留安全默认值的同时保留可控覆盖能力，兼顾兼容性。

**Independent Test**: 使用 `-Force`（强制模式）执行 `setup-plan.ps1`，在确认场景下能覆盖文件；默认模式不覆盖。

**Acceptance Scenarios**:

1. **Given** 需要重新初始化计划模板，**When** 以显式覆盖参数运行 `setup-plan.ps1`, **Then** 文件按预期被覆盖并有清晰提示。

---

### User Story 3 - Document Safe Behavior (Priority: P3)

作为团队成员，我希望文档和契约明确说明 `setup-plan` 的覆盖策略，避免误用。

**Why this priority**: 规范清晰能减少误操作，但依赖功能本体先稳定。

**Independent Test**: 仅查看文档即可判断默认行为、覆盖参数、错误提示和兼容性策略。

**Acceptance Scenarios**:

1. **Given** 新成员阅读 quickstart/contract，**When** 执行命令，**Then** 行为与文档一致且不会出现意外覆盖。

---

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- 当 `plan.md` 存在但为空文件时，是否视为可覆盖对象必须定义清晰。
- 当 `plan.md` 存在且只读时，脚本应返回可操作错误信息。
- 当 `-Force` 与新旧参数并存时，优先级规则必须稳定且可预测（默认模式优先安全保留）。

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: `setup-plan.ps1` MUST NOT overwrite existing `plan.md` by default.
- **FR-002**: `setup-plan.ps1` MUST continue creating `plan.md` from template when file is absent.
- **FR-003**: System MUST provide an explicit overwrite option (e.g., `-Force`) for deliberate replacement.
- **FR-004**: System MUST emit clear stdout/stderr message indicating whether file was created, preserved, or overwritten.
- **FR-005**: JSON output contract fields (`FEATURE_SPEC`, `IMPL_PLAN`, `SPECS_DIR`, `BRANCH`, `HAS_GIT`) MUST remain backward compatible.
- **FR-006**: Documentation and contracts MUST describe the safe default and explicit overwrite behavior.
- **FR-007**: Behavior MUST be validated by script-level checks covering default preserve path and forced overwrite path.

## Constitution Alignment *(mandatory)*

<!--
  ACTION REQUIRED: Confirm alignment with constitutional requirements.
  Keep this section concise and concrete.
-->

- **CA-001 Spec Traceability**: US1→FR-001/FR-002/FR-004，US2→FR-003/FR-005/FR-007，US3→FR-006。
- **CA-002 CLI Contract Impact**: `setup-plan.ps1` 增加显式覆盖参数，默认行为改为保留现有 `plan.md`。
- **CA-003 Test-First Plan**: 先编写失败用例（已有 `plan.md` 仍被覆盖），再实现保护逻辑，最后通过。
- **CA-004 Boundary Coverage**: 覆盖脚本参数边界（无参数/覆盖参数）与 JSON 输出兼容性。
- **CA-005 Observability & Versioning**: 增加行为提示日志；属于行为修正，语义版本影响为 PATCH。

### Key Entities *(include if feature involves data)*

- **PlanFileState**: 表示 `plan.md` 当前状态（missing/existing/readonly）。
- **SetupPlanInvocation**: 表示一次 `setup-plan` 调用（参数、分支、输出、结果动作）。

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: 在已有 `plan.md` 的 10 次重复执行中，默认模式覆盖次数为 0。
- **SC-002**: 在缺失 `plan.md` 的场景下，模板创建成功率为 100%。
- **SC-003**: 开启显式覆盖参数时，覆盖行为可预测且输出提示准确率为 100%。
- **SC-004**: `setup-plan -Json` 输出字段在修改前后保持兼容，无字段丢失。
