# Implementation Plan: Normalize Auto Branch Numbering to Three-digit Feature Branches

**Branch**: `010-normalize-branch-numbering` | **Date**: 2026-03-06 | **Spec**: `/specs/010-normalize-branch-numbering/spec.md`
**Input**: Feature specification from `/specs/010-normalize-branch-numbering/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

修复 `create-new-feature.ps1` 自动编号逻辑，仅统计三位 `###-` feature 分支/目录，避免测试分支污染导致编号跳跃。

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: `.specify/scripts/powershell/create-new-feature.ps1`  
**Storage**: git branch list + specs directory  
**Testing**: PowerShell regression script  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: CLI workflow script bugfix  
**Performance Goals**: 编号计算保持毫秒级  
**Constraints**: 保持手动编号与分支后缀逻辑兼容  
**Scale/Scope**: 单脚本编号规则修复 + 文档/测试

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

**Structure Decision**: 仅调整 create-new-feature 中分支/目录编号匹配正则，增加回归验证污染场景。

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 增加编号污染回归测试 | 防止分支噪声回归 | 人工验证覆盖不足 |

## Release Impact
- **SemVer**: PATCH
- **User-visible change**: 自动编号忽略非三位 feature 前缀
- **Backward compatibility**: `-Number` 手动编号与后缀逻辑不变

## Final Notes
- 该修复不会影响已有三位 feature 分支的编号顺序。
- 非标准编号分支仅作为噪声被忽略，不改变其存在性。
