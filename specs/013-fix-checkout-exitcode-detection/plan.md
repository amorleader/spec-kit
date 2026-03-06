# Implementation Plan: Fix Checkout Exit Code Detection in create-new-feature

**Branch**: `013-fix-checkout-exitcode-detection` | **Date**: 2026-03-06 | **Spec**: `/specs/013-fix-checkout-exitcode-detection/spec.md`
**Input**: Feature specification from `/specs/013-fix-checkout-exitcode-detection/spec.md`

## Summary

修复 `create-new-feature.ps1` 在恢复已有分支时对 `git checkout` 结果的误判，
并同步更新 recovery 回归中的失败注入模式，确保成功/失败两条路径都可稳定验证。

## Technical Context

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: `.specify/scripts/powershell/create-new-feature.ps1`, `tests/create_new_feature_recovery_regression.ps1`  
**Storage**: N/A  
**Testing**: PowerShell regression scripts  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: CLI workflow bugfix
**Performance Goals**: unchanged
**Constraints**: keep JSON contract and existing success output stable
**Scale/Scope**: single script logic + single regression injection update

## Constitution Check

- [x] Spec traceability exists from planned work to `spec.md` user stories and requirements.
- [x] CLI contract impact is documented (behavior fix only, no new args/fields).
- [x] Test-first approach is defined (recovery regression fails before fix).
- [x] Contract/integration coverage is planned for success and injected-failure branches.
- [x] Observability impact is documented (actionable error kept).
- [x] Version impact is documented using semantic versioning (PATCH).
- [x] Any added complexity is justified (minimal localized changes).

## Project Structure

### Documentation (this feature)

```text
specs/013-fix-checkout-exitcode-detection/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

### Source Code

```text
.specify/scripts/powershell/create-new-feature.ps1
tests/create_new_feature_recovery_regression.ps1
```

**Structure Decision**: 聚焦 checkout 退出码判定和回归注入同步，不触及其他模块。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | 无额外复杂度引入 | 局部修复可解决问题 |

## Release Impact
- **SemVer**: PATCH
- **User-visible change**: 已存在分支恢复路径不再误报失败
- **Backward compatibility**: JSON/text 输出字段与语义保持兼容
