# Implementation Plan: Add JSON Summary Mode to Full Quality Check Runner

**Branch**: `017-json-summary-mode` | **Date**: 2026-03-06 | **Spec**: `/specs/017-json-summary-mode/spec.md`
**Input**: Feature specification from `/specs/017-json-summary-mode/spec.md`

## Summary

为 `tests/run_all_quality_checks.ps1` 增加 `-Json` 模式，输出纯 JSON 汇总对象，
并保持默认文本模式与分支恢复逻辑兼容。

## Technical Context

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: `tests/run_all_quality_checks.ps1`  
**Storage**: N/A  
**Testing**: JSON/text dual-mode execution checks  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: test tooling enhancement
**Performance Goals**: unchanged
**Constraints**: keep existing text-mode contract
**Scale/Scope**: one script enhancement + docs

## Constitution Check

- [x] Spec traceability exists from planned work to `spec.md` stories and requirements.
- [x] CLI contract impact documented (tooling-only argument extension).
- [x] Test-first approach defined (Json/Text compatibility checks).
- [x] Boundary coverage planned (IncludeDocsOnly + branch stability).
- [x] Observability impact documented (structured JSON fields).
- [x] Version impact documented (PATCH).
- [x] Complexity justified (single script refactor).

## Project Structure

### Documentation (this feature)

```text
specs/017-json-summary-mode/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

### Source Code

```text
tests/run_all_quality_checks.ps1
```

**Structure Decision**: 仅扩展 runner 输出模式，不改动子回归脚本。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | 无复杂度升级 | 需满足CI机读能力 |

## Release Impact
- **SemVer**: PATCH
- **User-visible change**: runner 支持 `-Json` 机读汇总
- **Backward compatibility**: 默认文本模式输出保持不变
