# Feature Specification: Stabilize JSON Pure Check Output

**Feature Branch**: `883-stabilize-json-pure`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Stabilize JSON pure check output"

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

### User Story 1 - JSON 模式输出纯净 (Priority: P1)

作为自动化调用方，我希望脚本在 `-Json` 模式下只输出单个 JSON 文档，
这样管道消费时不会被警告或说明文本污染。

**Why this priority**: 这是机器可消费输出的基础，直接影响 CI 稳定性。

**Independent Test**: 对目标脚本启用 `-Json` 并在正常与失败场景验证输出首字符为 `{`，且可直接 `ConvertFrom-Json`。

**Acceptance Scenarios**:

1. **Given** `-Json` 模式，**When** 脚本成功执行，**Then** stdout 仅包含 JSON 且可解析。
2. **Given** `-Json` 模式，**When** 触发失败路径，**Then** 仍返回可解析 JSON 错误对象，不混入非 JSON 文本。

---

### User Story 2 - 错误语义一致化 (Priority: P2)

作为维护者，我希望 JSON 错误输出字段在相关脚本间一致，
这样回归测试与上游调用逻辑无需按脚本分支处理。

**Why this priority**: 统一错误契约可减少脚本间适配成本与误判。

**Independent Test**: 验证目标脚本在失败时均提供一致核心字段（如 `ERROR`、`STATUS` 或等价约定字段）。

**Acceptance Scenarios**:

1. **Given** 两个以上脚本失败路径，**When** 输出 JSON，**Then** 核心错误字段命名与语义一致。

---

### User Story 3 - 文档与门禁固化 (Priority: P3)

作为项目协作者，我希望 JSON 纯净输出要求被文档化并有独立门禁，
这样后续变更不会回退到混合输出。

**Why this priority**: 通过文档+回归门禁将约束长期化。

**Independent Test**: docs validator 与 JSON 纯净回归脚本都通过，并纳入聚合执行。

**Acceptance Scenarios**:

1. **Given** 特性文档存在，**When** 执行 docs validator，**Then** JSON 纯净约束条款全部命中。

---

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- 目标脚本在非 feature 分支触发失败时，`-Json` 输出仍必须保持纯 JSON。
- 路径缺失、Git 不可用等前置错误发生时，不得输出混杂文本到 stdout。
- `Write-Warning` 或 `Write-Host` 的历史调用不得污染 JSON 模式输出。

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: `check-prerequisites.ps1` 在 `-Json` 模式 MUST 输出单个可解析 JSON 文档。
- **FR-002**: `setup-plan.ps1` 在 `-Json` 模式 MUST 输出单个可解析 JSON 文档。
- **FR-003**: `create-new-feature.ps1` 在 `-Json` 模式 MUST 保持 JSON 纯净，不混入说明文本。
- **FR-004**: 失败路径 JSON 输出 MUST 提供一致核心错误字段语义。
- **FR-005**: MUST 新增 JSON 纯净回归脚本覆盖成功与失败两类路径。
- **FR-006**: MUST 新增 docs validator 校验纯净输出约束已写入 spec/plan/contracts/quickstart。

## Constitution Alignment *(mandatory)*

<!--
  ACTION REQUIRED: Confirm alignment with constitutional requirements.
  Keep this section concise and concrete.
-->

- **CA-001 Spec Traceability**: US1→FR-001/FR-002/FR-003，US2→FR-004，US3→FR-005/FR-006。
- **CA-002 CLI Contract Impact**: 无新增参数；仅约束 `-Json` 输出纯净与错误对象一致性。
- **CA-003 Test-First Plan**: 先写 JSON 纯净回归与 docs validator，再修改脚本输出路径。
- **CA-004 Boundary Coverage**: 覆盖成功路径、失败路径、缺少 feature dir、非 feature 分支等场景。
- **CA-005 Observability & Versioning**: 输出契约稳定化，版本影响 PATCH。

### Key Entities *(include if feature involves data)*

- **JsonCommandResult**: 脚本 JSON 输出对象，包含状态、关键字段与错误信息。
- **JsonPurityCheckResult**: 纯净输出检测结果，记录是否可解析及污染来源。

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: 目标脚本 `-Json` 模式下输出 100% 可 `ConvertFrom-Json`。
- **SC-002**: 失败路径不出现 JSON 之外的 stdout 文本污染。
- **SC-003**: 新增 JSON 纯净回归脚本稳定通过并纳入聚合。
