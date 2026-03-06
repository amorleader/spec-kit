# Feature Specification: Add JSON Summary Mode to Full Quality Check Runner

**Feature Branch**: `017-json-summary-mode`  
**Created**: 2026-03-06  
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - 机读汇总输出 (Priority: P1)
作为 CI 调用方，我希望 `run_all_quality_checks.ps1 -Json` 输出可解析 JSON 汇总，
这样可以稳定消费总数、通过数、失败数与逐脚本状态。

**Independent Test**: 运行 `-Json -IncludeDocsOnly`，输出为单个可解析 JSON 对象。

### User Story 2 - 文本模式兼容 (Priority: P2)
作为开发者，我希望默认文本模式输出不变，
继续保留 `RUN/PASS/FAIL` 与最终 `PASSED/FAILED`。

**Independent Test**: 不带 `-Json` 运行时输出格式与原先一致。

### User Story 3 - JSON 模式无噪声 (Priority: P3)
作为自动化消费者，我希望 JSON 模式不混入文本日志或分支恢复消息，
避免解析失败。

**Independent Test**: JSON 模式下输出直接 `ConvertFrom-Json` 成功。

## Requirements

### Functional Requirements
- **FR-001**: 新增 `-Json` 开关，输出汇总对象而非文本块。
- **FR-002**: JSON 对象必须包含 `TOTAL_SCRIPTS`、`FAILED_SCRIPTS`、`PASSED_SCRIPTS`、`RESULTS`、`STATUS`。
- **FR-003**: 默认文本模式行为保持兼容。
- **FR-004**: JSON 模式禁止输出额外文本噪声。

## Constitution Alignment

- **CA-001**: US1→FR-001/FR-002，US2→FR-003，US3→FR-004。
- **CA-002**: 仅测试工具脚本行为扩展，无生产 CLI 变更。
- **CA-003**: 先实现后通过 JSON/文本双模式验证。
- **CA-004**: 覆盖 IncludeDocsOnly + branch-restore 组合路径。
- **CA-005**: SemVer PATCH。

## Success Criteria

- **SC-001**: `-Json` 输出可直接解析且字段完整。
- **SC-002**: 文本模式输出与既有脚本契约一致。
- **SC-003**: JSON 模式执行后分支仍保持稳定。
