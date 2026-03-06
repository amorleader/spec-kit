# Implementation Plan: Stabilize check-prerequisites Regression Across Branches

**Branch**: `012-stabilize-check-prerequisites` | **Date**: 2026-03-06 | **Spec**: `/specs/012-stabilize-check-prerequisites/spec.md`
**Input**: Feature specification from `/specs/012-stabilize-check-prerequisites/spec.md`

## Summary

修复 `tests/check_prerequisites_regression.ps1` 对当前分支的隐式依赖：
通过在测试执行范围内显式设置 `SPECIFY_FEATURE=004-improve-check-prerequisites` 并在 finally 恢复，确保任意分支均可稳定回归。

## Technical Context

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: `.specify/scripts/powershell/check-prerequisites.ps1`, `.specify/scripts/powershell/common.ps1`  
**Storage**: N/A  
**Testing**: PowerShell regression scripts  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: CLI workflow test stabilization
**Performance Goals**: unchanged
**Constraints**: no behavior changes to production scripts; keep failure assertions intact
**Scale/Scope**: single regression script + feature docs

## Constitution Check

*GATE: Must pass before implementation.*

- [x] Spec traceability exists from planned work to `spec.md` user stories and requirements.
- [x] CLI contract impact is documented (no production CLI behavior change).
- [x] Test-first approach is defined (existing regression fails first on non-004 branch).
- [x] Contract/integration coverage is planned for exit-code and message assertions.
- [x] Observability impact is documented (failure messages retained).
- [x] Version impact is documented using semantic versioning (PATCH).
- [x] Any added complexity is justified (minimal env scoping only).

## Project Structure

### Documentation (this feature)

```text
specs/012-stabilize-check-prerequisites/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

### Source Code

```text
tests/check_prerequisites_regression.ps1
```

**Structure Decision**: 仅修改回归脚本与 012 文档，不变更生产脚本接口。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | 无新增复杂度 | 直接依赖当前分支会持续误报 |

## Release Impact
- **SemVer**: PATCH
- **User-visible change**: 回归脚本在任意分支稳定运行
- **Backward compatibility**: production CLI 输出与行为不变
