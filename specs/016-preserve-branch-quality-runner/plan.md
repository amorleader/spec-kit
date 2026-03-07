# Implementation Plan: Preserve Current Branch in Full Quality Check Runner

**Branch**: `016-preserve-branch-quality-runner` | **Date**: 2026-03-06 | **Spec**: `/specs/016-preserve-branch-quality-runner/spec.md`
**Input**: Feature specification from `/specs/016-preserve-branch-quality-runner/spec.md`

## Summary

为 `tests/run_all_quality_checks.ps1` 增加“记录并恢复原始分支”的 finally 逻辑，
在不改变既有汇总契约的前提下，避免执行子回归导致当前工作分支漂移。

## Technical Context

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: `tests/run_all_quality_checks.ps1`  
**Storage**: N/A  
**Testing**: full-runner execution + before/after branch check  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: test tooling hardening
**Performance Goals**: unchanged
**Constraints**: keep existing runner output contract
**Scale/Scope**: single-script enhancement + docs

## Constitution Check

- [x] Spec traceability exists from planned work to `spec.md` stories and requirements.
- [x] CLI contract impact documented (tooling-only behavior extension).
- [x] Test-first approach defined (before/after branch assertions).
- [x] Boundary coverage planned (git repo + restore failure warning path).
- [x] Observability impact documented (explicit restore message/warning).
- [x] Version impact documented (PATCH).
- [x] Complexity justified (minimal finally-hook logic).

## Project Structure

### Documentation (this feature)

```text
specs/016-preserve-branch-quality-runner/
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

**Structure Decision**: 仅增强聚合脚本分支恢复能力，不变更被调用回归脚本。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | 无复杂度升级 | 不恢复分支会影响后续开发上下文 |

## Release Impact
- **SemVer**: PATCH
- **User-visible change**: 一键检查结束后自动回到原分支
- **Backward compatibility**: RUN/PASS/FAIL 与汇总输出契约不变
