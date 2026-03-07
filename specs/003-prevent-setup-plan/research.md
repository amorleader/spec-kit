# Phase 0 Research — Prevent setup-plan Overwrite

## Research Scope
- 目标：防止 `setup-plan.ps1` 默认覆盖已有 `plan.md`。
- 输入：`spec.md`、现有 `setup-plan.ps1` 行为、宪法 1.0.0。

## Decisions

### 1) Safe Default Behavior
- Decision: 默认模式下若 `plan.md` 已存在，则保留并返回路径，不再复制模板。
- Rationale: 避免覆盖人工编辑内容，符合“安全默认”原则。
- Alternatives considered:
  - 每次都覆盖：存在高风险，已在 002 中被证明会导致文档回退。
  - 每次都报错：过于严格，阻断常规流程。

### 2) Explicit Overwrite Path
- Decision: 增加显式覆盖参数（建议 `-Force`），仅在用户明确要求时覆盖。
- Rationale: 平衡安全性与可操作性。
- Alternatives considered:
  - 不提供覆盖参数：无法快速重置模板。
  - 隐式覆盖条件（如文件为空时覆盖）：规则不透明，容易误判。

### 3) Output Compatibility
- Decision: 保持 `setup-plan -Json` 输出字段不变（`FEATURE_SPEC/IMPL_PLAN/SPECS_DIR/BRANCH/HAS_GIT`）。
- Rationale: 防止下游流程解析失败。
- Alternatives considered:
  - 更改字段名：会破坏已有自动化。

### 4) Observability
- Decision: 在标准输出中明确提示本次动作（created/preserved/overwritten）。
- Rationale: 便于定位行为与审计。
- Alternatives considered:
  - 不输出动作类型：调试成本高。

### 5) Test Strategy
- Decision: 先写失败测试（existing plan 被覆盖），再实现修复并回归验证。
- Rationale: 满足测试优先要求，确保修复可回归。
- Alternatives considered:
  - 手工 spot check：覆盖不足，易回归。

## Open Clarifications
- 无阻塞项；参数命名选择 `-Force`，与 PowerShell 习惯一致。

## Finalized After Implementation
- `-Force` 已作为显式覆盖参数落地到 `setup-plan.ps1`。
- 默认模式与覆盖模式均已通过回归脚本验证。
- JSON 输出字段兼容性保持不变（未新增/删除核心字段）。
