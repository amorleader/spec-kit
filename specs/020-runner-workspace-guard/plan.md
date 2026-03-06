# Implementation Plan: Protect Workspace Cleanliness After Quality Runner Execution

**Branch**: `020-runner-workspace-guard` | **Date**: 2026-03-06 | **Spec**: `/specs/020-runner-workspace-guard/spec.md`
**Input**: Feature specification from `/specs/020-runner-workspace-guard/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

为 `tests/run_all_quality_checks.ps1` 增加脚本级工作区快照与恢复能力，自动清理执行期间产生的污染（如 `.bak`/`.tmp` 与新增tracked改动），并保证不覆盖执行前已有改动。

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
**Performance Goals**: 恢复逻辑增加的开销保持在秒级  
**Constraints**: 不引入破坏性行为；仅清理本次新增污染  
**Scale/Scope**: 修改 1 个聚合脚本 + 新增 2 个测试脚本 + 020 文档

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
tests/run_all_quality_checks_workspace_guard_regression.ps1
tests/validate_run_all_quality_checks_workspace_guard_docs.ps1
specs/020-runner-workspace-guard/spec.md
specs/020-runner-workspace-guard/plan.md
specs/020-runner-workspace-guard/research.md
specs/020-runner-workspace-guard/data-model.md
specs/020-runner-workspace-guard/quickstart.md
specs/020-runner-workspace-guard/contracts/quality-runner-workspace-guard-contract.md
specs/020-runner-workspace-guard/tasks.md
```

**Structure Decision**: 沿用 tests/ 下单脚本扩展模式，以最小改动实现工作区防污染。

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| git 状态快照恢复 | 仅清理本次执行新增污染 | 粗暴 `git checkout .` 会误伤已有未提交改动 |

## Release Impact

- **SemVer**: PATCH
- **User-visible change**: 新增工作区恢复诊断和 JSON 恢复统计
- **Backward compatibility**: 既有参数与返回状态保持兼容
