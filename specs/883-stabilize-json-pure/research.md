# Research: JSON Pure Output Stabilization

## Decision 1
- 统一在 `-Json` 分支写入单一 JSON 文档。
- 原因：避免 `Write-Host`/`Write-Warning` 污染 stdout。

## Decision 2
- 失败路径输出结构化 JSON 错误对象。
- 原因：调用方可稳定解析并根据字段判定失败原因。

## Decision 3
- 优先补回归门禁，再改脚本实现。
- 原因：防止后续改动再次引入非 JSON 输出。