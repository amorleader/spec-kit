# Implementation Plan: Recover Missing Specs Directory for Existing Feature Branch

**Branch**: `006-recover-missing-specs` | **Date**: 2026-03-06 | **Spec**: `/specs/006-recover-missing-specs/spec.md`
**Input**: Feature specification from `/specs/006-recover-missing-specs/spec.md`

## Summary

修复 `create-new-feature.ps1` 在目标分支已存在时直接报错的行为，支持恢复式脚手架（补齐缺失目录/spec 文件）并保持输出契约兼容。

## Technical Context

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: Git CLI、`.specify/scripts/powershell/create-new-feature.ps1`  
**Storage**: 文件系统（`specs/<branch>/spec.md`）  
**Testing**: PowerShell 回归脚本（分支存在恢复场景）  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: CLI workflow script bugfix  
**Performance Goals**: 不增加可感知延迟（秒级）  
**Constraints**: 保持 JSON 字段兼容、避免覆盖已有 spec 内容  
**Scale/Scope**: 单脚本恢复逻辑 + 文档/测试

## Constitution Check

- [x] Spec traceability exists from planned work to `spec.md` user stories and requirements.
- [x] CLI contract impact is documented (commands, arguments, stdout/stderr, JSON output).
- [x] Test-first approach is defined (tests written first and expected to fail before implementation).
- [x] Contract/integration coverage is planned for interface, schema, or cross-component changes.
- [x] Observability impact is documented (logs/metrics/traces needed to diagnose failures).
- [x] Version impact is documented using semantic versioning, including breaking-change notes.
- [x] Any added complexity is justified in `## Complexity Tracking` with rejected simpler alternatives.

## Project Structure

### Documentation (this feature)

```text
specs/006-recover-missing-specs/
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
.specify/scripts/powershell/create-new-feature.ps1
tests/create_new_feature_recovery_regression.ps1
```

**Structure Decision**: 聚焦 `create-new-feature.ps1` 分支存在恢复逻辑，新增专用回归脚本与合同文档。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 新增 recovery 回归脚本 | 防止 branch-dir 不一致回归 | 手工验证不稳定且不可复用 |

## Release Impact

- **SemVer**: PATCH（分支恢复行为修复，保持输出兼容）
- **User-visible change**:
	- 目标分支已存在时不再直接失败，可进入恢复路径
	- 已存在 `spec.md` 时不覆盖原内容
- **Backward compatibility**: `BRANCH_NAME/SPEC_FILE/FEATURE_NUM/HAS_GIT` 字段保持不变
