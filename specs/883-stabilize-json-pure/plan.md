# Implementation Plan: Stabilize JSON Pure Check Output

**Branch**: `883-stabilize-json-pure` | **Date**: 2026-03-06 | **Spec**: `/specs/883-stabilize-json-pure/spec.md`
**Input**: Feature specification from `/specs/883-stabilize-json-pure/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

统一并稳定关键脚本在 `-Json` 模式下的纯净输出，覆盖成功和失败路径，消除非 JSON 文本污染并补齐回归门禁。

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: `.specify/scripts/powershell/*.ps1`, Git CLI  
**Storage**: N/A  
**Testing**: PowerShell regression + docs validation  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: CLI tooling hardening  
**Performance Goals**: 不引入可感知延迟  
**Constraints**: 不新增 CLI 参数；维持现有成功/失败语义  
**Scale/Scope**: 3 个脚本 + 2 个新增测试脚本 + 883 文档

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
tests/json_pure_output_regression.ps1
tests/validate_json_pure_output_docs.ps1
specs/883-stabilize-json-pure/spec.md
specs/883-stabilize-json-pure/plan.md
specs/883-stabilize-json-pure/research.md
specs/883-stabilize-json-pure/data-model.md
specs/883-stabilize-json-pure/quickstart.md
specs/883-stabilize-json-pure/contracts/json-pure-output-contract.md
specs/883-stabilize-json-pure/tasks.md
```

**Structure Decision**: 在既有脚本上做 JSON 输出路径收敛并补齐专项回归。

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 统一失败 JSON 输出 | 保障自动化消费稳定 | 仅修单一脚本会导致跨脚本契约不一致 |

## Release Impact

- **SemVer**: PATCH
- **User-visible change**: `-Json` 模式输出更稳定、可解析性更高
- **Backward compatibility**: 参数与成功语义保持兼容
