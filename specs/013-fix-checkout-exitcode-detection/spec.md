# Feature Specification: Fix Checkout Exit Code Detection in create-new-feature

**Feature Branch**: `013-fix-checkout-exitcode-detection`  
**Created**: 2026-03-06  
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - 非当前分支恢复必须成功 (Priority: P1)

作为在已有目标分支之外执行 `create-new-feature` 的开发者，
我希望脚本在目标分支已存在时能够稳定 checkout 并继续执行，
避免出现“已切换分支但脚本误报失败”的情况。

**Why this priority**: 这是恢复路径核心场景，失败会阻断流程。

**Independent Test**: 运行 `tests/create_new_feature_recovery_regression.ps1` 的 US2 第一用例，期望通过。

**Acceptance Scenarios**:
1. **Given** 目标分支已存在且当前不在该分支，**When** 执行 `create-new-feature.ps1`，**Then** 返回成功并切换到目标分支。
2. **Given** `git checkout -b` 先失败（分支已存在），**When** 执行恢复逻辑，**Then** 后续 `git checkout` 结果被正确判定。

---

### User Story 2 - 强制 checkout 失败必须报错 (Priority: P2)

作为维护者，我希望当 checkout 真失败时仍然返回非 0 并给出可操作报错，
确保故障注入与真实错误都能被检测到。

**Why this priority**: 保护失败路径，避免“误成功”。

**Independent Test**: 回归中的 `failed checkout returns actionable error` 用例应返回非 0。

**Acceptance Scenarios**:
1. **Given** checkout 语句被注入 `throw`，**When** 执行脚本，**Then** 返回非 0。

---

### User Story 3 - 回归注入脚本与实现保持同步 (Priority: P3)

作为测试维护者，我希望故障注入替换模式跟随实现语句更新，
避免测试因注入失效而产生假阳性。

**Why this priority**: 防止回归脚本失真。

**Independent Test**: 更新后的注入替换规则能命中当前 checkout 语句并触发失败路径。

**Acceptance Scenarios**:
1. **Given** create-new-feature checkout 语句更新，**When** 运行回归，**Then** 注入仍然生效。

### Edge Cases

- `git checkout` 实际成功但前序命令失败码残留，不应误判。
- 失败注入命中失败时必须维持非 0 退出码契约。

## Requirements

### Functional Requirements

- **FR-001**: 恢复路径的 checkout 结果判定必须基于当前 checkout 命令真实退出码。
- **FR-002**: checkout 失败时脚本必须返回非 0 并输出可操作错误信息。
- **FR-003**: 回归测试中的故障注入模式必须匹配当前实现语句。
- **FR-004**: 不改变 JSON 输出字段与正常成功路径输出格式。

## Constitution Alignment

- **CA-001 Spec Traceability**: US1→FR-001，US2→FR-002，US3→FR-003。
- **CA-002 CLI Contract Impact**: 仅修复错误判定，不新增参数/字段。
- **CA-003 Test-First Plan**: 先运行 recovery 回归复现失败，再实现修复并复测通过。
- **CA-004 Boundary Coverage**: 覆盖恢复成功与恢复失败注入两条边界路径。
- **CA-005 Observability & Versioning**: 版本影响 PATCH，错误信息保持可诊断。

## Success Criteria

### Measurable Outcomes

- **SC-001**: `tests/create_new_feature_recovery_regression.ps1` 在当前分支通过。
- **SC-002**: 非当前分支恢复用例返回成功且当前分支正确切换。
- **SC-003**: 故障注入用例返回非 0，维持失败语义。
