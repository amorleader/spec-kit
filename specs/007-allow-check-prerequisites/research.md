# Research: PathsOnly Branch Validation

## Decision 1
- PathsOnly 模式应跳过 feature 分支校验。
- 原因：该模式仅用于路径发现，不依赖分支合法性。

## Decision 2
- 普通模式继续执行原有分支校验。
- 原因：避免改变现有失败语义与调用预期。

## Decision 3
- 回归覆盖 PathsOnly 成功 + normal mode 失败。
- 原因：确保模式边界稳定。

## Finalized After Implementation
- `-PathsOnly` 已在分支校验前返回路径输出。
- 普通模式保持原有 feature 分支失败语义。
- 回归脚本验证 PathsOnly 成功、normal mode 失败边界均稳定。
