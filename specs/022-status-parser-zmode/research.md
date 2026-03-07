# Research: Porcelain-Z Status Parser

## Decision 1
- 使用 `git status --porcelain -z` 读取工作区状态。
- 原因：NUL 分隔可避免路径中空格、箭头符号引发歧义。

## Decision 2
- rename/copy 状态按双 token 解析 old/new 路径。
- 原因：恢复逻辑需要同时感知源路径与目标路径。

## Decision 3
- 保留现有输出契约，仅替换内部解析路径。
- 原因：避免破坏既有调用方和回归基线。
