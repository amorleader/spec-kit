# Research: Three-digit Branch Number Detection

## Decision 1
- 自动编号仅统计 `###-` 三位前缀分支/目录。
- 原因：与 feature 规范一致，避免测试分支（4+位）污染。

## Decision 2
- 保持手动 `-Number` 行为不变。
- 原因：兼容现有显式编号流程。

## Decision 3
- 增加回归覆盖：混入 4 位测试分支时自动编号仍基于三位分支。
- 原因：防止未来回归。

## Finalized After Implementation
- 自动编号分支匹配已收敛为 `^(\d{3})-`。
- specs 目录匹配已收敛为 `^(\d{3})-`。
- 手动 `-Number` 与后缀生成行为保持不变。
