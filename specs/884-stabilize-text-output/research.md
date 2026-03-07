# Research: Text Output Stability

## Decision 1
- 维持文本模式关键字段行（如 `ACTION:`）作为稳定锚点。
- 原因：兼顾人工阅读与基于文本的轻量脚本消费。

## Decision 2
- 失败路径统一使用错误标题 + 下一步提示语义。
- 原因：跨脚本排障路径一致，降低支持成本。

## Decision 3
- 保持 JSON 模式行为不变，仅增强文本模式稳定性。
- 原因：避免影响既有机器消费链路。