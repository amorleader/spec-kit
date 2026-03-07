# Implementation Plan: Allow check-prerequisites PathsOnly on Non-feature Branches

**Branch**: `007-allow-check-prerequisites` | **Date**: 2026-03-06 | **Spec**: `/specs/007-allow-check-prerequisites/spec.md`
**Input**: Feature specification from `/specs/007-allow-check-prerequisites/spec.md`

## Summary

让 `check-prerequisites.ps1` 的 `-PathsOnly` 模式不再受 feature 分支校验限制，从而在任意分支可返回路径；普通模式保持原有校验逻辑不变。

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: `.specify/scripts/powershell/check-prerequisites.ps1`  
**Storage**: 文件系统路径解析  
**Testing**: PowerShell 回归脚本  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: CLI workflow script bugfix  
**Performance Goals**: 维持秒级执行  
**Constraints**: 保持普通模式行为兼容  
**Scale/Scope**: 单脚本逻辑调整 + 文档与测试

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
specs/007-allow-check-prerequisites/
├── plan.md
├── spec.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
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
tests/check_prerequisites_paths_only_regression.ps1
```

**Structure Decision**: 仅调整 `check-prerequisites.ps1` 的分支校验执行顺序，配套新增 PathsOnly 回归与文档契约更新。

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 新增 PathsOnly 回归脚本 | 防止模式回归 | 仅手工验证无法覆盖分支组合 |

## Release Impact

- **SemVer**: PATCH
- **User-visible change**: `-PathsOnly` 在非 feature 分支返回路径而非直接失败
- **Backward compatibility**: 普通模式与输出字段保持兼容

## Final Notes
- PathsOnly 仅改变是否执行分支门禁，不改变输出字段集合。
- 普通模式错误码和错误提示保持既有行为。
