# Research: Quality Runner Timeout Guard

## Decision 1
- 为聚合器增加可选参数 `-PerScriptTimeoutSec`，默认 `0` 禁用超时。
- 原因：默认行为不变，按需启用，兼顾兼容性与稳定性。

## Decision 2
- 子脚本执行采用可等待并可终止的子进程方式，实现脚本级超时。
- 原因：需要可预测地停止卡死脚本，并继续后续脚本执行。

## Decision 3
- 文本与 JSON 同步增加超时诊断（状态标签与顶层计数）。
- 原因：便于 CI 与人工日志同时定位 TIMEOUT 场景。
