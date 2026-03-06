# Implementation Plan: Stabilize Text Output Check Behavior

**Branch**: `884-stabilize-text-output` | **Date**: 2026-03-06 | **Spec**: `/specs/884-stabilize-text-output/spec.md`
**Input**: Feature specification from `/specs/884-stabilize-text-output/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

稳定关键 PowerShell 脚本在文本模式下的输出格式与错误提示语义，通过专项回归与文档门禁降低输出回退风险。

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: `.specify/scripts/powershell/*.ps1`, regression tests  
**Storage**: N/A  
**Testing**: PowerShell regression + docs validation  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: CLI tooling hardening  
**Performance Goals**: 文本输出稳定化不引入可感知性能回退  
**Constraints**: 不新增 CLI 参数，不改变 JSON 模式契约  
**Scale/Scope**: 3 个脚本 + 2 个测试文件 + 884 文档

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
.specify/scripts/powershell/check-prerequisites.ps1
.specify/scripts/powershell/setup-plan.ps1
.specify/scripts/powershell/create-new-feature.ps1
tests/text_output_check_regression.ps1
tests/validate_text_output_check_docs.ps1
specs/884-stabilize-text-output/spec.md
specs/884-stabilize-text-output/plan.md
specs/884-stabilize-text-output/research.md
specs/884-stabilize-text-output/data-model.md
specs/884-stabilize-text-output/quickstart.md
specs/884-stabilize-text-output/contracts/text-output-check-contract.md
specs/884-stabilize-text-output/tasks.md
```

**Structure Decision**: 在现有脚本和测试框架上做文本输出契约稳定化增强。

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 统一文本错误提示语义 | 降低人工排障心智负担 | 仅修单脚本会导致跨脚本体验不一致 |

## Release Impact

- **SemVer**: PATCH
- **User-visible change**: 文本模式输出更稳定，失败提示更一致
- **Backward compatibility**: JSON 模式与参数保持兼容
