# Implementation Plan: Fix create-new-feature Argument Parsing Consistency

**Branch**: `005-fix-create-new` | **Date**: 2026-03-06 | **Spec**: `/specs/005-fix-create-new/spec.md`
**Input**: Feature specification from `/specs/005-fix-create-new/spec.md`

## Summary

修复 `create-new-feature.ps1` 在常见参数顺序下的描述解析不一致问题，确保入口命令稳定可用；同时保持既有 JSON 输出契约、编号规则和分支命名逻辑不变。

## Technical Context

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: Git CLI（可选）、`.specify/scripts/powershell/create-new-feature.ps1`  
**Storage**: 文件系统（`specs/<feature>/spec.md` 与分支创建）  
**Testing**: PowerShell 回归脚本（参数组合与输出断言）  
**Target Platform**: Windows PowerShell / pwsh
**Project Type**: CLI workflow script bugfix  
**Performance Goals**: 参数解析开销保持可忽略，执行仍为秒级  
**Constraints**: 兼容既有输出字段与分支命名规则；错误信息可诊断  
**Scale/Scope**: 单脚本修复 + 回归脚本 + 契约文档更新

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Spec traceability exists from planned work to `spec.md` user stories and requirements.
- [x] CLI contract impact is documented (commands, arguments, stdout/stderr, JSON output).
- [x] Test-first approach is defined (tests written first and expected to fail before implementation).
- [x] Contract/integration coverage is planned for interface, schema, or cross-component changes.
- [x] Observability impact is documented (logs/metrics/traces needed to diagnose failures).
- [x] Version impact is documented using semantic versioning, including breaking-change notes.
- [x] Any added complexity is justified in `## Complexity Tracking` with rejected simpler alternatives.

**Post-Design Re-check**: PASS

## Project Structure

### Documentation (this feature)

```text
specs/005-fix-create-new/
├── plan.md
├── spec.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

### Source Code (repository root)

```text
.specify/
└── scripts/powershell/
    └── create-new-feature.ps1

tests/
├── create_new_feature_regression.ps1
└── helpers/
```

**Structure Decision**: 变更聚焦 `.specify/scripts/powershell/create-new-feature.ps1` 参数解析路径；测试与契约文档在 `tests/` 与 `specs/005.../contracts` 配套维护。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 增加参数解析回归脚本 | 防止顺序相关回归 | 人工调用覆盖不到参数组合边界 |

## Release Impact

- **SemVer**: PATCH（参数解析行为修复，不引入破坏性输出变更）
- **User-visible change**:
    - 支持 `-Json "description"` 与 `"description" -Json` 两种常见调用顺序
    - 缺失描述输入时保持 non-zero 失败与明确 usage 提示
- **Backward compatibility**: JSON 输出字段 `BRANCH_NAME/SPEC_FILE/FEATURE_NUM/HAS_GIT` 保持兼容
