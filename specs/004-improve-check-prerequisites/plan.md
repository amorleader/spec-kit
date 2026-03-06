# Implementation Plan: Improve check-prerequisites Output Consistency

**Branch**: `004-improve-check-prerequisites` | **Date**: 2026-03-06 | **Spec**: `/specs/004-improve-check-prerequisites/spec.md`
**Input**: Feature specification from `/specs/004-improve-check-prerequisites/spec.md`

## Summary

统一 `check-prerequisites.ps1 -Json` 在不同执行上下文中的字段与失败语义，确保调用方获得稳定可解析输出；同时补齐契约文档与回归脚本，避免后续任务生成链路因输出漂移而中断。

## Technical Context

**Language/Version**: PowerShell 5.1+  
**Primary Dependencies**: Git CLI（可选）、Specify 脚本链（`check-prerequisites.ps1`）  
**Storage**: 文件系统（`specs/<feature>` 与文档文件）  
**Testing**: PowerShell 回归脚本（脚本级断言）  
**Target Platform**: Windows PowerShell / pwsh 兼容环境
**Project Type**: CLI workflow script hardening  
**Performance Goals**: 单次检查保持秒级，新增校验不引入可感知延迟  
**Constraints**: JSON 字段兼容；失败退出码可预测；日志可诊断  
**Scale/Scope**: 单脚本契约稳定性修复 + 文档/契约同步

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
specs/004-improve-check-prerequisites/
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
    └── check-prerequisites.ps1

tests/
└── check_prerequisites_regression.ps1
```

**Structure Decision**: 仅修改 `.specify/scripts/powershell/check-prerequisites.ps1`，配套新增/更新 `tests/` 与 `specs/004.../contracts` 文档，不引入额外目录层级。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 新增稳定性回归脚本 | 防止输出契约回归 | 仅靠人工运行无法覆盖多场景一致性 |

## Release Impact

- **SemVer**: PATCH（兼容性修复，稳定输出与失败语义）
- **User-visible change**:
    - `-Json` 成功输出固定字段：`FEATURE_DIR` + `AVAILABLE_DOCS`
    - 缺失 `plan.md`/`tasks.md` 的失败路径统一 non-zero + 可操作提示
- **Backward compatibility**: 不移除既有顶层 JSON 字段；`AVAILABLE_DOCS` 保持数组类型
