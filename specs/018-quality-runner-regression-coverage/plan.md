# Implementation Plan: Add Regression Coverage for Full Quality Runner

**Branch**: `018-quality-runner-regression-coverage` | **Date**: 2026-03-06 | **Spec**: `/specs/018-quality-runner-regression-coverage/spec.md`
**Input**: Feature specification from `/specs/018-quality-runner-regression-coverage/spec.md`

## Summary

新增 quality runner 的独立回归与文档校验脚本，确保 JSON 契约、文本兼容、分支稳定和文档一致性都可自动化门禁。

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: tests/run_all_quality_checks.ps1  
**Storage**: N/A  
**Testing**: PowerShell regression + docs validation  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: test coverage enhancement  
**Performance Goals**: unchanged  
**Constraints**: no behavioral change to runner core logic  
**Scale/Scope**: 3 new test assets + 018 docs

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Spec traceability exists from planned work to `spec.md` stories and requirements.
- [x] CLI contract impact is documented (test/tooling only).
- [x] Test-first approach is defined (new regression fails before docs are ready).
- [x] Contract/integration coverage is planned for JSON fields and docs semantics.
- [x] Observability impact is documented (clear failure labels and exit codes).
- [x] Version impact is documented using semantic versioning (PATCH).
- [x] Added complexity is minimal and justified.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
tests/helpers/assert_run_all_quality_checks_json.ps1
tests/run_all_quality_checks_regression.ps1
tests/validate_run_all_quality_checks_docs.ps1
```

**Structure Decision**: 仅补齐质量 runner 的测试与文档校验覆盖。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | 无复杂度升级 | 当前改动为测试资产增量 |

## Release Impact
- **SemVer**: PATCH
- **User-visible change**: 增加 runner 专项回归与文档门禁脚本
- **Backward compatibility**: runner 与其他脚本行为不变
