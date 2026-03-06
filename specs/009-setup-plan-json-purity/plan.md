# Implementation Plan: Stabilize Pure JSON Output for setup-plan

**Branch**: `009-setup-plan-json-purity` | **Date**: 2026-03-06 | **Spec**: `/specs/009-setup-plan-json-purity/spec.md`
**Input**: Feature specification from `/specs/009-setup-plan-json-purity/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

修复 `setup-plan.ps1 -Json` 混入 ACTION 文本导致的解析不稳定问题；保留非 JSON 模式下 ACTION 可读提示。

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: `.specify/scripts/powershell/setup-plan.ps1`  
**Storage**: 文件系统  
**Testing**: PowerShell 回归脚本  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: CLI workflow script bugfix  
**Performance Goals**: 秒级执行保持不变  
**Constraints**: JSON 字段兼容、文本模式可读性保持  
**Scale/Scope**: 单脚本输出语义修复 + 文档/测试

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
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: 仅修改 `setup-plan.ps1` 的 JSON 输出路径；回归与契约文档配套更新。

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 增加 JSON 纯净回归脚本 | 防止输出回归 | 手工验证不稳定 |

## Release Impact
- **SemVer**: PATCH
- **User-visible change**: `-Json` 模式仅输出 JSON
- **Backward compatibility**: JSON 字段保持不变，文本模式 ACTION 保持不变
