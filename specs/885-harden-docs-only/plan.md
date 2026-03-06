# Implementation Plan: Harden Docs-Only Aggregate Execution

**Branch**: `885-harden-docs-only` | **Date**: 2026-03-06 | **Spec**: `/specs/885-harden-docs-only/spec.md`
**Input**: Feature specification from `/specs/885-harden-docs-only/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

加固 `run_all_quality_checks.ps1` 的 docs-only 执行路径，确保在新增 validator 或失败场景下统计、状态传播和输出契约稳定。

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: `tests/run_all_quality_checks.ps1`, docs validators  
**Storage**: N/A  
**Testing**: PowerShell regression + docs validation  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: CLI test harness hardening  
**Performance Goals**: docs-only 执行保持快速与稳定  
**Constraints**: 保持 CLI 参数与 JSON 字段兼容  
**Scale/Scope**: 1 个聚合脚本 + 2 个测试文件 + 885 文档

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

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
tests/run_all_quality_checks.ps1
tests/run_all_quality_checks_docs_only_regression.ps1
tests/validate_docs_only_hardening_docs.ps1
specs/885-harden-docs-only/spec.md
specs/885-harden-docs-only/plan.md
specs/885-harden-docs-only/research.md
specs/885-harden-docs-only/data-model.md
specs/885-harden-docs-only/quickstart.md
specs/885-harden-docs-only/contracts/docs-only-aggregate-contract.md
specs/885-harden-docs-only/tasks.md
```

**Structure Decision**: 以最小改动加固 docs-only 聚合路径并补齐专项门禁。

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 专项 docs-only 回归 | 保护高频轻量路径 | 仅依赖全量回归难以及时发现 docs-only 回退 |

## Release Impact

- **SemVer**: PATCH
- **User-visible change**: docs-only 路径稳定性提升
- **Backward compatibility**: 参数与输出字段保持兼容
