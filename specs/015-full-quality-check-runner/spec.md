# Feature Specification: Add Full Quality Check Runner

**Feature Branch**: `015-full-quality-check-runner`  
**Created**: 2026-03-06  
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - 一键运行全部回归 (Priority: P1)
作为维护者，我希望一条命令运行全部 `*_regression.ps1`，并输出逐项 PASS/FAIL，
减少手工逐个执行脚本的时间与漏检风险。

**Independent Test**: 运行 `tests/run_all_quality_checks.ps1`，看到每个回归脚本都有 RUN/PASS 行。

### User Story 2 - 一键运行文档校验 (Priority: P2)
作为维护者，我希望同一脚本继续运行全部 `validate_*_docs.ps1`，并在末尾给出总结果。

**Independent Test**: 运行脚本后，所有文档校验脚本都被执行并有汇总结果。

### User Story 3 - 输出可读且可诊断 (Priority: P3)
作为排障人员，我希望聚合输出不被 ErrorRecord 噪声污染，并保留每个脚本退出码。

**Independent Test**: 输出中出现清晰的 `--- RUN/--- PASS/--- FAIL` 区块和失败列表。

## Requirements

### Functional Requirements
- **FR-001**: 新增聚合脚本必须发现并执行 `tests/*_regression.ps1`。
- **FR-002**: 聚合脚本必须发现并执行 `tests/validate_*_docs.ps1`。
- **FR-003**: 任一脚本失败时聚合脚本返回非 0，并汇总失败项与退出码。
- **FR-004**: 提供 `-IncludeDocsOnly` 模式，仅执行文档校验。

## Constitution Alignment

- **CA-001**: US1→FR-001，US2→FR-002，US3→FR-003。
- **CA-002**: 无生产 CLI 变更，仅测试工具链增强。
- **CA-003**: 先实现脚本，再通过实跑验证全量通过。
- **CA-004**: 覆盖成功与失败汇总分支。
- **CA-005**: SemVer PATCH，增强开发体验。

## Success Criteria

- **SC-001**: `tests/run_all_quality_checks.ps1` 可执行并完成全量检查。
- **SC-002**: 全量通过时输出 `run_all_quality_checks: PASSED`。
- **SC-003**: 失败时输出失败脚本清单并返回非 0。
