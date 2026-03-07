# Research: Workspace Status Parser Hardening

## Decision 1
- 为 git 状态行增加专用归一化解析函数。
- 原因：将 `old -> new`、空格路径等格式统一为恢复可用路径。

## Decision 2
- rename 条目优先使用 `->` 右侧路径进行恢复判断。
- 原因：恢复逻辑应针对当前工作区实际路径。

## Decision 3
- 新增专项回归覆盖 rename 与复杂路径样本。
- 原因：防止解析增强在后续迭代回退。
