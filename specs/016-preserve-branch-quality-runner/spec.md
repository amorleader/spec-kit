# Feature Specification: Preserve Current Branch in Full Quality Check Runner

**Feature Branch**: `016-preserve-branch-quality-runner`  
**Created**: 2026-03-06  
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - 运行后恢复当前分支 (Priority: P1)
作为开发者，我希望执行 `tests/run_all_quality_checks.ps1` 后仍停留在启动时的分支，
避免聚合脚本调用的子回归切分支导致工作上下文漂移。

**Independent Test**: 执行前后分别读取 `git rev-parse --abbrev-ref HEAD`，两者一致。

### User Story 2 - 恢复失败可观测 (Priority: P2)
作为维护者，我希望当恢复分支失败时有明确 warning，便于及时处理。

**Independent Test**: 恢复失败时输出 `failed to restore branch` 警告。

### User Story 3 - 现有汇总契约不变 (Priority: P3)
作为调用者，我希望 `RUN/PASS/FAIL` 与最终 `PASSED/FAILED` 汇总格式保持不变。

**Independent Test**: 现有全量质量检查结果仍可解析且通过。

## Requirements

### Functional Requirements
- **FR-001**: 聚合脚本必须在执行前记录当前分支（若存在 git 仓库）。
- **FR-002**: 聚合脚本必须在 finally 阶段尝试恢复到原始分支。
- **FR-003**: 恢复成功/失败必须输出可读消息（成功信息或 warning）。
- **FR-004**: 不改变现有脚本发现规则与汇总输出契约。

## Constitution Alignment

- **CA-001**: US1→FR-001/FR-002，US2→FR-003，US3→FR-004。
- **CA-002**: 仅测试工具脚本变更，无生产 CLI 行为变更。
- **CA-003**: 先实现后通过前后分支一致性验证。
- **CA-004**: 覆盖 git 仓库可恢复与不可恢复分支两条路径。
- **CA-005**: SemVer PATCH，提升开发流程稳定性。

## Success Criteria

- **SC-001**: 全量执行后当前分支与执行前一致。
- **SC-002**: 质量检查最终汇总仍为 `run_all_quality_checks: PASSED`（在当前基线）。
- **SC-003**: 恢复失败时输出 warning 且不吞掉主流程结果。
