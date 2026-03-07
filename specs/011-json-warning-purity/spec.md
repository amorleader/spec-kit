# Feature Specification: Keep create-new-feature JSON Mode Free of Warning Output

**Feature Branch**: `011-json-warning-purity`
**Created**: 2026-03-06
**Status**: Draft

## User Stories

### User Story 1 - JSON 模式输出纯净 (Priority: P1)
作为调用 `create-new-feature.ps1 -Json` 的自动化调用方，
我希望在触发“分支名截断 warning”时仍然只得到可解析 JSON，
以便稳定进行机读解析，不受告警文本污染。

**Independent Test**:
在长分支名触发截断的场景运行 `create-new-feature.ps1 -Json`，合并流输出应以 `{` 开始并可被 `ConvertFrom-Json` 成功解析。
该测试覆盖 warning conditions，验证 JSON 模式不会被 warning 文本污染。

**Acceptance Criteria**:
1. `-Json` 模式下不输出 warning 文本。
2. JSON 字段保持兼容：`BRANCH_NAME`、`SPEC_FILE`、`FEATURE_NUM`、`HAS_GIT`。

---

### User Story 2 - 文本模式 warning 可见 (Priority: P2)
作为手工执行脚本的开发者，
我希望在文本模式下继续看到 warning，
以便及时感知分支名截断等潜在问题。

**Independent Test**:
在同一长分支名场景运行不带 `-Json` 的命令，输出应包含 `WARNING:` 且保留 `ACTION:` 与 key-value 文本。

**Acceptance Criteria**:
1. 非 JSON 模式保留 warning 输出。
2. 文本模式的 `ACTION:` 与 key-value 输出行为保持不变。

---

### User Story 3 - 文档与契约一致 (Priority: P3)
作为维护该 CLI 的团队成员，
我希望 quickstart、contract 与 failure catalog 一致描述两种模式的 warning 行为，
以便后续修改和回归测试有清晰依据。

**Independent Test**:
运行文档一致性检查脚本，能够验证 quickstart/contract/spec 中关键语句存在且语义一致。

**Acceptance Criteria**:
1. 文档明确 JSON 模式不输出 warning。
2. 文档明确文本模式保留 warning。
3. 回归脚本和文档检查脚本均可通过。

## Requirements

### Functional Requirements
- FR-001: `create-new-feature.ps1 -Json` 在 warning 场景下必须保持纯 JSON 输出。
- FR-002: 文本模式在同类 warning 场景下必须继续输出 warning。
- FR-003: JSON 模式字段兼容性不得改变。
- FR-004: quickstart 与 contracts 必须反映上述行为并可被脚本化校验。

### Non-Functional Requirements
- NFR-001: 变更范围限制在现有脚本与回归资产，不新增运行时依赖。
- NFR-002: 语义版本影响为 PATCH。
