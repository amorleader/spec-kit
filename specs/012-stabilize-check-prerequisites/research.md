# Research: Stabilize check-prerequisites Regression Across Branches

## Decision 1
- 回归脚本显式设置 `SPECIFY_FEATURE=004-improve-check-prerequisites`。
- 原因：该特性目录具备稳定的 `plan.md` 与 `tasks.md`，可复现缺失场景。

## Decision 2
- 使用 `try/finally` 恢复 `SPECIFY_FEATURE`。
- 原因：避免污染同一终端后续脚本上下文。

## Decision 3
- 不修改生产脚本。
- 原因：问题在测试上下文耦合，产品行为本身正确。
