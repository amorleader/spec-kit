# Feature Specification: Harden Quality Runner with Per-Script Timeout Guard

**Feature Branch**: `019-runner-timeout-guard`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Harden quality runner with per-script timeout guard"

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

### User Story 1 - 超时防护执行 (Priority: P1)

作为维护者，我希望 `run_all_quality_checks.ps1` 支持单脚本超时防护，
这样当某个检查脚本卡死时，聚合器不会无限阻塞。

**Why this priority**: 这是聚合可用性的核心保障，直接影响 CI 是否能收敛。

**Independent Test**: 使用一个故意长时间睡眠的测试脚本运行聚合器并设置超时阈值，验证命令在预期时间内结束并继续输出汇总。

**Acceptance Scenarios**:

1. **Given** 存在长时间不返回的子脚本，**When** 以 `-PerScriptTimeoutSec` 运行聚合器，**Then** 该子脚本被标记为超时失败且主进程继续执行后续脚本。
2. **Given** 所有子脚本都在阈值内完成，**When** 开启超时参数，**Then** 聚合行为与未开启时一致。

---

### User Story 2 - 汇总可观测性增强 (Priority: P2)

作为开发者，我希望文本和 JSON 汇总都清晰反映超时结果，
便于快速定位是普通失败还是超时失败。

**Why this priority**: 只有清晰诊断信息才能让超时机制真正可运维。

**Independent Test**: 运行一次包含超时脚本的聚合并检查文本输出、JSON 输出中都有超时标识和统计字段。

**Acceptance Scenarios**:

1. **Given** 出现超时脚本，**When** 查看文本输出，**Then** 能看到 TIMEOUT 标签和超时计数。
2. **Given** 出现超时脚本，**When** 使用 `-Json` 模式，**Then** `RESULTS` 中可识别该脚本为超时并在顶层有超时统计字段。

---

### User Story 3 - 文档与回归门禁 (Priority: P3)

作为文档与测试维护者，我希望新增超时能力有对应回归与文档校验，
确保后续重构不会破坏 CLI 契约。

**Why this priority**: 这是防回归的长期保障，避免超时逻辑在后续迭代中失效。

**Independent Test**: 运行新增超时回归脚本与 docs validator，均通过。

**Acceptance Scenarios**:

1. **Given** 019 文档完整，**When** 运行 docs validator，**Then** 超时参数、输出契约、示例命令都被验证。
2. **Given** 回归脚本存在超时场景，**When** 执行回归，**Then** 能稳定验证超时与非超时两条路径。

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- `-PerScriptTimeoutSec` 传入 `0`、负数或非数字时如何处理。
- 子脚本超时后强制终止失败，是否影响后续脚本调度。
- 在 `-IncludeDocsOnly` 下超时策略是否同样生效且不改变原有筛选范围。

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: `tests/run_all_quality_checks.ps1` MUST support `-PerScriptTimeoutSec` (默认 `0` 表示不启用超时)。
- **FR-002**: 启用超时时，任一子脚本超过阈值 MUST 被标记为失败且失败原因可识别为 TIMEOUT。
- **FR-003**: 子脚本超时后，聚合器 MUST 继续执行后续脚本并输出完整汇总。
- **FR-004**: `-Json` 输出 MUST 包含超时统计字段（如 `TIMED_OUT_SCRIPTS`）且保持既有字段兼容。
- **FR-005**: 文本输出 MUST 包含可读超时标识并与最终 PASSED/FAILED 状态一致。
- **FR-006**: MUST 新增超时场景回归脚本覆盖成功、超时、禁用超时三类路径。
- **FR-007**: MUST 新增文档校验脚本，验证 spec/quickstart/contract 对超时能力描述一致。

## Constitution Alignment *(mandatory)*

<!--
  ACTION REQUIRED: Confirm alignment with constitutional requirements.
  Keep this section concise and concrete.
-->

- **CA-001 Spec Traceability**: US1→FR-001/FR-002/FR-003，US2→FR-004/FR-005，US3→FR-006/FR-007。
- **CA-002 CLI Contract Impact**: 新增可选参数 `-PerScriptTimeoutSec`，默认行为不变；文本/JSON 仅增量字段与标识。
- **CA-003 Test-First Plan**: 先补超时回归与 docs validator（先红后绿），再改聚合器实现。
- **CA-004 Boundary Coverage**: 覆盖超时阈值边界、docs-only 模式、JSON 字段兼容。
- **CA-005 Observability & Versioning**: 增加 TIMEOUT 诊断信息，语义版本为 PATCH。

### Key Entities *(include if feature involves data)*

- **ScriptRunResult**: 单脚本执行结果，包含脚本名、退出码、状态、是否超时、耗时。
- **TimeoutSummary**: 聚合汇总中的超时计数与超时脚本列表。

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: 在存在超时子脚本时，聚合命令总耗时不超过 `超时阈值 + 20s`。
- **SC-002**: 超时场景下 `RESULTS` 和文本输出都能明确识别 TIMEOUT。
- **SC-003**: 未启用超时参数时，现有回归脚本结果与 018 基线一致。
- **SC-004**: 新增超时回归与 docs validator 可纳入 `run_all_quality_checks` 聚合执行。
