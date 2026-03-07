# Research: Runner Workspace Guard

## Decision 1
- 在每个子脚本执行前后采集 git 状态快照并做差集恢复。
- 原因：仅恢复本次执行新增污染，避免影响执行前已有改动。

## Decision 2
- 仅自动删除新增的 `.bak` 与 `.tmp` 文件。
- 原因：限制自动删除范围，降低误删风险。

## Decision 3
- JSON 汇总增加恢复统计字段，文本输出显示恢复动作。
- 原因：保证机读和人读两条路径都可观测。
