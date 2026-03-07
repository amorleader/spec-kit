# Feature Specification: Stabilize check-prerequisites Regression Across Branches

**Feature Branch**: `012-stabilize-check-prerequisites`  
**Created**: 2026-03-06  
**Status**: Draft  

## User Scenarios & Testing

### User Story 1 - 回归脚本与当前分支解耦 (Priority: P1)

作为维护脚本测试的开发者，我希望 `tests/check_prerequisites_regression.ps1` 不依赖当前 git 分支，
这样在任意 feature 分支执行都能得到一致结果。

**Why this priority**: 当前回归会在非 `004-*` 分支误判失败，直接影响自动化稳定性。

**Independent Test**: 在 `012-*` 分支执行 `tests/check_prerequisites_regression.ps1`，测试应全部通过。

**Acceptance Scenarios**:

1. **Given** 当前分支不是 `004-*`，**When** 运行回归脚本，**Then** US1/US2 用例仍通过。
2. **Given** 缺少 `plan.md`，**When** 执行 check-prerequisites，**Then** 回归脚本捕获非 0 退出码与错误提示。

---

### User Story 2 - 临时环境变量不泄漏 (Priority: P2)

作为同一终端中连续运行多个回归的开发者，我希望脚本在使用 `SPECIFY_FEATURE` 后恢复原值，
避免污染后续测试上下文。

**Why this priority**: 环境变量泄漏会造成链式误报，排查成本高。

**Independent Test**: 运行回归前后读取 `SPECIFY_FEATURE`，值保持一致（或都为空）。

**Acceptance Scenarios**:

1. **Given** 运行前存在 `SPECIFY_FEATURE`，**When** 脚本结束，**Then** 变量恢复原值。

---

### User Story 3 - 文档记录分支无关策略 (Priority: P3)

作为项目维护者，我希望 regression 文档注明“固定目标 feature + 环境恢复”策略，
便于后续新增回归复用该模式。

**Why this priority**: 降低同类问题重复出现概率。

**Independent Test**: 文档校验脚本或人工检查能看到该策略说明。

**Acceptance Scenarios**:

1. **Given** 查看特性文档，**When** 查阅 contracts/quickstart，**Then** 能看到分支无关执行说明。

### Edge Cases

- 运行前 `SPECIFY_FEATURE` 未设置，应在 finally 中恢复为空。
- 目标 feature 目录缺失时，脚本应尽早给出可操作错误。

## Requirements

### Functional Requirements

- **FR-001**: 回归脚本 MUST 在执行前显式设置目标 `SPECIFY_FEATURE`，避免依赖当前分支。
- **FR-002**: 回归脚本 MUST 在结束后恢复 `SPECIFY_FEATURE` 原状态。
- **FR-003**: 缺失 `plan.md` 与缺失 `tasks.md` 的失败断言 MUST 继续生效。
- **FR-004**: 相关文档 MUST 记录分支无关测试策略和验证命令。

## Constitution Alignment

- **CA-001 Spec Traceability**: US1→FR-001/FR-003，US2→FR-002，US3→FR-004。
- **CA-002 CLI Contract Impact**: 不改变产品 CLI，仅修复回归执行上下文。
- **CA-003 Test-First Plan**: 先在非 004 分支运行现有回归拿失败，再实现修复后回归通过。
- **CA-004 Boundary Coverage**: 覆盖 plan/tasks 缺失边界与环境变量恢复边界。
- **CA-005 Observability & Versioning**: 版本影响 PATCH，输出仍保留可定位失败信息。

## Success Criteria

### Measurable Outcomes

- **SC-001**: 在任意 `###-*` feature 分支运行 `tests/check_prerequisites_regression.ps1` 均通过。
- **SC-002**: 回归后 `SPECIFY_FEATURE` 与执行前保持一致。
- **SC-003**: CI/本地不再出现“Expected non-zero exit code when plan.md is missing.”误报。
