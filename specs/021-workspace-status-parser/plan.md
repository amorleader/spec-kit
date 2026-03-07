# Implementation Plan: Harden Workspace Recovery with Robust Git Status Parsing

**Branch**: `021-workspace-status-parser` | **Date**: 2026-03-06 | **Spec**: `/specs/021-workspace-status-parser/spec.md`
**Input**: Feature specification from `/specs/021-workspace-status-parser/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

增强 `run_all_quality_checks.ps1` 中工作区恢复对 git porcelain 状态行的解析能力，重点覆盖 rename 与复杂路径格式，确保恢复逻辑稳定回滚本次新增污染。

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: `tests/run_all_quality_checks.ps1`, Git CLI  
**Storage**: N/A  
**Testing**: PowerShell regression + docs validation  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: test tooling hardening  
**Performance Goals**: 解析增强不引入明显时延  
**Constraints**: 保持现有 CLI 兼容；恢复逻辑仅影响新增污染  
**Scale/Scope**: 修改 1 个聚合脚本 + 新增 2 条测试脚本 + 021 文档

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
tests/run_all_quality_checks_status_parser_regression.ps1
tests/validate_run_all_quality_checks_status_parser_docs.ps1
specs/021-workspace-status-parser/spec.md
specs/021-workspace-status-parser/plan.md
specs/021-workspace-status-parser/research.md
specs/021-workspace-status-parser/data-model.md
specs/021-workspace-status-parser/quickstart.md
specs/021-workspace-status-parser/contracts/quality-runner-status-parser-contract.md
specs/021-workspace-status-parser/tasks.md
```

**Structure Decision**: 在现有 quality runner 体系上做解析增强和测试补充，避免扩散改动面。

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 状态行归一化函数 | 统一处理 rename 与复杂路径 | 直接字符串切片在 `old -> new` 场景容易误判 |

## Release Impact

- **SemVer**: PATCH
- **User-visible change**: 无新增参数；恢复稳健性增强
- **Backward compatibility**: 维持既有输出字段与行为
