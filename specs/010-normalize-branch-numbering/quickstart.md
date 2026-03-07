# Quickstart: Three-digit Auto Numbering

1. 污染场景验证
- 准备包含 `010-...` 和 `8034-...` 的分支列表（后者为测试噪声）。
- 运行 `create-new-feature.ps1` 自动编号。
- 期望：下一个编号为 `011-*`。

2. 手动编号验证
- `create-new-feature.ps1 -Number 123 ...`
- 期望：输出 `123-*`。
