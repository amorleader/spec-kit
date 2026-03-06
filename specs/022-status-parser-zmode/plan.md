# Implementation Plan: Use Porcelain-Z Parser for Workspace Status Recovery

**Branch**: `022-status-parser-zmode` | **Date**: 2026-03-06 | **Spec**: `/specs/022-status-parser-zmode/spec.md`
**Input**: Feature specification from `/specs/022-status-parser-zmode/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

将工作区快照解析由普通 porcelain 文本模式升级为 `--porcelain -z`，稳健支持 rename 双路径和特殊文件名，确保恢复逻辑对复杂路径稳定有效。

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
**Performance Goals**: 解析升级不引入可感知性能回退  
**Constraints**: 保持 CLI 输出兼容；仅替换内部快照解析  
**Scale/Scope**: 修改 1 个脚本 + 新增 2 个测试脚本 + 022 文档

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
tests/run_all_quality_checks_status_parser_zmode_regression.ps1
tests/validate_run_all_quality_checks_status_parser_zmode_docs.ps1
specs/022-status-parser-zmode/spec.md
specs/022-status-parser-zmode/plan.md
specs/022-status-parser-zmode/research.md
specs/022-status-parser-zmode/data-model.md
specs/022-status-parser-zmode/quickstart.md
specs/022-status-parser-zmode/contracts/quality-runner-status-parser-zmode-contract.md
specs/022-status-parser-zmode/tasks.md
```

**Structure Decision**: 在现有 quality runner 上做解析内核升级与针对性回归补充。

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 引入 NUL 分隔解析 | 正确覆盖复杂路径与 rename 双路径 | 文本 split 对特殊路径易歧义 |

## Release Impact

- **SemVer**: PATCH
- **User-visible change**: 无新增参数，内部解析稳定性增强
- **Backward compatibility**: 输出字段和退出语义保持兼容
