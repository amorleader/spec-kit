# Implementation Plan: Stabilize setup-plan Regression Mode Expectations

**Branch**: `014-stabilize-setup-plan` | **Date**: 2026-03-06 | **Spec**: `/specs/014-stabilize-setup-plan/spec.md`
**Input**: Feature specification from `/specs/014-stabilize-setup-plan/spec.md`

## Summary

修复 `tests/setup_plan_regression.ps1` 的模式混用：
文本模式负责 `ACTION` 断言，JSON 模式单独负责字段兼容断言，
并保持 `setup-plan.ps1` 现有输出契约不变。

## Technical Context

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: `tests/setup_plan_regression.ps1`, `.specify/scripts/powershell/setup-plan.ps1`  
**Storage**: N/A  
**Testing**: PowerShell regression scripts  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: Test stabilization
**Performance Goals**: unchanged
**Constraints**: do not change setup-plan production contract
**Scale/Scope**: single regression script refactor

## Constitution Check

- [x] Spec traceability exists from planned work to `spec.md` user stories and requirements.
- [x] CLI contract impact is documented (no production CLI change).
- [x] Test-first approach is defined (regression currently fails in 3 assertions).
- [x] Contract/integration coverage is planned for existing/missing/force and text/json modes.
- [x] Observability impact is documented (failure logs preserved).
- [x] Version impact is documented (PATCH).
- [x] Any added complexity is justified (minimal test-level refactor only).

## Project Structure

### Documentation (this feature)

```text
specs/014-stabilize-setup-plan/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

### Source Code

```text
tests/setup_plan_regression.ps1
```

**Structure Decision**: 仅修改回归测试与 014 文档，不改动 setup-plan 主脚本逻辑。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | 无新增复杂度 | 局部修复即可收敛问题 |

## Release Impact
- **SemVer**: PATCH
- **User-visible change**: 回归脚本不再因模式混用产生误报
- **Backward compatibility**: setup-plan 文本/JSON 输出契约保持不变
