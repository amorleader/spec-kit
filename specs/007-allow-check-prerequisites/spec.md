# Feature Specification: Allow check-prerequisites PathsOnly on Non-feature Branches

**Feature Branch**: `007-allow-check-prerequisites`  
**Created**: 2026-03-06  
**Status**: Draft  
**Input**: User description: "Allow check-prerequisites PathsOnly on non-feature branches"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - PathsOnly Works Everywhere (Priority: P1)
作为调用者，我希望 `check-prerequisites.ps1 -PathsOnly` 在任意分支都可返回路径信息，不被 feature 分支校验阻断。

**Why this priority**: 这是调用链路入口能力，失败会阻断自动化探测。

**Independent Test**: 在非 `###-` 分支执行 `-PathsOnly -Json`，返回 0 且输出路径字段。

### User Story 2 - Keep Existing Validation for Normal Mode (Priority: P2)
作为维护者，我希望普通模式仍保持原有 feature 分支校验，不引入行为回退。

**Why this priority**: 防止修复 PathsOnly 时误改普通模式语义。

**Independent Test**: 在非 feature 分支执行普通模式，保持 deterministic 的 non-zero 失败。

### User Story 3 - Update Docs Contract (Priority: P3)
作为团队成员，我希望契约文档明确 PathsOnly 与普通模式的差异。

**Why this priority**: 文档一致性保障可维护性。

**Independent Test**: 仅按 quickstart/contract 即可正确预期成功与失败。

### Edge Cases
- `-PathsOnly -Json` 与 `-PathsOnly` 文本模式都应可用。
- 输出字段应保持稳定并可解析。
- 普通模式仍需在无效分支返回 non-zero。

## Requirements *(mandatory)*
- **FR-001**: `-PathsOnly` MUST bypass feature-branch validation.
- **FR-002**: normal mode MUST keep existing branch validation behavior.
- **FR-003**: PathsOnly output fields MUST remain stable.
- **FR-004**: docs/contracts MUST describe mode difference.

## Constitution Alignment *(mandatory)*
- **CA-001**: US1→FR-001/FR-003, US2→FR-002, US3→FR-004
- **CA-002**: CLI behavior changes only for PathsOnly mode
- **CA-003**: Tests fail first on non-feature branch PathsOnly
- **CA-004**: Cover PathsOnly JSON/text and normal-mode failure
- **CA-005**: PATCH-level behavior fix

## Success Criteria *(mandatory)*
- **SC-001**: non-feature branch + PathsOnly success rate 100%
- **SC-002**: non-feature branch + normal mode failure rate 100%
- **SC-003**: output field compatibility remains 100%
