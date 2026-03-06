# Implementation Plan: Add Full Quality Check Runner

**Branch**: `015-full-quality-check-runner` | **Date**: 2026-03-06 | **Spec**: `/specs/015-full-quality-check-runner/spec.md`
**Input**: Feature specification from `/specs/015-full-quality-check-runner/spec.md`

## Summary

新增 `tests/run_all_quality_checks.ps1` 聚合执行全部 regression 与 docs 校验脚本，
输出统一 RUN/PASS/FAIL 报告，并在失败时返回非 0。

## Technical Context

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: existing scripts under `tests/`  
**Storage**: N/A  
**Testing**: run aggregator + existing regression/doc scripts  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: test tooling enhancement
**Performance Goals**: unchanged
**Constraints**: no changes to production scripts
**Scale/Scope**: one new runner script + feature docs

## Constitution Check

- [x] Spec traceability exists from planned work to `spec.md` user stories and requirements.
- [x] CLI contract impact is documented (tooling only).
- [x] Test-first approach is defined (runner verified against current suite).
- [x] Contract/integration coverage is planned (success and failure summary).
- [x] Observability impact is documented (structured summary output).
- [x] Version impact is documented (PATCH).
- [x] Any added complexity is justified (single script, minimal logic).

## Project Structure

### Documentation (this feature)

```text
specs/015-full-quality-check-runner/
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

**Structure Decision**: 增量新增测试聚合脚本，不改动现有脚本行为。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | 无复杂度升级 | 手工逐个运行成本高且易漏 |

## Release Impact
- **SemVer**: PATCH
- **User-visible change**: 新增一键质量检查入口
- **Backward compatibility**: 现有脚本与契约保持不变
