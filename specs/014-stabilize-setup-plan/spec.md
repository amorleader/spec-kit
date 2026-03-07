# Feature Specification: Stabilize setup-plan Regression Mode Expectations

**Feature Branch**: `014-stabilize-setup-plan`  
**Created**: 2026-03-06  
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - 文本模式断言与调用模式一致 (Priority: P1)

作为维护 `setup_plan_regression` 的开发者，
我希望所有 `ACTION:` 断言只针对文本模式输出执行，
从而避免 JSON 模式下出现误报。

**Why this priority**: 当前失败直接阻断回归，影响交付稳定性。

**Independent Test**: 运行 `tests/setup_plan_regression.ps1`，US1/US2 全部通过。

**Acceptance Scenarios**:
1. **Given** existing/missing/force 三种场景，**When** 文本模式运行，**Then** `ACTION:` 断言通过。
2. **Given** 同一场景，**When** JSON 模式运行，**Then** 仅检查 JSON 字段兼容。

---

### User Story 2 - JSON 兼容断言独立验证 (Priority: P2)

作为自动化调用方，我希望 JSON 字段兼容性断言独立于文本断言，
确保模式边界清晰。

**Why this priority**: 防止未来再次混淆模式语义。

**Independent Test**: 回归中 JSON 字段校验步骤单独调用 `-Json` 并可稳定解析。

**Acceptance Scenarios**:
1. **Given** 任一 setup-plan 场景，**When** JSON 模式调用，**Then** `FEATURE_SPEC/IMPL_PLAN/SPECS_DIR/BRANCH/HAS_GIT` 字段存在。

---

### User Story 3 - 无副作用回归保障 (Priority: P3)

作为维护者，我希望修复后不影响 `setup_plan_json_output_regression`，
保证 JSON 纯净契约继续成立。

**Why this priority**: 防止修复一个回归破坏另一个回归。

**Independent Test**: `tests/setup_plan_json_output_regression.ps1` 通过。

**Acceptance Scenarios**:
1. **Given** JSON 模式，**When** 运行 `setup_plan_json_output_regression`，**Then** 纯 JSON 断言通过。

### Edge Cases

- 文本断言与 JSON 断言应在同一测试文件中分离执行。
- JSON 解析失败时应保留现有可诊断失败信息。

## Requirements

### Functional Requirements

- **FR-001**: `tests/setup_plan_regression.ps1` 必须将文本 `ACTION` 断言与 JSON 字段断言分开执行。
- **FR-002**: JSON 字段断言必须在显式 `-Json` 调用下执行。
- **FR-003**: 现有 `ACTION: preserved|created|overwritten` 断言语义保持不变。
- **FR-004**: 不修改 `.specify/scripts/powershell/setup-plan.ps1` 的现有输出契约。

## Constitution Alignment

- **CA-001 Spec Traceability**: US1→FR-001/FR-003，US2→FR-002，US3→FR-004。
- **CA-002 CLI Contract Impact**: 无产品脚本行为变更，仅修复测试契约。
- **CA-003 Test-First Plan**: 先运行现有回归复现 3 个失败，再调整测试并回归通过。
- **CA-004 Boundary Coverage**: 覆盖 existing/missing/force 三场景及 text/json 双模式。
- **CA-005 Observability & Versioning**: 版本影响 PATCH，失败输出保持可诊断。

## Success Criteria

### Measurable Outcomes

- **SC-001**: `tests/setup_plan_regression.ps1` 从失败变为通过。
- **SC-002**: `tests/setup_plan_json_output_regression.ps1` 持续通过。
- **SC-003**: 未来在任意 feature 分支执行上述回归结果一致。
