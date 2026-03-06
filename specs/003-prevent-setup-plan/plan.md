# Implementation Plan: Prevent setup-plan Overwrite

**Branch**: `003-prevent-setup-plan` | **Date**: 2026-03-06 | **Spec**: `/specs/003-prevent-setup-plan/spec.md`
**Input**: Feature specification from `/specs/003-prevent-setup-plan/spec.md`

## Summary

修复 `setup-plan.ps1` 在 `plan.md` 已存在时的默认覆盖行为，改为“默认保留、显式覆盖”，并保持 JSON 输出契约兼容；同时补齐测试与文档，避免再次发生规划文件回退。

## Technical Context

**Language/Version**: PowerShell 5.1+（脚本）与 Markdown（文档）  
**Primary Dependencies**: Specify CLI、Git、`.specify/scripts/powershell/setup-plan.ps1`  
**Storage**: 文件系统（`specs/<branch>/plan.md`）  
**Testing**: PowerShell 脚本级回归验证 + `check-prerequisites.ps1` 阶段校验  
**Target Platform**: Windows（当前），并保持对 `pwsh` 执行兼容  
**Project Type**: CLI 驱动的 workflow 工具脚本修复  
**Performance Goals**: `setup-plan` 额外判断逻辑不引入可感知延迟（本地单次执行保持秒级）  
**Constraints**: 默认行为必须安全、输出字段必须兼容、错误提示必须可操作  
**Scale/Scope**: 单脚本行为修复 + 契约/文档更新 + 验证工件

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Spec traceability exists from planned work to `spec.md` user stories and requirements.
- [x] CLI contract impact is documented (commands, arguments, stdout/stderr, JSON output).
- [x] Test-first approach is defined (tests written first and expected to fail before implementation).
- [x] Contract/integration coverage is planned for interface, schema, or cross-component changes.
- [x] Observability impact is documented (logs/metrics/traces needed to diagnose failures).
- [x] Version impact is documented using semantic versioning, including breaking-change notes.
- [x] Any added complexity is justified in `## Complexity Tracking` with rejected simpler alternatives.

**Post-Design Re-check**: PASS（本特性设计阶段无新增宪法违例）

## Project Structure

### Documentation (this feature)

```text
specs/003-prevent-setup-plan/
├── plan.md
├── spec.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

### Source Code (repository root)

```text
.specify/
├── scripts/powershell/
│   └── setup-plan.ps1
└── templates/

specs/
└── 003-prevent-setup-plan/
```

**Structure Decision**: 本特性为脚本行为修复，核心变更聚焦 `.specify/scripts/powershell/setup-plan.ps1`，并同步规范文档与契约文件。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 增加显式覆盖参数分支 | 兼顾“安全默认”与“可控覆盖”两类场景 | 仅保留默认不覆盖会阻断合法重置流程 |

## Release Impact

- **SemVer**: PATCH（行为修正，不引入破坏性字段变更）
- **User-visible change**:
	- 默认模式：existing `plan.md` 保留，输出 `ACTION: preserved`
	- 强制模式：`-Force` 覆盖 existing `plan.md`，输出 `ACTION: overwritten`
	- 缺失文件：创建 `plan.md`，输出 `ACTION: created`
- **Backward compatibility**: `-Json` 输出字段 `FEATURE_SPEC/IMPL_PLAN/SPECS_DIR/BRANCH/HAS_GIT` 保持兼容
